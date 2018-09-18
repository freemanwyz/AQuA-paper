function res = aqua_top(datOrg,opts)
    %global dbg
    
    % -- preset 1: in vivo. 2: ex vivo. 3: GluSnFR
    [datOrg,opts] = burst.prep1a(datOrg,opts);
    
    % detection
    [dat,dF,arLst,lmLoc,opts,~] = burst.actTop(datOrg,opts);  % foreground and seed detection
    %ov1 = plt.regionMapWithData(arLst,datOrg,0.5); zzshow(ov1);
    %zzshow(dbg.datSim>0);zzshow(datOrg)
    
    [svLst,~,riseX] = burst.spTop(dat,dF,lmLoc,[],opts);  % super voxel detection
    %ov1 = plt.regionMapWithData(svLst,datOrg,0.5); zzshow(ov1);
    
    [riseLst,datR,evtLst,seLst] = burst.evtTop(dat,dF,svLst,riseX,opts);  % events
    %ov1 = plt.regionMapWithData(seLst,datOrg,0.5,datR); zzshow(ov1);
    %ov1 = plt.regionMapWithData(evtLst,datOrg,0.5,datR); zzshow(ov1);
    
    [ftsLst,dffMat] = fea.getFeatureQuick(datOrg,evtLst,opts);
    
    % fitler by significance level
    mskx = ftsLst.curve.dffMaxZ>opts.zThr;
    dffMatFilterZ = dffMat(mskx,:);
    evtLstFilterZ = evtLst(mskx);
    tBeginFilterZ = ftsLst.curve.tBegin(mskx);
    riseLstFilterZ = riseLst(mskx);
    %ov1 = plt.regionMapWithData(evtLstFilterZ,datOrg,0.5,datR); zzshow(ov1);
    
    % merging (glutamate)
    evtLstMerge = burst.mergeEvt(evtLstFilterZ,dffMatFilterZ,tBeginFilterZ,opts);
    %ov1 = plt.regionMapWithData(evtLstMerge,datOrg,0.5,datR); zzshow(ov1);
    
    % reconstruction (glutamate)
    if opts.extendSV==0 || opts.ignoreMerge==0 || opts.extendEvtRe>0
        [riseLstE,datRE,evtLstE] = burst.evtTopEx(dat,dF,evtLstMerge,opts);
    else
        riseLstE = riseLstFilterZ; datRE = datR; evtLstE = evtLstFilterZ;
    end
    %ov1 = plt.regionMapWithData(evtLstE,datOrg,0.5,datRE); zzshow(ov1);
    
    % feature extraction
    [ftsLstE,dffMatE,dMatE] = fea.getFeaturesTop(datOrg,evtLstE,opts);
    ftsLstE = fea.getFeaturesPropTop(dat,datRE,evtLstE,ftsLstE,opts);
    
    res = [];
    res.opts = opts;
    res.se = seLst;
    res.evtAll = evtLst;
    res.evt = evtLstE;
    res.rise = riseLstE;
    res.fts = ftsLstE;
    res.dffMat = dffMatE;
    res.dMat = dMatE;
    
end






