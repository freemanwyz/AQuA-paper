% test running time for different data sets
% Data type, duration, total events volume

addpath(genpath('../AQuA-stable/'));
pTop = getWorkPath();
presetVec = 4;
% presetVec = [1,2,4];

for nn=1:numel(presetVec)
    preset = presetVec(nn);
    
    % preset 1: in vivo. 2: ex vivo lck. 4: GluSnFR
    if preset == 1
        p0 = 'D:\OneDrive\projects\glia_kira\raw\Mar14_InVivoDataSet\';
        f0Vec = {'2x_125um_gcampwLEP_10min_moco',...
            '2826451(4)_1_2_4x_140um_dualwv-001',...
            '2826451(4)_1_2_4x_reg_200um_dualwv-001'};
%         f0Vec = {'2x_125um_gcampwLEP_10min_moco',...
%             '2x_145um_gcampwLEP_10min_moco',...
%             '2x_190um_gcampwLEP_10min_moco',...
%             '2826451(4)_1_2_4x_140um_dualwv-001',...
%             '2826451(4)_1_2_4x_reg_200um_dualwv-001'};
    end
    
    if preset == 2
        p0 = 'D:\OneDrive\projects\glia_kira\raw\TTXDataSetRegistered_32Bit\';
        f0Vec = {'FilteredNRMCCyto16m_slice1_baseline1_L2 3-001cycle1channel1',...
            'FilteredNRMCCyto16m_slice2_Baseline3_L2 3-009cycle1channel1',...
            'FilteredNRMCCyto16m_slice3_Baseline1_L2 3-013cycle1channel1',...
            %'FilteredNRMCCyto16m_slice3_TTX1_L2 3-016cycle1channel1',...
            %'FilteredNRMCCyto22m_slice1_Baseline2_Layer2_3-002cycle1channel1'
            };
    end
    
    if preset == 4
        p0 = 'D:\OneDrive\projects\glia_kira\raw\GluSnFR_20180511';
        f0Vec = {
            'gfap-121116-slice1-ACSF-012_reg',...
            'hsyn-102816-Slice1-ACSF-001_reg',...
            'hsyn-111016-Slice1-ACSF-003_reg',...
            %'gfap-122616-slice1-baseline-005_channel1_reg',...
            %'gfap-122616-slice1-baseline2-006-channel1_2_reg'
            };
    end
    
    % detection
    opts = util.parseParam(preset,0,'parameters1.csv');
    opts.spSz = 25;  % 9
    
    %     opts.thrARScl = 6;
    
    tLst = cell(numel(f0Vec),1);
    szLst = cell(numel(f0Vec),1);
    volLst = zeros(numel(f0Vec),1);
    pLst = cell(numel(f0Vec),1);
    mLst = cell(numel(f0Vec),1);
    evtLstAll = cell(numel(f0Vec),1);
    
    %     profile('-memory','on');
    for ii=1:numel(f0Vec)
        %         profile('on');
        f0 = f0Vec{ii};
        [datOrg,opts] = burst.prep1(p0,[f0,'.tif'],[],opts);  % read data
        
        [dat,dF,arLst,lmLoc,opts,dL] = burst.actTop(datOrg,opts);  % foreground and seed detection
        
        [svLst,~,riseX] = burst.spTop(dat,dF,lmLoc,[],opts);  % super voxel detection
        
        [riseLst,datR,evtLst,seLst] = burst.evtTop(dat,dF,svLst,riseX,opts);  % events
        
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
        
        szLst{ii} = size(datOrg);
        volLst(ii) = sum(cellfun(@numel,evtLstE));
        evtLstAll{ii} = evtLstE;
        
        % running time and memory usage
        if 0
            profile('off');
            profData = profile('info');
            pLst{ii} = profData;
            
            xx = {profData.FunctionTable.FunctionName};
            mAll = profData.FunctionTable(1).TotalMemAllocated/8/1e9;
            tAll = profData.FunctionTable(1).TotalTime;
            
            idx0 = find(strcmp(xx,'prep1'));
            m0 = profData.FunctionTable(idx0).TotalMemAllocated/8/1e9;
            t0 = profData.FunctionTable(idx0).TotalTime;
            
            idx1 = find(strcmp(xx,'actTop'));
            m1 = profData.FunctionTable(idx1).TotalMemAllocated/8/1e9;
            t1 = profData.FunctionTable(idx1).TotalTime;
            
            idx2 = find(strcmp(xx,'spTop'));
            m2 = profData.FunctionTable(idx2).TotalMemAllocated/8/1e9;
            t2 = profData.FunctionTable(idx2).TotalTime;
            
            idx3 = find(strcmp(xx,'evtTop'));
            m3 = profData.FunctionTable(idx3).TotalMemAllocated/8/1e9;
            t3 = profData.FunctionTable(idx3).TotalTime;
            
            idx4 = find(strcmp(xx,'getFeatureQuick'));
            m4 = profData.FunctionTable(idx4).TotalMemAllocated/8/1e9;
            t4 = profData.FunctionTable(idx4).TotalTime;
            
            idx5 = find(strcmp(xx,'mergeEvt'));
            m5 = profData.FunctionTable(idx5).TotalMemAllocated/8/1e9;
            t5 = profData.FunctionTable(idx5).TotalTime;
            
            idx6 = find(strcmp(xx,'evtTopEx'));
            if ~isempty(idx6)
                m6 = profData.FunctionTable(idx6).TotalMemAllocated/8/1e9;
                t6 = profData.FunctionTable(idx6).TotalTime;
            else
                m6 = 0; t6 = 0;
            end
            
            idx7a = find(strcmp(xx,'getFeaturesTop'));
            m7a = profData.FunctionTable(idx7a).TotalMemAllocated/8/1e9;
            t7a = profData.FunctionTable(idx7a).TotalTime;
            
            idx7b = find(strcmp(xx,'getFeaturesPropTop'));
            m7b = profData.FunctionTable(idx7b).TotalMemAllocated/8/1e9;
            t7b = profData.FunctionTable(idx7b).TotalTime;
            
            m7 = max(m7a,m7b);
            t7 = t7a+t7b;
            
            mLst{ii} = [mAll,m0,m1,m2,m3,m4,m5,m6,m7];
            tLst{ii} = [tAll,t0,t1,t2,t3,t4,t5,t6,t7];
        end
    end
    save(['x_',num2str(preset),'.mat'],'p0','f0Vec','evtLstAll');
    %     save(['run_',num2str(preset),'.mat'],'p0','f0Vec','tLst','mLst','szLst','volLst','pLst');
end

if 0
    ov1 = plt.regionMapWithData(arLst,datOrg,0.5); zzshow(ov1);
    ov1 = plt.regionMapWithData(svLst,datOrg,0.5); zzshow(ov1);
    ov1 = plt.regionMapWithData(seLst,datOrg,0.5,datR); zzshow(ov1);
    ov1 = plt.regionMapWithData(evtLst,datOrg,0.5,datR); zzshow(ov1);
    ov1 = plt.regionMapWithData(evtLstFilterZ,datOrg,0.5,datR); zzshow(ov1);
    ov1 = plt.regionMapWithData(evtLstMerge,datOrg,0.5,datR); zzshow(ov1);
    [ov1,lblMapS] = plt.regionMapWithData(evtLstE,datOrg,0.5,datRE); zzshow(ov1);
end






