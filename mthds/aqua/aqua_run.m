%% setup
addpath(genpath('../AQuA/'));
pOut = 'D:\OneDrive\projects\glia_kira\se_aqua\dat_detect\';
p0 = 'D:\OneDrive\projects\glia_kira\se_aqua\dat\';

f0 = {
    {'2826451(4)_1_2_4x_reg_200um_dualwv-001_nr',1}
    };

% f0 = {
%     {'FilteredNRMCCyto16m_slice2_Baseline3_L2 3-009cycle1channel1',3},...
%     {'FilteredNRMCCyto16m_slice2_TTX3_L2 3-012cycle1channel1',3},...
%     {'FilteredNRMCCyto16m_slice3_Baseline3_L2 3-015cycle1channel1',3}
%     };


%% detection
for nn=1:numel(f0)
    opts = util.parseParam(f0{nn}{2},0,'parameters1.csv');
    opts.zThr = 5;
    
    [datOrg,opts] = burst.prep1(p0,[f0{nn}{1},'.tif'],[],opts);
    
    % foreground and seed detection
    [dat,dF,arLst,lmLoc,opts,dL] = burst.actTop(datOrg,opts);
    
    % super voxel detection
    [svLst,~,riseX] = burst.spTop(dat,dF,lmLoc,[],opts);
    
    % events
    [riseLst,datR,evtLst,seLst] = burst.evtTop(dat,dF,svLst,riseX,opts);
    
    % fitler by significance level
    [ftsLst,dffMat] = fea.getFeatureQuick(datOrg,evtLst,opts);
    mskx = ftsLst.curve.dffMaxZ>opts.zThr;
    dffMatFilterZ = dffMat(mskx,:);
    evtLstFilterZ = evtLst(mskx);
    tBeginFilterZ = ftsLst.curve.tBegin(mskx);
    riseLstFilterZ = riseLst(mskx);
    
    % merging (glutamate)
    evtLstMerge = burst.mergeEvt(evtLstFilterZ,dffMatFilterZ,tBeginFilterZ,opts);
    
    % reconstruction (glutamate)
    if opts.extendSV==0 || opts.ignoreMerge==0 || opts.extendEvtRe>0
        [riseLstE,datRE,evtLstE] = burst.evtTopEx(dat,dF,evtLstMerge,opts);
    else
        riseLstE = riseLstFilterZ; datRE = datR; evtLstE = evtLstFilterZ;
    end
    
    % feature extraction
    [ftsLstE,dffMatE,dMatE] = fea.getFeaturesTop(datOrg,evtLstE,opts);
    ftsLstE = fea.getFeaturesPropTop(dat,datRE,evtLstE,ftsLstE,opts);
    
    % export to GUI
    res = fea.gatherRes(datOrg,opts,evtLstE,ftsLstE,dffMatE,dMatE,riseLstE,datRE);
    res.seLst = seLst;
    res.datRecon = datRE;
    
    save([pOut,f0{nn}{1},'_aqua.mat'],'res','-v7.3');
end

%% plots
% aqua_gui(res);

% ov1 = plt.regionMapWithData(arLst,datOrg,0.5); zzshow(ov1);
% ov1 = plt.regionMapWithData(svLst,datOrg,0.5); zzshow(ov1);
% ov1 = plt.regionMapWithData(seLst,datOrg,0.5,datR); zzshow(ov1);
% ov1 = plt.regionMapWithData(evtLst,datOrg,0.5,datR); zzshow(ov1);
% ov1 = plt.regionMapWithData(evtLstFilterZ,datOrg,0.5,datR); zzshow(ov1);
% ov1 = plt.regionMapWithData(evtLstMerge,datOrg,0.5,datR); zzshow(ov1);
% [ov1,lblMapS] = plt.regionMapWithData(evtLstE,datOrg,0.5,datRE); zzshow(ov1);






