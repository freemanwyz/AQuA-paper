% generate simulation data for ex vivo data
% events on each 2D components independently

pRes = 'D:\OneDrive\projects\glia_kira\results\sim_se_ex\';
pDat = 'D:\OneDrive\projects\glia_kira\raw\TTXDataSetRegistered_32Bit\';
f0 = 'FilteredNRMCCyto16m_slice3_Baseline3_L2 3-015cycle1channel1';
tmp = load([pRes,f0,'.mat']); res = tmp.res;

dat = readTiffSeq([pDat,f0,'.tif']);
gapx = res.opts.regMaskGap;
dat = dat(gapx+1:end-gapx,gapx+1:end-gapx,:);
dat = dat/max(dat(:));
dat = sqrt(dat);
p = sim1.extractSe(dat,res.seLst);
p = sim1.simParamEx(p);


%% generate events
% sName = 'ex_domain_1';
sName = 'ex_domain_largesize_oneseed_fixed_nospasmo_samedf';

p0 = p;
p0.useDomain = 1;
p0.nSe = 2000;
% p0.xRate = 2;
p0.seDensity = 3;
p0.nDomain = 30;
p0.domainType = 'large';
p0.fixed = 0;
p0.unifBri = 2;
p0.seedMinDist = 500;
p0.noProp = 0;
p0.ignoreFilterSpa = 1;
p0.smoXY = 1;
p0.ignoreFilterTemp = 0;
p0.minPropSz = 400;
p0.valMin = 0.05;

if p0.useDomain>0
    [dmMap,dmSeIdx] = sim1.genDomains(p0);
    [datSim,evtLst,evtLstCore,seSim] = sim1.genExDomainBased(p0,dmMap,dmSeIdx);
else
    [datSim,evtLst,evtLstCore,seSim] = sim1.genEx(p0);
end

dAvg = mean(dat,3);

%% save
datSim = uint16(datSim*65535);
pOut = 'D:\OneDrive\projects\glia_kira\se_aqua\simDat\';
t0 = datestr(datetime(),'yyyymmddHHMM');
f1 = [sName,'_',t0,'.mat'];
save([pOut,f1],'datSim','evtLst','evtLstCore','seSim','dAvg','p0');

if 0  % plot results
    zzshow(regionMapWithData(dmMap));
    zzshow(regionMapWithData(evtLst,zeros(size(datSim))))
end









