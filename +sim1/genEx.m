function [datSim,evtLst,evtLstCore,seSim] = genEx(p)
    % generate super events and events

    dOut = zeros(p.sz(1),p.sz(2),ceil(p.nSe/p.seDensity*p.dsRate),'single');
    eOut = zeros(size(dOut),'int32');
    seSim = cell(0);
    evtCnt = 0;
    seCnt = 1;
    nSeEx = numel(p.se);
    for nn=1:p.nSe*1.5
        fprintf('S.evt: %d\n',nn)
        p1 = [];
        
        % get one SE
        idx = randi(nSeEx);
        pixMap = p.sePix{idx};
        p1.nPix = sum(pixMap(:)>0);  
        p1.sz = size(p.seVox{idx});
        p1.fg = imdilate(pixMap,strel('square',3));
        p1.sucRtBaseAvg = p.sePg{idx,2};

        % seed candidates in this SE
        maxEvtNum = ceil(p1.nPix/p.evtArea);  
        nEvt = randi([ceil(maxEvtNum/2),maxEvtNum]);
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
        
        initTime = randi(ceil(p1.sz(3)/2),1,nEvt);
        initTime = initTime - min(initTime);
        duraTime = ones(1,nEvt)*p1.sz(3)*p.dsRate;
        p1.maxTime = p.dsRate;
        
        % generate an event or a super event
        [evtMap,regMap,dlyMap] = sim1.genSe(seedIdx,sucRt,initTime,duraTime,p1);
        
        % relative intensity for pixels      
        mskIntensity = p.sePg{idx,2};
        datSeVal = (evtMap>0).*mskIntensity*p.seBri(idx);        
        rgh1 = p.seRg(idx,1):p.seRg(idx,2);
        rgw1 = p.seRg(idx,3):p.seRg(idx,4);
        
        % find earliest valid frame on dilated pixel map        
        rgh2 = max(min(rgh1)-5,1):min(max(rgh1)+5,p.sz(1));
        rgw2 = max(min(rgw1)-5,1):min(max(rgw1)+5,p.sz(2));
        regMap1 = zeros(numel(rgh2),numel(rgw2));
        regMap1(rgh1-min(rgh2)+1,rgw1-min(rgw2)+1) = regMap>0;
        
        act0 = dOut(rgh2,rgw2,:);
        msk0 = imdilate(regMap1,strel('square',9));
        act0x = act0.*msk0;
        act0x = sum(reshape(act0x,[],size(dOut,3)))>0;
        tSlotMin = size(datSeVal,3)+2*numel(p.filter3D);  % se frame number
        
        xx = find(act0x>0);
        t0 = [];
        if isempty(xx)  % random find the frame to put
            t0 = randi(size(dOut,3)-tSlotMin);
        else  % find frame with enough space
            xx1 = [1,xx,size(dOut,3)];
            xx1Dif = xx1(2:end) - xx1(1:end-1);
            x00 = find(xx1Dif>tSlotMin);
            
            if ~isempty(x00)
                idx1 = x00(randi(numel(x00)));  % randomly choose one slot
                a = xx1(idx1)+2*numel(p.filter3D);
                b = xx1(idx1+1)-tSlotMin;
                if a<b
                    t0 = randi([a,b]);  % randomly choose one frame
                end
            end
        end
        
        if ~isempty(t0)
            % add SE to movie
            tx = size(datSeVal,3);
            rgt = t0:t0+tx-1;
            
            dOut(rgh1,rgw1,rgt) = dOut(rgh1,rgw1,rgt) + single(datSeVal);
            evtMap(evtMap>0) = evtMap(evtMap>0)+evtCnt;
            evtCnt = max(evtMap(:));
            eOut(rgh1,rgw1,rgt) = max(eOut(rgh1,rgw1,rgt),int32(evtMap));
            
            % save simulated SE and event info
            xx = [];
            x0 = evtMap(evtMap(:)>0);
            x0 = unique(x0);            
            xx.evt = x0;
            xx.onset = dlyMap;
            xx.reg = regMap;
            xx.rgh = rgh1; xx.rgw = rgw1; xx.rgt = rgt;
            xx.bri = p.seBri(idx);
            xx.intMap = mskIntensity*p.seBri(idx).*(regMap>0);
            seSim{seCnt} = xx;
            seCnt = seCnt + 1;
        end
        if seCnt>=p.nSe
            break
        end
    end
    
    % post-processing
    [datSim,evtLst,evtLstCore] = sim1.postProcSim(dOut,eOut,p);
    
end





