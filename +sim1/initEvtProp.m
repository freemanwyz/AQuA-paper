function [p1,seedIdx,initTime,sucRt] = initEvtProp(p,idx)
    % initEvt set parameters for generating an event
    %
    % seed location, propagation success rate, initial time, duration
    % support moving and growing propagation types
    %
    % we first over-select, then reduce the numbers
    %
    
    rng(88)
    
    pixMap = p.sePix{idx};

    p1 = [];
    p1.nPix = sum(pixMap(:)>0);
    p1.sz = size(p.seVox{idx});
    p1.sucRtBaseAvg = p.sePg{idx,2};
    
    % seed candidates in this SE
    %msk00 = p1.sucRtBaseAvg;
    %msk00(pixMap==0) = 0;
    %sgRegMaxNow = imregionalmax(msk00);
    %sgRegMaxNow(pixMap==0) = 0;
    %locLm = find(sgRegMaxNow);
    
    ix00 = find(pixMap>0);
    locLm = ix00(randsample(numel(ix00),max(round(numel(ix00)/50),3)));
    
    % sample for seed candidates
    maxEvtNum = ceil(p1.nPix/p.evtArea);
    %nEvt = randi([1,maxEvtNum]);
    if strcmp(p.propType,'mixed')
        if randi(2)==1
            p.propType = 'grow';
        else
            p.propType = 'move';
        end
    end
    switch p.propType
        case 'grow'
            wt = locLm*0+1;
            p1.propTypeScore = 1;
        case 'move'
            [ih,iw] = ind2sub(p1.sz(1:2),locLm);
            dhw = (ih-ih').^2+(iw-iw').^2;
            wt = max(dhw,[],2);  % prefer longer path
            p1.propTypeScore = 0;
    end
    wt = wt/sum(wt);
    idxSel = unique(randsample(numel(locLm),maxEvtNum*5,true,wt));
    %if numel(idxSel)>nEvt
    %    idxSel = idxSel(1:nEvt);
    %end
    seedIdx = locLm(idxSel);
    seedIdx = seedIdx(randperm(numel(seedIdx)));
    
    % choose seeds obeying minimum distance
    msk = zeros(p1.sz(1),p1.sz(2));
    msk(seedIdx) = 1;
    for ii=1:numel(seedIdx)
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
    
    seedMap = 1*(pixMap>0);
    seedMap(seedIdx) = 2;
    p1.seedMap = imdilate(seedMap,strel('square',5));
    
    % event properties
    p1.fg = pixMap;
    p1.pixMap = pixMap;
    p1.sucRtBase = p.sePg{idx,1};
    p1.cRiseMin = p.cRiseMin;
    p1.speedUpProp = p.speedUpProp;
    p1.dsRate = p.dsRate;
    p1.xRate = p.xRate;
    p1.xOverSample = 5;  % temporal over-sample during growing
    if isfield(p,'propAccel')
        p1.propAccel = p.propAccel;
    else
        p1.propAccel = 0;
    end
    
    p1.xSeedLoc = 2*sqrt(nEvt);  % rough maximum propagation distance from seeds
    
    [ihxx,iwxx,~] = ind2sub(p.sz,p.se{idx});
    p1.dist = max(max(ihxx)-min(ihxx),max(iwxx)-min(iwxx));
    p1.sucRtOverall = p1.dist/p1.xSeedLoc/p1.sz(3)/p1.xOverSample;
    
    rt0 = p1.sucRtOverall/mean(p1.sucRtBase(pixMap>0));
    sucRt = ones(1,nEvt)*rt0;
    initTime = zeros(1,nEvt);
    
end


