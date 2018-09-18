% generate simulation data for ex vivo data
% events on each 2D components independently
% 

pDat = 'D:\OneDrive\projects\glia_kira\raw\TTXDataSetRegistered_32Bit\';
f0 = 'FilteredNRMCCyto16m_slice3_Baseline3_L2 3-015cycle1channel1.tif';

dat = io.readTiffSeq([pDat,filesep,f0]);
dat = dat/max(dat(:));
p = sim.prepareExVivo(dat);

% big events
p0 = p;
p0.nSe = 20;
p0.numEvtInBurst = 24;
p0.seedMinDist = 15;
p0.seedRtMul = 0.4;
datBig = sim.genBigEx(p0,0);

% small events
p1 = p;
p1.szRt = 0.1;
p1.numEvtInBurst = 3;
p1.nStpGrow = 10;
p1.seedRtAdd = 0.75;
datSmall = sim.genSmall(p1,datBig>0,0);

% output
datSim = datBig;
% datSim = datBig + datSmall;
datSimNy = datSim + p.dAvg*3 + randn(size(datSim))*0.02;
zzshow(datSimNy*2)

io.writeTiffSeq('d:\exvivo_015_more.tiff',datSimNy*4,8);





