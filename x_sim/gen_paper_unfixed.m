%% generate simulation data for AQuA paper simulation figures
fTop = getWorkPath();
pRes = [fTop,'dat_detect/se_only/'];
pDat = [fTop,'dat/'];
pOut = [fTop,'simDat/'];
f0 = 'FilteredNRMCCyto16m_slice3_Baseline3_L2 3-015cycle1channel1';

p = sim1.extractSeFromAquaResults(pDat,pRes,f0);

simIdx = [];  % [] for template, number for additional ones
nRep = 2;
% rng(88);


%% ROI with size changing events
sName = 'nonroi-szChg';
stdVec = 1:5;  % max odds, the average is 1,1.5,2,2.5,3

p0 = p;
p0.stdVec = stdVec;
p0.dxSz = 0.5;
p0.circMax = 10;
p0.dxOfst = 1;

dmMap = sim1.genDomainsSizeCirc(p0);
p0.dmMap = dmMap;

datLst = cell(0);
evtLst = cell(0);
parfor ii=1:numel(stdVec)
    for nn=1:nRep
        fprintf('%d\n',ii)
        [datSim0,evtLst0] = sim1.genEvt_sizeChange(p0,dmMap,stdVec(ii));
        datLst{ii,nn} = datSim0;
        evtLst{ii,nn} = evtLst0;
    end
end

save([pOut,sName,num2str(simIdx),'.mat'],'datLst','evtLst','p0','-v7.3');


%% ROI with location drifting events
sName = 'nonroi-locChg';
stdVec = 0:0.25:1;  % ratio of diameters

p0 = p;
p0.stdVec = stdVec;
p0.dxSz = 0.5;
p0.circMax = 10;
p0.dxOfst = 1;

dmMap = sim1.genDomainsSizeCirc(p0);
p0.dmMap = dmMap;

datLst = cell(0);
evtLst = cell(0);
parfor ii=1:numel(stdVec)
    for nn=1:nRep
        fprintf('%d\n',ii)
        [datSim0,evtLst0,q] = sim1.genEvt_locDrift(p0,dmMap,stdVec(ii));
        datLst{ii,nn} = datSim0;
        evtLst{ii,nn} = evtLst0;
    end
end

save([pOut,sName,num2str(simIdx),'.mat'],'datLst','evtLst','p0','-v7.3');





















