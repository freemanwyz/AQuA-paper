% generate simulation data for ex vivo data
% based on super events detection results for 2D regions and locations

pRes = 'D:\OneDrive\projects\glia_kira\results\sim_se_ex\';
pDat = 'D:\OneDrive\projects\glia_kira\raw\TTXDataSetRegistered_32Bit\';
f0 = 'FilteredNRMCCyto16m_slice3_Baseline3_L2 3-015cycle1channel1';
tmp = load([pRes,f0,'.mat']); res = tmp.res;

dat = readTiffSeq([pDat,f0,'.tif']);
gapx = res.opts.regMaskGap;
dat = dat(gapx+1:end-gapx,gapx+1:end-gapx,:);
dat = dat/max(dat(:));
dat = sqrt(dat);
dAvg = mean(dat,3);
p = sim1.extractSe(dat,res.seLst);
p = sim1.simParamEx(p);


%% generate events
% Default parameters in this session:
p0 = p;
rng(88);
sType = 4;  % 0,1,2,4
switch sType
    case -1  % ROI (debug)
        sName = 'dbg-roi_smo-t_freq-low';
        p0.mthd = 'roi_dbg';
    case 0  % ROI
        sName = 'ex-roi_area-avg-min-100_smo-st';
        p0.domainType = 'average';
        p0.nDomain = 100;
        p0.minArea = 100;
        p0.noProp = 1;
        p0.fixed = 1;
        p0.seedMinDist = 1e8;
        p0.minPropSz = 1e8;
    case 1  % Evt
        sName = 'ex-evt_area-big-min-100_smo-st';
        p0.mthd = 'event';
        p0.minArea = 100;
        p0.noProp = 1;
        p0.seedMinDist = 1e8;
        p0.minPropSz = 1e8;
    case 2  % ROI + prop
        sName = 'ex-roi_area-big-min-100_prop-min-500-gap-100_smo-st';
        p0.domainType = 'large';
        p0.nDomain = 100;
        p0.minArea = 100;
        p0.seedMinDist = 100;
    case 3  % ROI + prop + spk (test)
        sName = 'ex-roi-spk_area-big-min-100_prop-min-500-gap-100_smo-st';
        p0.domainType = 'large';
        p0.nDomain = 100;
        p0.minArea = 100;
        p0.seedMinDist = 100;
        p0.useSpk = 1;
        p0.sparklingSz = [16,36];
        p0.sparklingDensity = 1;
    case 4  % Evt + prop
        sName = 'ex-evt_area-big-min-100_prop-min-500-gap-100_smo-st';
        p0.mthd = 'event';
        p0.minArea = 100;
        p0.seedMinDist = 100;
end

evtLstDomain = [];
seSim = [];
dmMap = [];
switch p0.mthd
    case 'domain'
        [dmMap,dmSeIdx] = sim1.genDomains(p0);
        [datSim,evtLst,evtLstDomain,seSim] = sim1.genExDomainBased(p0,dmMap,dmSeIdx);
    case 'event'
        [datSim,evtLst,~,seSim] = sim1.genExEventBased(p0);
    case 'roi_dbg'
        [datSim,evtLst,dmMap] = sim1.roi_dbg(p0);
end


%% save
datSim = uint16(datSim*65535);
pOut = 'D:\OneDrive\projects\glia_kira\se_aqua\simDat\';
t0 = datestr(datetime(),'yyyymmddHHMM');
f1 = [sName,'_',t0,'.mat'];
save([pOut,f1],'datSim','evtLst','dmMap','evtLstDomain','seSim','dAvg','p0');

if 0  % plot results
    zzshow(regionMapWithData(dmMap));
    zzshow(regionMapWithData(evtLst,zeros(size(datSim))))
end









