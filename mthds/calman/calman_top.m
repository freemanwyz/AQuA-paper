function res = calman_top(dat,tsub,options,K,patches,tau,p,dlSave,showMe)
    % Top level Calman, modified by Yizhi
    % TODO: specify input presets
    
    % complete pipeline for calcium imaging data pre-processing
    %dlSave = './mthds/calman/';  % save CNN model
    %fCalmAn = '../../repo/CalmAn/';
    %addpath(fCalmAn)
    %addpath(genpath([fCalmAn,'utilities']));
    %addpath(genpath([fCalmAn,'deconvolution']));
    
    sessId = randi(1e8);
    foldername = [tempdir,'calman',num2str(sessId),filesep];
    if ~exist(foldername,'dir')
        mkdir(foldername);
    end

    fileIn = {[foldername,'tmpDat.tif']};
    writeTiffSeq(fileIn{1},dat,16);
    
    numFiles = numel(fileIn);
    FOV = size(read_file(fileIn{1},1,1));
        
    % downsample h5 files and save into a single memory mapped matlab file
    % --------------------------------------------------------------------
    
    fullname = fileIn{1};
    [folder_name,file_name,~] = fileparts(fullname);
    regFile = fullfile(folder_name,[file_name,'_mc.h5']);
    convert_file(fullname,'h5',regFile);
    registered_files = {regFile};
    
    ds_filename = [foldername,'/ds_data.mat'];
    data_type = class(read_file(registered_files{1},1,1));
    data = matfile(ds_filename,'Writable',true);
    data.Y  = zeros([FOV,0],data_type);
    data.Yr = zeros([prod(FOV),0],data_type);
    data.sizY = [FOV,0];
    F_dark = Inf;                                    % dark fluorescence (min of all data)
    batch_size = 2000;                               % read chunks of that size
    batch_size = round(batch_size/tsub)*tsub;        % make sure batch_size is divisble by tsub
    Ts = zeros(numFiles,1);                          % store length of each file
    cnt = 0;                                         % number of frames processed so far
    tt1 = tic;
    for i = 1:numFiles
        name = registered_files{i};
        info = h5info(name);
        dims = info.Datasets.Dataspace.Size;
        ndimsY = length(dims); % number of dimensions (data array might be already reshaped)
        Ts(i) = dims(end);
        Ysub = zeros(FOV(1),FOV(2),floor(Ts(i)/tsub),data_type);
        data.Y(FOV(1),FOV(2),sum(floor(Ts/tsub))) = zeros(1,data_type);
        data.Yr(prod(FOV),sum(floor(Ts/tsub))) = zeros(1,data_type);
        cnt_sub = 0;
        for t = 1:batch_size:Ts(i)
            Y = read_file(name,t,min(batch_size,Ts(i)-t+1));
            F_dark = min(nanmin(Y(:)),F_dark);
            ln = size(Y,ndimsY);
            Y = reshape(Y,[FOV,ln]);
            Y = cast(downsample_data(Y,'time',tsub),data_type);
            ln = size(Y,3);
            Ysub(:,:,cnt_sub+1:cnt_sub+ln) = Y;
            cnt_sub = cnt_sub + ln;
        end
        data.Y(:,:,cnt+1:cnt+cnt_sub) = Ysub;
        data.Yr(:,cnt+1:cnt+cnt_sub) = reshape(Ysub,[],cnt_sub);
        toc(tt1);
        cnt = cnt + cnt_sub;
        data.sizY(1,3) = cnt;
    end
    data.F_dark = F_dark;
    
    
    % now run CNMF on patches on the downsampled file, set parameters first
    % ---------------------------------------------------------------------
    
    %sizY = data.sizY;  % of data matrix

    %     switch xType
    %         case 'invivo'
    %             [options,K,patches,tau,p] = setInVivo(sizY,fr,tsub);
    %         case 'exvivo'
    %             [options,K,patches,tau,p] = setExVivo(sizY,fr,tsub);
    %     end
    
    % Run on patches (the main work is done here)
    [A,b,C,f,~,P,~,YrA] = run_CNMF_patches(data.Y,K,patches,tau,0,options);
    
    % we are operating on downsampled data
    % compute correlation image on a small sample of the data
    % (optional - for visualization purposes)
    Cn = correlation_image_max(data,8);
    
    % classify components
    rval_space = classify_comp_corr(data,A,C,b,f,options);
    ind_corr = rval_space > options.space_thresh;  % components that pass the correlation test
    % this test will keep processes
    % further classification with cnn_classifier
    try  % matlab 2017b or later is needed
        [ind_cnn,~] = cnn_classifier(A,FOV,[dlSave,'cnn_model'],options.cnn_thr,dlSave);
    catch
        ind_cnn = true(size(A,2),1);  % components that pass the CNN classifier
    end
    
    % event exceptionality
    fitness = compute_event_exceptionality(C+YrA,options.N_samples_exc,options.robust_std);
    ind_exc = (fitness < options.min_fitness);
    
    % select components
    keep = (ind_corr | ind_cnn) & ind_exc;
    
    % view contour plots of selected and rejected components (optional)
    throw = ~keep;
    Coor_k = [];
    Coor_t = [];
    if showMe>0
        try
            figure;
            ax1 = subplot(121); plot_contours(A(:,keep),Cn,options,0,[],Coor_k,[],1,find(keep));
            title('Selected components','fontweight','bold','fontsize',14);
            ax2 = subplot(122); plot_contours(A(:,throw),Cn,options,0,[],Coor_t,[],1,find(throw));
            title('Rejected components','fontweight','bold','fontsize',14);
            linkaxes([ax1,ax2],'xy')
        catch
            keyboard
        end
    end
    
    % keep only the active components
    % ---------------------------------------------------------------------
    
    A_keep = A(:,keep);
    C_keep = C(keep,:);
    
    % extract residual signals for each trace
    if exist('YrA','var')
        R_keep = YrA(keep,:);
    else
        R_keep = compute_residuals(data,A_keep,b,C_keep,f);
    end
    
    % extract fluorescence on native temporal resolution
    options.fr = options.fr*tsub;                   % revert to origingal frame rate
    N = size(C_keep,1);                             % total number of components
    T = sum(Ts);                                    % total number of timesteps
    C_full = imresize(C_keep,[N,T]);                % upsample to original frame rate
    R_full = imresize(R_keep,[N,T]);                % upsample to original frame rate
    %F_full = C_full + R_full;                       % full fluorescence
    f_full = imresize(f,[size(f,1),T]);             % upsample temporal background
    %S_full = zeros(N,T);
    
    P.p = 0;
    ind_T = [0;cumsum(Ts(:))];
    options.nb = options.gnb;
    for i = 1:numFiles
        inds = ind_T(i)+1:ind_T(i+1);   % indeces of file i to be updated
        [C_full(:,inds),f_full(:,inds),~,~,R_full(:,inds)] = update_temporal_components_fast(...
            registered_files{i},A_keep,b,C_full(:,inds),f_full(:,inds),P,options);
        disp(['Extracting raw fluorescence at native frame rate. File ',num2str(i),' out of ',...
            num2str(numFiles),' finished processing.'])
    end
    
    % extract DF/F and deconvolve DF/F traces
    [F_dff,F0] = detrend_df_f(A_keep,[b,ones(prod(FOV),1)],C_full,...
        [f_full;-double(F_dark)*ones(1,T)],R_full,options);
    
    C_dec = zeros(N,T);         % deconvolved DF/F traces
    S_dec = zeros(N,T);         % deconvolved neural activity
    bl = zeros(N,1);            % baseline for each trace (should be close to zero since traces are DF/F)
    neuron_sn = zeros(N,1);     % noise level at each trace
    g = cell(N,1);              % discrete time constants for each trace
    if p == 1
        model_ar = 'ar1';
    elseif p == 2
        model_ar = 'ar2';
    else
        error('This order of dynamics is not supported');
    end
    
    for i = 1:N
        spkmin = options.spk_SNR*GetSn(F_dff(i,:));
        lam = choose_lambda(exp(-1/(options.fr*options.decay_time)),GetSn(F_dff(i,:)),options.lam_pr);
        [cc,spk,opts_oasis] = deconvolveCa(F_dff(i,:),model_ar,...
            'method','thresholded','optimize_pars',true,'maxIter',20,...
            'window',150,'lambda',lam,'smin',spkmin);
        bl(i) = opts_oasis.b;
        C_dec(i,:) = cc(:)' + bl(i);
        S_dec(i,:) = spk(:);
        neuron_sn(i) = opts_oasis.sn;
        g{i} = opts_oasis.pars(:)';
        disp(['Performing deconvolution. Trace ',num2str(i),' out of ',num2str(N),' finished processing.'])
    end
        
    % output
    % ---------------------------------------------------------------------
    res = save4CalmAn(A_keep,Cn,F_dff,F0,C_dec,S_dec,options);
    
    try
        rmdir(foldername,'s');
    catch
    end
    
end















