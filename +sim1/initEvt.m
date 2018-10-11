function [p1,seedIdx,initTime,sucRt] = initEvt(p,idx)
    % initEvt set parameters for generating an event
    % seed location, propagation success rate, initial time, duration
    % 
    
    pixMap = p.sePix{idx};
    %pixMap = imfill(pixMap,'holes');

    p1 = [];
    p1.dsRate = p.dsRate;
    p1.pixMap = pixMap;
    p1.nPix = sum(pixMap(:)>0);
    p1.sz = size(p.seVox{idx});
    %p1.fg = imdilate(pixMap,strel('square',3));
    p1.fg = pixMap;
    p1.sucRtBaseAvg = p.sePg{idx,2};
    
    % seed candidates in this SE
    % TODO: learn from real data for event number in that super event
    maxEvtNum = ceil(p1.nPix/p.evtArea);
    nEvt = randi([1,maxEvtNum]);
    %nEvt = randi([ceil(maxEvtNum/2),maxEvtNum]);
    msk00 = p1.sucRtBaseAvg;
    msk00(pixMap==0) = 0;
    sgRegMaxNow = imregionalmax(msk00);
    sgRegMaxNow(pixMap==0) = 0;
    locLm = find(sgRegMaxNow);
    seedIdx = locLm(randperm(numel(locLm),nEvt));
    
    % choose seeds obeying minimum distance
    msk = zeros(p1.sz(1),p1.sz(2));
    msk(seedIdx) = 1:nEvt;
    for ii=1:nEvt
        seed0 = seedIdx(ii);
        if msk(seed0)==0
            continue
        end
        [ih,iw] = ind2sub(p1.sz,seed0);
        rgh0 = max(ih-p.seedMinDist,1):min(ih+p.seedMinDist,p1.sz(1));
        rgw0 = max(iw-p.seedMinDist,1):min(iw+p.seedMinDist,p1.sz(2));
        msk(rgh0,rgw0) = 0; msk(seed0) = 1;
    end
    seedIdx = find(msk);
    nEvt = numel(seedIdx);
    
    % event properties
    p1.sucRtBase = p.sePg{idx,1};
    p1.cRiseMin = p.cRiseMin;
    p1.speedUpProp = p.speedUpProp;
    
    p1.xSeedLoc = 2*sqrt(nEvt);  % rough maximum propagation distance from seeds
    p1.xOverSample = 5;  % further temporal over-sample during growing
    [ihxx,iwxx,~] = ind2sub(p.sz,p.se{idx});
    p1.dist = max(max(ihxx)-min(ihxx),max(iwxx)-min(iwxx));
    p1.sucRtOverall = p1.dist/p1.xSeedLoc/p1.sz(3)/p1.xOverSample;
    if nEvt>1
        xPropRatio = 1;  % allow higher success rate for large events
    else
        xPropRatio = 1;
    end
    rt0 = p1.sucRtOverall/mean(p1.sucRtBase(pixMap>0))*xPropRatio;
    sucRt = ones(1,nEvt)*rt0;
    
    %initTime = randi(ceil(p1.sz(3)/2),1,nEvt);
    %initTime = initTime - min(initTime);
    initTime = zeros(1,nEvt);
    
    %duraTime = ones(1,nEvt)*p1.sz(3)*p.dsRate;  % FIXME: be more flexible    
    %p1.extTime = 5*p.dsRate;  % FIXME: should be a parameter
    
end


