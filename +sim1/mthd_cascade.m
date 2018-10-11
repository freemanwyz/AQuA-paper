function mthd_cascade(xx)
    
    % tmp = load('./mthds/cascade/svmmodel_ex_vivo_sim.mat');
    % md = tmp.svmModelLst;
    
    addpath('../../repo/cascade/');
    
    p = [];
    p.foffset = 0; % how many initial frames to exclude in analysis
    p.norm_signal = 'std'; % ('std','bkg','sub') % different way to normalize intenisty
    p.spf = 1 ; % frame rate at acquisition
    
    % event detection
    p.min_peak_dist_ed = 3;  % 2
    p.min_peak_length = 3;  % 1
    p.hb=21; % 21. high bound size for in-x,y dim
    p.zlb=1; % low bound size for in-z(t) dim
    p.zhb=21; % 21. high bound size for in-z(t) dim
    
    % background trending correction
    p.int_correct= 0; % if 1, correct bkg, if 0, no correction.
    
    % processing
    resx = cell(0,xx.nRep);
    iouxxCas = zeros(numel(xx.nStdVec),xx.nRep);
    iouxxCas2D = zeros(numel(xx.nStdVec),xx.nRep);
    xx.HW = size(xx.dAvg,1)*size(xx.dAvg,2);
    kk=1; ii=1; %#ok<NASGU>
    
    for kk=1:xx.nRep
        for ii=1:numel(xx.nStdVec)
            fprintf('Cascade std %d ==================\n',xx.nStdVec(ii));
            datSimNy = xx.datSim*2 + xx.dAvg*xx.bgRt + randn(xx.sz)*xx.nStdVec(ii) + 0.2;
            
            zThrPk = min(xx.sigxU/xx.nStdVec(ii),10);
            p.lb=xx.nStdVec(ii)*3; % low bound size for in-x,y dim
            %p.peak_int_ed = 10;
            p.min_int_ed = min(1,zThrPk*0.5);
            p.peak_int_ed = zThrPk; % minimum peak intesnity value for being considered as signal
            %p.min_int_ed = zThrPk*0.2; % minimum intenisty value for start-end of a event
            
            res0 = Cal_anl_main2sa_forreview_x(datSimNy,p);
            
            % peak detector from Cascade
            res0.pixLst = vox2pix(res0.evt,xx.sz);
            resx{ii,kk} = res0;
            [iouVoxD2G,iouPixD2G] = sim1.IoU(res0.evt,res0.pixLst,xx.evtLst,xx.pixLst,xx.sz);
            [iouVoxG2D,iouPixG2D] = sim1.IoU(xx.evtLst,xx.pixLst,res0.evt,res0.pixLst,xx.sz);
            iouxxCas(ii,kk) = (nanmean(iouVoxD2G)+nanmean(iouVoxG2D))/2;
            iouxxCas2D(ii,kk) = (nanmean(iouPixD2G)+nanmean(iouPixG2D))/2;
            csvwrite(['./tmp/cascade_',xx.f0,'_vox.csv'],iouxxCas);
            csvwrite(['./tmp/cascade_',xx.f0,'_pix.csv'],iouxxCas2D);
            close all
            
            %     % classfication with SVM
            %     for jj=2:4
            %         md0 = md{ii,jj-1};
            %         lb0 = md0.predict(res0.testdata);
            %         fprintf('%d\n',sum(lb0));
            %         res0a = res0;
            %         res0a.svm1_pk_class = lb0;
            %         resx{ii,jj} = res0a;
            %     end
        end
    end
    
    if xx.saveMe>0
        iouVol = iouxxCas; nStdVec = xx.nStdVec; f0 = xx.f0; %#ok<NASGU>
        save([xx.pOut,'res_cascade_',xx.f0,'_',xx.t0,'.mat'],'resx','nStdVec','iouVol','f0','-v7.3');
    end
    
end


