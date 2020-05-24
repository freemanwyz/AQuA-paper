% gather the simulation results for un-fixed ROI
%
% do not re-calculate results
%
% exps (in synthetic data): xx.p0.stdVec
% noise levels (in simulation results): xx.nStdVec
% format of results files:  test__method__file__exp-k.mat
%
% session: top level location, an aspect of event detection
% files: synthetic data sets to study that aspect of detection
% exps: synthetic data settings in each synthetic file
% tests: differet tests to understand that aspect
% methods: AQuA and peer methods
% noises: SNR performance
% repeats: for CI calculation

sessTop = 'event_20181023';
synDatNameLst = {'nonroi-szChg','nonroi-locChg','prop-grow-speedChg',...
    'prop-move-speedChg','prop-mixed-speedChg'};
fp = getWorkPath();

synDatFolder = [fp,'simDat/'];
simResFolder = [fp,'sim/'];
outcomeFolder = [fp,'outcome/'];

% simulation results files
pOut = [simResFolder,filesep,sessTop,filesep];
f00 = dir([pOut,'*.mat']);
simResFileLst = cell(0);
kk = 1;
for s0 = synDatNameLst
    for ii=1:numel(f00)
        if ~isempty(strfind(f00(ii).name,s0))
            simResFileLst{kk,1} = f00(ii).name;
            kk = kk+1;
        end
    end
end

%% gather ground truth
gtTb = cell2table(cell(0,4),'VariableNames',{'file','exp','param','gt'});
for nn = 1:numel(synDatNameLst)
    s0 = synDatNameLst{nn};
    xx = load([synDatFolder,sessTop,filesep,s0,'.mat']);
    for ii=1:size(xx.datLst,1)
        fprintf('Add exp %d in %s\n',ii,s0)        
        xx1 = [];
        xx1.datSim = xx.datLst{ii,1};
        xx1.evtLst = xx.evtLst{ii,1};
        d0 = xx1.datSim;
        xx1.datSim = cat(3,d0,zeros(size(d0,1),size(d0,2),100,'uint16'));
        gt = sim1.anaGt(xx1);
        p0 = xx.p0;
        gt.paramAll = p0.stdVec;
        gtTb = [gtTb;{s0,ii,p0.stdVec(ii),{gt}}]; %#ok<AGROW>
    end
end


%% gather each simulation result file
xLst = cell(numel(simResFileLst),1);

for nn=1:numel(simResFileLst)
    r0 = simResFileLst{nn};
    fprintf('%s\n',r0)
    c0 = strsplit(r0,'.');
    c1 = strsplit(c0{1},'_');
    test0 = c1{1};
    mthd0 = c1{2};
    file0 = c1{3};
    c1a = strsplit(c1{4},'-');
    exp0 = str2double(c1a{2});
    gtSel = strcmp(gtTb.file,file0) & gtTb.exp==exp0;
    gt0 = gtTb.gt(gtSel);
    param0 = gtTb.param(gtSel);
    
    dt0 = load([simResFolder,sessTop,filesep,r0]);
    snr0 = round(20*log10(gt0{1}.sigMean./dt0.nStdVec)*10)/10;
    
    ivox = dt0.iouVol{1};
    ipix = dt0.iouVol{2};
    
    lst0 = cell(numel(snr0),1);
    for ii=1:numel(snr0)
        u0 = {file0,exp0,param0,test0,mthd0,snr0(ii),...
            ivox(ii,:),ipix(ii,:),mean(ivox(ii,:)),mean(ipix(ii,:))};
        lst0{ii} = u0;
    end
    xLst{nn} = lst0;
end


%% output
dtTb = cell2table(cell(0,10),'VariableNames',{'file','exp','param',...
    'test','mthd','snr','voxIou','pixIou','voxIouMean','pixIouMean'});
for nn=1:numel(xLst)
    lst0 = xLst{nn};
    if ~isempty(lst0)
        for mm=1:numel(lst0)
            dtTb = [dtTb;lst0{mm}]; %#ok<AGROW>
        end
    end
end

%% p-values
snr0 = [-0.1, 2.4, 4.9, 7.4, 9.9, 14.9, 19.9];

% size change
pVec_sz = get_pval(dtTb,'sz-snr10','nonroi-szChg',1:5,0);
pVec_sz_snr = get_pval(dtTb,'sz5-snr','nonroi-szChg',snr0,1);

% location change
pVec_loc = get_pval(dtTb,'loc-snr10','nonroi-locChg',1:5,0);
pVec_loc_snr = get_pval(dtTb,'loc5-snr','nonroi-locChg',snr0,1);

% growing propagation
pVec_grow = get_pval(dtTb,'speed-snr10','prop-grow-speedChg',1:5,0);
pVec_grow_snr = get_pval(dtTb,'speed5-snr','prop-grow-speedChg',snr0,1);

% moving propagation
pVec_move = get_pval(dtTb,'speed-snr10','prop-move-speedChg',1:5,0);
pVec_move_snr = get_pval(dtTb,'speed5-snr','prop-move-speedChg',snr0,1);

% mixed propagation
pVec_mixed = get_pval(dtTb,'speed-snr10','prop-mixed-speedChg',1:5,0);
pVec_mixed_snr = get_pval(dtTb,'speed5-snr','prop-mixed-speedChg',snr0,1);






















