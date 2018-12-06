function [p1,seedIdx,initTime,sucRt] = initEvtPropBorder(p,idx)
    % initEvt set parameters for generating an event
    %
    % seed location, propagation success rate, initial time, duration
    % support moving and growing propagation types
    %
    % we first over-select, then reduce the numbers
    %
    % one seed on border
    %
    
    rng(88)
    nEvt = 1;    
    pixMap = p.sePix{idx};

    p1 = [];
    p1.nPix = sum(pixMap(:)>0);
    p1.sz = size(p.seVox{idx});
    p1.sucRtBaseAvg = p.sePg{idx,2};
    
    % find a seed on boundary
    cc = bwboundaries(pixMap>0,'noholes');
    bdSub = cc{1};
    ih = bdSub(:,1);
    iw = bdSub(:,2);
    ix00 = sub2ind(size(pixMap),ih,iw);
    dhw = (ih-ih').^2+(iw-iw').^2;
    dhw = max(dhw,[],2);
    [~,ixx] = max(dhw);    
    seedIdx = ix00(ixx);    
    seedMap = 1*(pixMap>0);
    seedMap(seedIdx) = 2;
    
    if strcmp(p.propType,'mixed')
        tst0 = sum(clock)*1000;
        if mod(tst0,2)==0
            p.propType = 'grow';
        else
            p.propType = 'move';
        end
    end
    switch p.propType
        case 'grow'    
            p1.propTypeScore = 1;
        case 'move'
            p1.propTypeScore = 0;
    end
    
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


