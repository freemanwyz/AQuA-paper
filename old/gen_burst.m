% generate burst patterns
% addpath('C:\Users\Eric\Dropbox\code\wyz_3rd\foiVBM4D\');

preset = 1;
pDat = 'D:\neuro_WORK\glia_kira\raw\Mar14_InVivoDataSet\';
f0 = '2826451(4)_1_2_4x_reg_200um_dualwv-001.tif';

opts = util.parseParam(preset,0);
opts.usePG = 0;
[datOrg,opts] = burst.prep1(pDat,f0,[],opts);

% burst and non-burst frames
trgBg = 1201:1300;
trgBurst = 1431:1470;
dAvg = mean(datOrg(:,:,trgBg),3);
dBurst = datOrg(:,:,trgBurst);
fg = std(dBurst,0,3)>0.05;

%% events
p = [];
p.nEvt = 250;
p.nStart = 80;
p.nStp = 500;
p.cRiseMin = 30;
p.seedRtAdd = 0.2;
p.seedRtMul = 0.5;
p.seedMinDist = 10;
p.speedUpProp = 0.5;
p.pertMax = 20;
p.nStpGrow = 500;
p.sz = size(fg);
p.szRt = 1;
p.fg = fg;

% nEvt = 150; seedRtMul = 0.5; seedMinDist = 10;
% nEvt = 250; seedRtMul = 0.25; seedMinDist = 4;

datSim = sim.genOneBurst(dAvg,dBurst,p);

datSimNy = datSim*0.4 + dAvg + randn(size(datSim))*0.05;
zzshow(datSimNy)

%%
io.writeTiffSeq('d:\invivo_reg_200um_1x.tiff',dBurst*1.5,8);
io.writeTiffSeq('d:\invivo_reg_200um_1x_sim.tiff',datSimNy,8);



