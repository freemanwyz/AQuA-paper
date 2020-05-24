%% setup
pTop = getWorkPath('proj');

addpath(genpath([pTop,'/repo-yu-lab-vt/AQuA']));

% -- preset 1: in vivo. 2: ex vivo. 3: GluSnFR
preset = 1;
p0 = [pTop,'/tmp/mehmet/'];
f0 = 'test.tif';

opts = util.parseParam(preset,0,'parameters1.csv');

opts.spSz = 25;  % 9
opts.smoCurve = 0.1;
opts.smoXY = 0;
opts.usePG = 0;

[datOrg,opts] = burst.prep1(p0,f0,[],opts);  % read data


%% detection
opts.thrARScl = 8;
[dat,dF,arLst,lmLoc,opts,dL] = burst.actTop(datOrg,opts);  % foreground and seed detection

opts.thrExtZ = 6;
opts.thrTWScl = 3;
[svLst,~,riseX] = burst.spTop(dat,dF,lmLoc,[],opts);  % super voxel detection

[riseLst,datR,evtLst,seLst] = burst.evtTop(dat,dF,svLst,riseX,opts);  % events


% ov1 = plt.regionMapWithData(arLst,datOrg,0.5); zzshow(ov1);
% ov1 = plt.regionMapWithData(svLst,datOrg,0.5); zzshow(ov1);
% ov1 = plt.regionMapWithData(seLst,datOrg,0.5,datR); zzshow(ov1);
% ov1 = plt.regionMapWithData(evtLst,datOrg,0.5,datR); zzshow(ov1);
% ov1 = plt.regionMapWithData(evtLstFilterZ,datOrg,0.5,datR); zzshow(ov1);
% ov1 = plt.regionMapWithData(evtLstMerge,datOrg,0.5,datR); zzshow(ov1);
% [ov1,lblMapS] = plt.regionMapWithData(evtLstE,datOrg,0.5,datRE); zzshow(ov1);






