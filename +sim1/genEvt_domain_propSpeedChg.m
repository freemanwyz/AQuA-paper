function [datSim,evtLst,q] = genEvt_domain_propSpeedChg(p,dmMap,dmSeIdx)
    % generate events based on each domain
    %
    % all events propagates
    % meetting is not needed
    % speed limited by up-sampling rate
    %
    
    gapMin = 10*p.dsRate;

    dOut = zeros(p.sz(1),p.sz(2),ceil(p.nSe/p.seDensity*p.dsRate),'single');
    eOut = zeros(size(dOut),'int32');
    evtCnt = 0;
    ftLen = numel(p.filter3D);

    % generate events in each fixed domain
    dmLst = label2idx(dmMap);
    dmLen = cellfun(@numel,dmLst);
    dxMin = log(min(dmLen));
    dxMax = log(max(dmLen));
    dxGap = max(dxMax-dxMin,1);
    
    q = [];
    propSpeed = [];
    propSpeedNorm = [];
    
    for nn=1:numel(dmLst)
        fprintf('Domain %d\n',nn)
        
        pix0 = dmLst{nn};
        [ih0,iw0] = ind2sub(size(dmMap),pix0);
        rgh1 = min(ih0):max(ih0);
        rgw1 = min(iw0):max(iw0);
        
        idx = dmSeIdx(nn);
        %rgh1 = p.seRg(idx,1):p.seRg(idx,2);
        %rgw1 = p.seRg(idx,3):p.seRg(idx,4);
        
        dx0 = log(dmLen(nn));
        gapMax = round(gapMin+(dxMax-dx0)*20*p.dsRate/dxGap)+10*p.dsRate;
        tNow = ftLen;
        
        % default setting if fixed
        if p.fixed==1
            [p1,seedIdx,initTime,sucRt] = sim1.initEvtPropBorder(p,idx);
            evtMapx = sim1.genSePropDelayTrun(seedIdx,sucRt,initTime,p1);
            %evtMapx = sim1.genSePropSpeedAdj(seedIdx,sucRt,initTime,p1);
        end
        
        xx00 = randi(1e8);
        
        for uu=1:(p.nSe/numel(dmLst))
            %fprintf('Event %d\n',uu)
            rng(xx00)
            
            % generate an event or a super event
            if p.fixed==0
                [p1,seedIdx,initTime,sucRt] = sim1.initEvtPropBorder(p,idx);
                [evtMap,regMap,dlyMap] = sim1.genSePropDelayTrun(seedIdx,sucRt,initTime,p1);
                %[evtMap,regMap,dlyMap] = sim1.genSePropSpeedAdj(seedIdx,sucRt,initTime,p1);
            else
                evtMap = evtMapx;
            end
            
            % calculate real propagation speed
            % support single source only
            [ih2,iw2] = find(regMap>0);
            [ihc,iwc] = ind2sub(size(regMap),seedIdx(1));
            dMax00 = max(sqrt((ihc-ih2).^2+(iwc-iw2).^2));
            tMax00 = nanmax(dlyMap(:))/p.dsRate;
            propSpeed(end+1) = dMax00/tMax00; %#ok<AGROW>
            propSpeedNorm(end+1) = 1/tMax00; %#ok<AGROW>
            
            % trim events to pixel map                 
            evtMap = evtMap.*p1.pixMap;
            
            % relative intensity for pixels
            intMap = sum(evtMap,3)>0;
            if p.blurOut>0
                wtMap = bwdist(intMap==0);
                wtMap(wtMap>3) = 3;
                %wtMap(wtMap>0) = wtMap(wtMap>0)/max(wtMap(:))/2+0.5;
                intMap = wtMap/3;
            end
            datSeVal = (evtMap>0)*0.2.*intMap;
            datSeVal(datSeVal>0) = max(datSeVal(datSeVal>0),p.valMin);

            % find frame            
            t0 = tNow + randi([gapMin,gapMax]);
                        
            % add SE to movie
            tx = size(datSeVal,3);
            rgt = t0:t0+tx-1;
            tNow = max(rgt)+1;
            
            if tNow>size(dOut,3)-ftLen
                break
            end
            
            dOut(rgh1,rgw1,rgt) = dOut(rgh1,rgw1,rgt) + single(datSeVal);
            evtMap(evtMap>0) = evtMap(evtMap>0)+evtCnt;
            evtCnt = max(evtMap(:));
            eOut(rgh1,rgw1,rgt) = max(eOut(rgh1,rgw1,rgt),int32(evtMap));
        end
    end   
    
    % post processing
    [datSim,evtLst] = sim1.postProcSim(dOut,eOut,p);
    datSim = uint16(datSim*65535);
    
    q.propSpeed = propSpeed;
    q.propSpeedNorm = propSpeedNorm;
    
end













