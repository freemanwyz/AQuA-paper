% generate simulation data for AQuA paper simulation figures
% based on super events detection results for 2D regions and locations
%

fTop = getWorkPath();
pRes = [fTop,'dat_detect/se_only/'];
pDat = [fTop,'dat/'];
f0 = 'FilteredNRMCCyto16m_slice3_Baseline3_L2 3-015cycle1channel1';
pOut = [fTop,'simDat/'];

p = sim1.extractSeFromAquaResults(pDat,pRes,f0);

simIdx = [];  % [] for template, number for additional ones
nRep = 2;
% rng(88);


%% ROI with propagating events - keep duration unchanged
% for moving type, duration is with respect to each pixel
% for growing type, keep the average duration unchanged

% stdVec = [0,0.1,0.2,0.5,1,2,4,6,8,10];  % propagation delay
stdVec = [0,2.5,5,7.5,10];
% stdVec = 0:2:10;
% stdVec = [0,2.5,5,10,15,20];

p0 = p;
% p0.domainType = 'average2';  % large
p0.stdVec = stdVec;
p0.seedMinDist = 1e8;
p0.circMax = 5;
p0.dxSz = 0.2;
p0.dxOfst = 1.8;
p0.smoBefDs = 0;

% p.tfUp = 10*p.dsRate;  % onset part filter
% p.tfDn = 10*p.dsRate;  % offset part filter
% p.filter3D = sim1.getDecayFilter(p.tfUp,p.tfDn,1);  % filter in time direction

% p0.dsRate = 1;
% p0.xRate = 1;
p0.blurOut = 0;
% p0.ignoreFilterSpa = 1;
% p0.ignoreFilterTemp = 1;

[dmMap,dmSeIdx] = sim1.genDomainsSizeCirc(p0);
% [dmMap,dmSeIdx] = sim1.genDomains(p0);
p0.dmMap = dmMap;


%% generate movies
% typeLst = {'move'};
typeLst = {'grow','move','mixed'};
propSpeed = zeros(numel(typeLst),numel(stdVec));
propSpeedNorm = propSpeed;
for nn=1:numel(typeLst)
    datLst = cell(0);
    evtLst = cell(0);
    p0.propType = typeLst{nn};
    sName = ['prop-',typeLst{nn},'-speedChg'];
    parfor ii=1:numel(stdVec)
        p1 = p0;
        for mm=1:nRep
            fprintf('%d\n',ii)
            p1.propAccel = stdVec(ii);
            [datSim0,evtLst0,q] = sim1.genEvt_domain_propSpeedChg(p1,dmMap,dmSeIdx);
            datLst{ii,mm} = datSim0;
            evtLst{ii,mm} = evtLst0;
            if ii==1
                propSpeed(nn,ii) = nanmean(q.propSpeed);
                propSpeedNorm(nn,ii) = nanmean(q.propSpeedNorm);
            end
            fprintf('Active voxels count: %d\n',sum(datSim0(:)>0));
        end
    end
    save([pOut,sName,num2str(simIdx),'.mat'],'datLst','evtLst','p0','-v7.3');
end


%% signal not detectable by ROI
if 0
    p1 = p0;
    p1.propAccel = 1;
    p1.propType = 'move';
    p1.ignoreFilterSpa = 1;
    p1.ignoreFilterTemp = 1;
    [datSim0,evtLst0] = sim1.genEvt_domain_propSpeedChg(p1,dmMap,dmSeIdx);
    rtx0 = nan(numel(evtLst0),1);
    for ii=1:numel(evtLst0)
        evt0 = evtLst0{ii};
        [ih0,iw0,it0] = ind2sub(size(datSim0),evt0);
        nVox0 = numel(evt0);
        nPix0 = numel(unique(sub2ind(size(dmMap),ih0,iw0)));
        dt0 = max(it0)-min(it0)+1;
        rtx0(ii) = nVox0/nPix0/dt0;
    end
    nanmean(rtx0)
end






