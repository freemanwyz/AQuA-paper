% old code, old preset
p_top = '../../glia_kira/raw/GRAB-NE/';

% f_dat = '190405_s1_002.tif'; p = 0;
f_dat = '190405_s2_005.tif'; p = 1;

% f_dat = '190405_s1_002_ds5.mat'; p = 0;
% f_dat = '190405_s2_005_ds5.mat'; p = 1;

addpath(genpath('../AQuA-current/'));
opts = util.parseParam(3,0,'parameters-GRAB-NE.csv');

% opts.regMaskGap = 0;
% opts.cut = 1e4;
% opts.minSize = 50;
% opts.seedRemoveNeib = 5;
% opts.thrTWScl = 10;
% opts.getTimeWindowExt = 5000;
% opts.minShow1 = 0.05;  
% 
% if p==0
%     opts.thrARScl = 2;  % 1 for raw data
%     opts.fsz = [2,2,4];  % [1,1,2]    
%     opts.thrExtZ = 1;    
%     opts.seedNeib = 5;  % 1        
%     opts.cDelay = 10;
%     opts.cRise = 10;
%     opts.maxStp = 3;
% end
% 
% if p==1
%     opts.smoXY = 2;
%     opts.thrARScl = 1;    
%     opts.fsz = [1,1,1];
%     opts.thrExtZ = 0.5;
%     opts.thrSvSig = 0.5;
%     opts.cDelay = 20; % 10
%     opts.cRise = 6;  % 3    
%     opts.maxStp = 21;
% end

[datOrg,opts] = burst.prep1(p_top,f_dat,[],opts);  % read data

[dat,dF,arLst,lmLoc,opts,dL] = burst.actTop(datOrg,opts);  % foreground and seed detection

[svLst,~,riseX,lblMap] = burst.spTop(dat,dF,lmLoc,dL,opts);  % super voxel detection

[riseLst,datR,evtLst,seLst] = burst.evtTop(dat,dF,svLst,riseX,opts);  % events

% [ftsLst,dffMat] = fea.getFeatureQuick(datOrg,evtLst,opts);

% zzshow(regionMapWithData(arLst,datOrg,0.5))
% zzshow(regionMapWithData(svLst,datOrg*0.5))
zzshow(regionMapWithData(evtLst,datOrg*0.5))
% zzshow(regionMapWithData(num2cell(lmLoc),datOrg,0.5))






