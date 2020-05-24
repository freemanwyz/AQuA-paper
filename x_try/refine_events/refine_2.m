%% Test real data after some changes
% use raw data for event detection, test on real data
% Use noise after smoothing
% Use raw data after super events
% Refine super events
% Do not smooth curves in GTW (rising time estimation)
%

p0 = 'D:\OneDrive\projects\glia_kira\se_aqua\dat\';
% f0 = '2826451(4)_1_2_4x_reg_200um_dualwv-001_nr'; preset = 1;
% f0 = 'FilteredNRMCCyto16m_slice3_Baseline3_L2 3-015cycle1channel1'; preset = 3;

opts = util.parseParam(preset,[],'parameters1.csv');
opts.thrARScl = 3;

[datOrg,opts] = burst.prep1(p0,[f0,'.tif'],[],opts);
[dat,dF,arLst,lmLoc,opts,~] = burst.actTop(datOrg,opts);  % foreground and seed detection
% zzshow(regionMapWithData(arLst,dat*0));

[svLst,~,riseX] = burst.spTop(dat,dF,lmLoc,[],opts);
% zzshow(regionMapWithData(svLst,dat*0));

[riseLst,datR,evtLst,seLst] = burst.evtTop(datOrg,[],svLst,riseX,opts);
% zzshow(regionMapWithData(evtLst,dat*0));

[ftsLst,dffMat,dMat] = fea.getFeaturesTop(datOrg,evtLst,opts);








