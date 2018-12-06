% generate simulation data for AQuA paper simulation figures

if ispc
    fTop = 'D:/OneDrive/projects/glia_kira/se_aqua/';
else
    fTop = '/Users/yizhi/OneDrive/projects/glia_kira/se_aqua/';
end

pRes = [fTop,'dat_detect/se_only/'];
pDat = [fTop,'dat/'];
f0 = 'FilteredNRMCCyto16m_slice3_Baseline3_L2 3-015cycle1channel1';
pOut = [fTop,'simDat/'];

p = sim1.extractSeFromAquaResults(pDat,pRes,f0);

nRep = 2;
rng(88);


% different domain size distribution
sName = 'nonroi-domainSz';
p0 = p;
p0.circMax = 1.5;
p0.stdVec = [0.01,0.1,0.5,1,10];
datLst = cell(0);
evtLst = cell(0);
for ii=1:numel(p0.stdVec)
    parfor nn=1:nRep
        fprintf('%d\n',ii)
        p1 = p0;
        p1.dxSz = p0.stdVec(ii);
        dmMap = sim1.genDomainsSizeCirc(p1);        
        p1.dmMap = dmMap;
        [datSim0,evtLst0] = sim1.genEvt_domain_roi(p1,dmMap);
        datLst{ii,nn} = datSim0;
        evtLst{ii,nn} = evtLst0;
    end
end

% size and shape
save([pOut,sName,'.mat'],'datLst','evtLst','p0','-v7.3');


% different domain circularity distribution
sName = 'nonroi-domainCirc';
p0 = p;
p0.dxSz = 5;
p0.stdVec = [1,2,5,10,100];
datLst = cell(0);
evtLst = cell(0);
for ii=1:numel(p0.stdVec)
    parfor nn=1:nRep
        fprintf('%d\n',ii)
        p1 = p0;
        p1.circMax = p0.stdVec(ii);
        dmMap = sim1.genDomainsSizeCirc(p1);        
        p1.dmMap = dmMap;
        [datSim0,evtLst0] = sim1.genEvt_domain_roi(p1,dmMap);
        datLst{ii,nn} = datSim0;
        evtLst{ii,nn} = evtLst0;
    end
end

% size and shape
save([pOut,sName,'.mat'],'datLst','evtLst','p0','-v7.3');



















