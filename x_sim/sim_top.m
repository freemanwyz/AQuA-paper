% run simulation
addpath(genpath('../../repo/aqua/'));

pIn = 'D:\OneDrive\projects\glia_kira\se_aqua\simDat\';
pOut = 'D:\OneDrive\projects\glia_kira\se_aqua\sim\';
f0 = 'ex_domain_largesize_oneseed_fixed_nospasmo_samedf_201809180001';
% f0 = 'ex_domain_avgsize_fixed_noprop_nosmo_samedf_20180912_222204';
% f0 = 'ex_domain_avgsize_fixed_noprop_notempsmo_samedf_20180913_112045';

xType = 'exvivo';

xx = load([pIn,f0,'.mat']);
datSim = xx.datSim;

% pad data for GECI-quant grouping
d = mod(size(datSim,3),10);
if d>0
    datSim = cat(3,datSim,zeros(size(datSim,1),size(datSim,2),10-d,'uint16'));
end

javaclasspath('-v1')
javaclasspath('..\..\repo\gfptoolbox\tools\FASP\out\production\FASP\')

% enough zero for baseline and noise
datSim = cat(3,datSim,zeros(size(datSim,1),size(datSim,2),50,'uint16'));
xx.datSim = datSim;
dAvg = xx.dAvg;

datSim = single(datSim)/65535;

% radius for Suite2P
evtMap = zeros(size(datSim));
evtRad = nan(numel(xx.evtLst),1);
for nn=1:numel(xx.evtLst)
    evt0 = xx.evtLst{nn};
    evtMap(evt0) = nn;
    [ih,iw,it] = ind2sub(size(datSim),evt0);
    dh = max(ih)-min(ih);
    dw = max(iw)-min(iw);
    r = max(dh,dw)/2;
    evtRad(nn) = r*1.4;
    %ihw = unique(sub2ind(size(dAvg),iw));
    %evtRad(nn) = sqrt(numel(ihw)/2/pi);
end

global dbg
dbg = load([pIn,f0,'.mat']);
dbg.evtMap = evtMap;
% dbg.datSim = datSim;

% datSimNy = datSim + dAvg*1.5 + randn(size(datSim))*0.05;
% writeTiffSeq([pOut,f0,'_0.05.tif'],datSimNy*2);

% nStdVec = 0.01;
nStdVec = [0.01,0.1];
% nStdVec = 10.^(-2:0.2:-1);
% nStdVec = 10.^(-2:1:-1);
bgRt = 0.5;
zThr = 4;
HW = size(dAvg,1)*size(dAvg,2);


%% AQuA
% -------------------------------------------------------------------------

% thr 2 for smo 0.5, thr 3 for smo 1
resx = cell(0,1);
iouxx = zeros(numel(nStdVec),2);
for ii=1:numel(nStdVec)
    fprintf('Aqua Std %d ==================\n',nStdVec(ii));
    datSimNy = datSim + dAvg*bgRt + randn(size(datSim))*nStdVec(ii)+0.2;
    
    opts = util.parseParam(2,0,'parameters1.csv');
    opts.regMaskGap = 0;
    opts.usePG = 0;
    opts.cRise = 0.5;  % 1.5
    opts.cDelay = 1.5;  % 1.5
    opts.cOver = 0;
    opts.minShow1 = 0.1;  % 0.2
    
    %opts.smoXY = 0;
    %opts.smoXY = 0.5;  % 0.5, 1
    opts.smoXY = 0.5+max(nStdVec(ii)-0.01,0)*5;  % default    
    opts.minSize = round(8+opts.smoXY*8);
    %opts.minSize = 8;  % 8
    
    opts.thrARScl = 3;
    opts.thrExtZ = 2;
    opts.gtwSmo = 2;
    res0 = aqua_top(datSimNy,opts);
    %res0 = aquaThr(datSimNy,res0,opts);
    res0.evtBak = res0.evt;
    res0.evt = refineEvts(datSimNy,res0.evt,2*ceil(2*opts.smoXY)+1);
    
    resx{ii,1} = res0;
    %zzshow(regionMapWithData(xx.evtLst,zeros(size(datSim))),'evt,gt')
    %zzshow(regionMapWithData(res0.evt,zeros(size(datSim))),'evt,refine,all')
    %zzshow(regionMapWithData(res0.evtBak,zeros(size(datSim))),'evt,org')

    [iouDt2Gt,evtMapGt] = sim1.IoU3D(res0.evt,xx.evtLst,size(datSim));
    [iouGt2Dt,evtMapDt] = sim1.IoU3D(xx.evtLst,res0.evt,size(datSim));
    
    [iouDt2Gt0,evtMapGt0] = sim1.IoU3D(res0.evtBak,xx.evtLst,size(datSim));
    [iouGt2Dt0,evtMapDt0] = sim1.IoU3D(xx.evtLst,res0.evtBak,size(datSim));
    
    iouxx(ii,1) = (nanmean(iouDt2Gt)+nanmean(iouGt2Dt))/2;
    iouxx(ii,2) = (nanmean(iouDt2Gt0)+nanmean(iouGt2Dt0))/2;
end

% t0 = datestr(datetime(),'yyyymmdd_HHMMSS');
% save([pOut,'res_aqua_',f0,'_',t0,'.mat'],'resx','nStdVec','f0','-v7.3');
% close all

xSig = mean(datSim(datSim>0)); snr = 20*log10(xSig./nStdVec);
figure;plot(snr,iouxx,'-o','LineWidth',2);set(gca,'FontSize',18);
xlabel('SNR (dB)');ylabel('IoU');ylim([0.5,1]); legend('Refined','Original')

% ix = find(iouGt2Dt<0.9); xSel = xx.evtLst(ix); zzshow(lst2map(xSel,size(datSim)));

%% Calman
% -------------------------------------------------------------------------

resx = cell(0);
for ii=1:numel(nStdVec)
    fprintf('Calman Std %d ==================\n',nStdVec(ii));
    datSimNy = datSim + dAvg*bgRt + randn(size(datSim))*nStdVec(ii);
    res0 = calman_top(datSimNy,xType);
    [res0.evt,res0.z] = sim1.roi2evt(res0.dff,res0.roiLst,HW,zThr);
    resx{ii,1} = res0;
    rmdir([tempdir,'calman'],'s');
end
t0 = datestr(datetime(),'yyyymmdd_HHMMSS');
save([pOut,'res_calman_',f0,'_',t0,'.mat'],'resx','nStdVec','f0','-v7.3');
close all

%% Cascade
% -------------------------------------------------------------------------

tmp = load('./mthds/cascade/svmmodel_ex_vivo_sim.mat');
md = tmp.svmModelLst;

addpath('../../repo/cascade/');
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

% processing
resx = cell(0,4);  % No SVM and SVM trained by three ways
HW = size(dAvg,1)*size(dAvg,2);
for ii=1:numel(nStdVec)
    fprintf('Cascade std %d ==================\n',nStdVec(ii));
    datSimNy = datSim*2 + dAvg*bgRt + randn(size(datSim))*nStdVec(ii);
    res0 = Cal_anl_main2sa_forreview_x(datSimNy,p);
    resx{ii,1} = res0;
    
    % classfication with SVM
    for jj=2:4
        md0 = md{ii,jj-1};
        lb0 = md0.predict(res0.testdata);
        fprintf('%d\n',sum(lb0));
        res0a = res0;
        res0a.svm1_pk_class = lb0;
        resx{ii,jj} = res0a;
    end
end

t0 = datestr(datetime(),'yyyymmdd_HHMMSS');
save([pOut,'res_cascade_',f0,'_',t0,'.mat'],'resx','nStdVec','f0','-v7.3');
close all

%% Suite2P
% -------------------------------------------------------------------------

% file is put to RootStorage/xx/xx/file_name.tif
% folderPrj = tempdir;
db.diameter = mean(evtRad);
resx = cell(0);
for ii=1:numel(nStdVec)
    fprintf('Suite2P Std %d ==================\n',nStdVec(ii));
    datSimNy = datSim + dAvg*bgRt + randn(size(datSim))*nStdVec(ii);
    res0 = suite2p_wyz(datSimNy,db);
    [res0.evt,res0.z] = sim1.roi2evt(res0.dff,res0.roiLst,HW,zThr);
    resx{ii,1} = res0;
    rmdir([tempdir,'suite2p'],'s');
end
t0 = datestr(datetime(),'yyyymmdd_HHMMSS');
save([pOut,'res_suite2p_',f0,'_',t0,'.mat'],'resx','nStdVec','f0','-v7.3');
close all

%% GECI-quant
% -------------------------------------------------------------------------

thrSz = 1000;  % pixels count for large and small domains

resx = cell(0);
for ii=1:numel(nStdVec)
    fprintf('GECI Std %d ==================\n',nStdVec(ii));
    datSimNy = datSim + dAvg*bgRt + randn(size(datSim))*nStdVec(ii);
    res0 = geci_pipe(datSimNy,thrSz);  % run GECI-quant
    [res0.evt,res0.z] = sim1.roi2evt(res0.dff,res0.roiLst,HW,zThr);
    resx{ii,1} = res0;
    rmdir([tempdir,'geci'],'s');
end
t0 = datestr(datetime(),'yyyymmdd_HHMMSS');
save([pOut,'res_geci_',f0,'_',t0,'.mat'],'resx','nStdVec','f0','-v7.3');
close all






