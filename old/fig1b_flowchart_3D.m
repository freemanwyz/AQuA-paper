% read data and results
[dat,res] = loadRes('aqua',1);

% crop data to show
tVec = 120:5:175; tVecZoomIn = 170:174;
hrg = 191:380; wrg = 181:370;

%% draw
% raw
fRaw = pltFlow.raw(dat,hrg,wrg,tVec);

% foreground
fFg = pltFlow.foreground(dat,hrg,wrg,tVec,res);

% seeds
fSeed = pltFlow.seedWithFg(dat,hrg,wrg,tVec,res);

% curves
h = [245,329,274]; w = [245,266,212]; t = [166,177,127];
fSeedCurve = pltFlow.svCurves(dat.^2,h,w,t);

% super voxels
fSv = pltFlow.superVoxel(dat,hrg,wrg,tVec,res);

% super voxels, temporal zoom in
fSv1 = pltFlow.superVoxel(dat,hrg,wrg,tVecZoomIn,res);

% super events
fSe = pltFlow.superEvent(dat,hrg,wrg,tVec,res);

% rising map
xLoc = [242,246,165];
[fRiseSv,fRiseSe,fRiseSeLm,fRiseEvt] = pltFlow.risingMap(res,xLoc);

% events
fEvt = pltFlow.event(dat,hrg,wrg,tVec,res);


%% export
addpath('../../toolbox/plots/altmany-export_fig/')
export_fig(fRaw,'fig1b_raw.png');
export_fig(fFg,'fig1b_fg.png');
export_fig(fSeed,'fig1b_seed.png');
export_fig(fSeedCurve,'fig1b_seedCurve.pdf');
export_fig(fSeedCurve,'fig1b_seedCurve.png');
export_fig(fSv,'fig1b_sv.png');
export_fig(fSv1,'fig1b_sv1.png');
export_fig(fSe,'fig1b_se.png');

export_fig(fRiseSv,'fig1b_rise_sv.png');
export_fig(fRiseSe,'fig1b_rise_se.png');
export_fig(fRiseSeLm,'fig1b_rise_se_lm.png');
export_fig(fRiseEvt,'fig1b_rise_evt.png');

export_fig(fEvt,'fig1b_evt.png');













