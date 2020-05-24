function [p1,seedIdx,initTime,sucRt] = initEvtCopyReal(p,idx,nEvtTgt)
    % initEvt set parameters for generating an event
    %
    % seed location, propagation success rate, initial time, duration
    % support moving and growing propagation types
    %
    % we first over-select, then reduce event numbers to the desired
    %
    
    pixMap = p.sePix{idx};

    p1 = [];
    p1.nPix = sum(pixMap(:)>0);
    p1.sz = size(p.seVox{idx});
    if numel(p1.sz)==2
        p1.sz = [p1.sz,1];
    end
    p1.sucRtBaseAvg = p.sePg{idx,2};
    p1.propType = 'grow';
    p1.propTypeScore = 1;
    
    % seed candidates in this SE
    msk00 = p1.sucRtBaseAvg;
    msk00(pixMap==0) = 0;
    sgRegMaxNow = imregionalmax(msk00);
    sgRegMaxNow(pixMap==0) = 0;
    locLm = find(sgRegMaxNow);
    idxSel = unique(randsample(numel(locLm),nEvtTgt*5,true));
    seedIdx = locLm(idxSel);
    
    % choose seeds obeying minimum distance
    msk = zeros(p1.sz(1),p1.sz(2));
    msk(seedIdx) = 1:numel(seedIdx);
    distMax = max(p1.sz(1),p1.sz(2))*sqrt(2);
    %distRg = round(linspace(distMax/10,distMax,10));
    if distMax>10
        distRg = 10:10:distMax;
    else
        distRg = 1:distMax;
    end
    nEvt = nEvtTgt;
    for dist0=distRg
        for ii=1:nEvt
            seed0 = seedIdx(ii);
            if msk(seed0)==0
                continue
            end
            [ih,iw] = ind2sub(p1.sz,seed0);
            rgh0 = max(ih-dist0,1):min(ih+dist0,p1.sz(1));
            rgw0 = max(iw-dist0,1):min(iw+dist0,p1.sz(2));
            msk(rgh0,rgw0) = 0; 
            msk(seed0) = 1;
        end
        seedIdx = find(msk);
        nEvt = numel(seedIdx);
        if nEvt<=nEvtTgt
            break
        end
    end

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
    p1.xSeedLoc = 2*sqrt(nEvt);  % rough maximum propagation distance from seeds
    
    [ihxx,iwxx,~] = ind2sub(p.sz,p.se{idx});
    p1.dist = max(max(ihxx)-min(ihxx),max(iwxx)-min(iwxx));
    p1.sucRtOverall = p1.dist/p1.xSeedLoc/p1.sz(3)/p1.xOverSample;
    
    rt0 = p1.sucRtOverall/mean(p1.sucRtBase(pixMap>0));
    sucRt = ones(1,nEvt)*rt0;
    initTime = zeros(1,nEvt);
    
end


