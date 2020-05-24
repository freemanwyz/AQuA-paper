% re-produce each super events in ex vivo data as synthetic data
%
% TODO:
% Consider intensity when cutting super events to events
% 

if ispc
    fDrive = 'D:/';
else
    fDrive = '/Users/yizhi/';
end
fTop = [fDrive,'OneDrive/projects/glia_kira/se_aqua/'];
pRes = [fTop,'dat_detect/'];
pDat = [fTop,'dat/'];
pOut = [fTop,'simDat/'];

f0 = 'FilteredNRMCCyto16m_slice3_Baseline3_L2 3-015cycle1channel1';

% extract super events
% read data
tmp = load([pRes,f0,'_aqua.mat']);
evtLst = tmp.res.evt;
seLst = tmp.res.seLst;

% clean super events with events
seMap = lst2map(seLst,tmp.res.opts.sz);
evtMap = lst2map(evtLst,tmp.res.opts.sz);
seMap(evtMap==0) = 0;
seLst = label2idx(seMap);
seLst = seLst(~cellfun(@isempty,seLst));

dat = readTiffSeq([pDat,f0,'.tif']);
gapx = tmp.res.opts.regMaskGap;
dat = dat(gapx+1:end-gapx,gapx+1:end-gapx,:);
dat = sqrt(dat);
dat = dat/max(dat(:));

noiseStd = noiseInData(dat);
% sigMean = mean(dat(evtMap>0));

dBg = min(movmean(dat,20,3),[],3);
% dBg = median(dat,3);
dF = dat - dBg;
dF = imgaussfilt3(dF,1);
dF(dF<0) = 0;

p = sim1.extractSe(dat,seLst,0);
p = sim1.simParamEx(p);


%% generate data
[H,W,T] = size(dat);
T1 = T+10;
dOut = zeros(H,W,T1*p.dsRate,'single');
eOut = zeros(H,W,T1*p.dsRate,'uint32');
seOut = zeros(H,W,T1*p.dsRate,'uint32');
evtCnt = 0;
for idx=1:numel(p.sePix)
    fprintf('%d in %d\n',idx,numel(p.se))
    if numel(p.sePix{idx})<16
        continue
    end
    
    % only use suepr events containing detected events
    se0 = p.se{idx};
    evt0 = evtMap(se0);
    
    idx0 = unique(evt0(evt0>0));
    if isempty(idx0)
        continue
    end
    
    % get super events
    rgh1 = p.seRg(idx,1):p.seRg(idx,2);
    rgw1 = p.seRg(idx,3):p.seRg(idx,4);
    t1 = p.seRg(idx,5)*p.dsRate;
    apf0 = p.areaPerFrame{idx};
    [~,itMaxArea] = max(apf0);
    
    % generate events
    nEvt = numel(idx0);
    [p1,seedIdx,initTime,sucRt] = sim1.initEvtCopyReal(p,idx,nEvt);
    p1.dtProp = round((itMaxArea-1)*p.dsRate);
    durMin = round(1.2*max(p1.dtProp,1));
    if durMin<3*p.dsRate
        durMin = inf;
    end
    p1.dtTot = min(round((p.seRg(idx,6)*p.dsRate-t1)),durMin);
    evtMap0 = sim1.genSeCopyReal(seedIdx,sucRt,initTime,p1);
    datSeVal = (evtMap0>0).*p1.pixMap;
    
    % add SE to movie
    tx = size(datSeVal,3);
    rgt = t1:t1+tx-1;
    
    % in case of overlapping, remove smaller ones
    seOutNow = seOut(rgh1,rgw1,rgt);
    evtMap0a = imdilate(evtMap0,strel('square',5));
    idxOver = unique(seOutNow(evtMap0>0));
    idxOver = idxOver(idxOver>0);
    n0 = numel(p.sePix{idx});
    suc = 1;
    for kk=1:numel(idxOver)
        n1 = numel(p.sePix{idxOver(kk)});
        if n0<n1
            suc = 0;
            break
        end
    end
    if suc==0
        fprintf('Removed %d\n',idx)
        continue
    else
        for kk=1:numel(idxOver)
            fprintf('Removing %d\n',idxOver(kk))
            idx1 = find(seOut==idxOver(kk));
            seOut(idx1) = 0;
            eOut(idx1) = 0;
            dOut(idx1) = 0;
        end
    end
    
    % add events to movie
    dOut(rgh1,rgw1,rgt) = dOut(rgh1,rgw1,rgt) + single(datSeVal);
    evtMap0(evtMap0>0) = evtMap0(evtMap0>0)+evtCnt;
    evtCnt = max(evtMap0(:));
    eOut(rgh1,rgw1,rgt) = max(eOut(rgh1,rgw1,rgt),uint32(evtMap0));
    seOut(rgh1,rgw1,rgt) = max(seOut(rgh1,rgw1,rgt),uint32((evtMap0>0)*idx));
end

% spatial and temporal smoothing
p.smoXY = 2;
[datSim,evtLst] = sim1.postProcSimCopyReal(dOut,eOut,p);


%% adjust each event using dF
% adjust duration, do not discard pixels
% adjust intensity?

d1 = datSim(:,:,1:T).*dF;
d1Vec = reshape(d1,[],T);
peakValMin = noiseStd;
for nn=1:numel(evtLst)
    fprintf('Refining event %d\n',nn)
    evt0 = evtLst{nn};
    [ih,iw,it] = ind2sub([H,W,T1],evt0);
    ihw = sub2ind([H,W],ih,iw);
    pix = unique(ihw);
    for mm=1:numel(pix)
        pix0 = pix(mm);
        idx0 = ihw==pix(mm);
        [pix0h,pix0w] = ind2sub([H,W],pix0);
        it0 = sort(it(idx0));
        it0 = it0(it0<=T);
        val0 = d1Vec(pix0,it0);
        
        % increase weak peaks
        if max(val0)<peakValMin
            val0 = val0/max(val0)*peakValMin;
        end
        
        % discard value < 20% peak intensity
        val0Good = val0>0.2*max(val0);
        ix1 = find(val0Good,1);
        ix2 = find(val0Good,1,'last');
        if ix1>1
            val0(1:ix1) = 0;
        end
        if ix2<numel(val0)
            val0(ix2+1:end) = 0;
        end
        
        d1Vec(pix0,it0) = val0;
    end    
end
datSim1 = reshape(d1,H,W,T);

% update events
evtMap = lst2map(evtLst,size(datSim));
evtMap = evtMap(:,:,1:T);
evtLst1 = label2idx(evtMap.*(datSim1>0));
evtLst1 = evtLst1(~cellfun(@isempty,evtLst1));


%% output
sName = 'exvivo';
datLst = {uint16(datSim1*65535)};
evtLst = {evtLst1};

p0 = p;
p0.stdVec = 0;
p0.dAvg = dBg;
p0.nStdVec = noiseStd;

save([pOut,sName,'.mat'],'datLst','evtLst','p0','-v7.3');


%% 
datOut = (datSim1+dBg+randn(size(datSim1))*noiseStd).^2;
writeTiffSeq([pOut,filesep,sName,'.tif'],datOut);







