addpath('../../repo/cascade/');

pRes = 'D:\OneDrive\projects\glia_kira\results\sim_se_ex\';
pDat = 'D:\OneDrive\projects\glia_kira\raw\TTXDataSetRegistered_32Bit\';
f0 = 'FilteredNRMCCyto16m_slice3_Baseline3_L2 3-015cycle1channel1';
tmp = load([pRes,f0,'.mat']); res = tmp.res;
[datSim,evtLst,~,~,dAvg] = genExTop(pDat,f0,res);

%% parameters
% same with simulation

nStdVec = 10.^(-2:0.2:-1);
bgRt = 1.5;

% basic analysis criteria setting
p = [];
p.foffset = 0; % how many initial frames to exclude in analysis
p.norm_signal = 'std'; % ('std','bkg','sub') % different way to normalize intenisty
p.spf = 1 ; % frame rate at acquisition

% event detection
p.min_int_ed = 0.5; % minimum intenisty value for start-end of a event;
p.peak_int_ed = 2; % minimum peak intesnity value for being considered as signal
p.min_peak_dist_ed = 2;
p.min_peak_length = 1;

% background trending correction
p.int_correct= 0; % if 1, correct bkg, if 0, no correction.

%% detection and training
svmModelLst = cell(numel(nStdVec),3);
datx = datSim;
datx(datx<0.01) = 0;
datxVec = reshape(datx,[],size(datx,3));
[H,W,T] = size(datSim);
for ii=1:numel(nStdVec)
    datSimNy = datSim*2 + dAvg*bgRt + randn(size(datSim))*nStdVec(ii);    
    res0 = Cal_anl_main2sa_forreview_x(datSimNy,p);
    
    testData = res0.testdata;
    
    evt0 = res0.evt;
    lblPix = zeros(numel(evt0),1);
    lblMin = lblPix;
    lblVox = lblPix;
    for jj=1:numel(evt0)
        evt00 = evt0{jj};       
        
        % spatial overlapping
        [ih,iw,it] = ind2sub([H,W,T],evt00);
        ihw = unique(sub2ind([H,W],ih,iw));
        ss = datxVec(ihw,min(it):max(it));
        ss1 = sum(ss>0,2);        
        if sum(ss1>0)>numel(ss1)*0.5
            lblPix(jj) = 1;
        end
        
        % any overlapping
        ss = datSim(evt0{jj});
        if sum(ss>0)>4
            lblMin(jj) = 1;
        end        

        % volumn overlapping
        ss = datSim(evt0{jj});
        if sum(ss>0)>numel(ss)*0.5
            lblVox(jj) = 1;
        end        
    end
    
    % SVM
    c = cvpartition(numel(evt0),'KFold',10);
    opts = struct('Optimizer','bayesopt','ShowPlots',false,'CVPartition',c,...
        'AcquisitionFunctionName','expected-improvement-plus');
    
    svmmod = fitcsvm(testData,lblPix,'KernelFunction','rbf',...
        'OptimizeHyperparameters','auto','HyperparameterOptimizationOptions',opts);
    svmModelLst{ii,1} = svmmod;
    
    svmmod = fitcsvm(testData,lblMin,'KernelFunction','rbf',...
        'OptimizeHyperparameters','auto','HyperparameterOptimizationOptions',opts);
    svmModelLst{ii,2} = svmmod;
    
    svmmod = fitcsvm(testData,lblVox,'KernelFunction','rbf',...
        'OptimizeHyperparameters','auto','HyperparameterOptimizationOptions',opts);
    svmModelLst{ii,3} = svmmod;
    
end

save('svmmodel_ex_vivo_sim.mat','svmModelLst','opts','p','nStdVec')









