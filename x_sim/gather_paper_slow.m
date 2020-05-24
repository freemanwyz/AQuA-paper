% analyze the simulation results for un-fixed ROI
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

doNotReCal = 1;  % use results from data, do not re-calculate

sessTop = 'event_20181023';
postx = '';
% postx = '_unfixed';
% postx = '_prop';
synDatNameLst = {'nonroi-szChg','nonroi-locChg','prop-grow-speedChg',...
    'prop-move-speedChg','prop-mixed-speedChg'};
% synDatNameLst = {'prop-grow-speedChg','prop-move-speedChg','prop-mixed-speedChg'};
% synDatNameLst = {'nonroi-szChg','nonroi-locChg'};

synDatFolder = 'D:\OneDrive\projects\glia_kira\se_aqua\simDat\';
simResFolder = 'D:\OneDrive\projects\glia_kira\se_aqua\sim\';
outcomeFolder = 'D:\OneDrive\projects\glia_kira\se_aqua\outcome\';

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
        gtLst = cell(1,size(xx.datLst,2));
        if doNotReCal==0
            for jj=1:size(xx.datLst,2)
                xx1 = [];
                xx1.datSim = xx.datLst{ii,jj};
                xx1.evtLst = xx.evtLst{ii,jj};
                d0 = xx1.datSim;
                xx1.datSim = cat(3,d0,zeros(size(d0,1),size(d0,2),100,'uint16'));
                gt = sim1.anaGt(xx1);
                p0 = xx.p0;
                gt.paramAll = p0.stdVec;
                gtLst{jj} = gt;
            end
        else
            xx1 = [];
            xx1.datSim = xx.datLst{ii,1};
            xx1.evtLst = xx.evtLst{ii,1};
            d0 = xx1.datSim;
            xx1.datSim = cat(3,d0,zeros(size(d0,1),size(d0,2),100,'uint16'));
            gt = sim1.anaGt(xx1);
            p0 = xx.p0;
            gt.paramAll = p0.stdVec;
            for jj=1:size(xx.datLst,2)
                gtLst{jj} = gt;
            end
        end
        gtTb = [gtTb;{s0,ii,p0.stdVec(ii),{gtLst}}]; %#ok<AGROW>
    end
end


%% analyze each simulation result file
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
    gt0 = gt0{1};
    param0 = gtTb.param(gtSel);
    dt0 = load([simResFolder,sessTop,filesep,r0]);
    snr0 = round(20*log10(gt0{1}.sigMean./dt0.nStdVec)*10)/10;
    if doNotReCal==0 && isfield(dt0,'resx')
        [ivox,ipix] = sim1.anaIoU(dt0.resx,gt0);
    else
        if iscell(dt0.iouVol)
            ivox = [mean(dt0.iouVol{1},2),2*std(dt0.iouVol{1},0,2)];
            ipix = [mean(dt0.iouVol{2},2),2*std(dt0.iouVol{2},0,2)];
        else
            ivox = [mean(dt0.iouVol,2),2*std(dt0.iouVol,0,2)];
            ipix = ivox;
        end
    end
    lst0 = cell(numel(snr0),1);
    for ii=1:numel(snr0)
        u0 = {file0,exp0,param0,test0,mthd0,snr0(ii),...
            ivox(ii,1),ivox(ii,2),ipix(ii,1),ipix(ii,2)};
        lst0{ii} = u0;
    end
    xLst{nn} = lst0;
end


%%
dtTb = cell2table(cell(0,10),'VariableNames',{'file','exp','param',...
    'test','mthd','snr','voxIou','voxIouCi','pixIou','pixIouCi'});
for nn=1:numel(xLst)
    lst0 = xLst{nn};
    if ~isempty(lst0)
        for mm=1:numel(lst0)
            dtTb = [dtTb;lst0{mm}];
        end
    end
end

writetable(dtTb,[outcomeFolder,filesep,sessTop,'_summary',postx,'.csv']);
% writetable(gtTb(:,1:end-1),[outcomeFolder,filesep,sessTop,'_summary.csv']);






