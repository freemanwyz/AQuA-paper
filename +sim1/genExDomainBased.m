function [datSim,evtLstAll,evtLst,seSim] = genExDomainBased(p,dmMap,dmSeIdx)
    % generate super events and events based on each domain
    % Similar to ROI based data
    % 
    % TODO:
    % Add sparklings to empty spaces between eventsm
    % Improve super event number, temporal gap and frequency
    % Spatial shifting between events in one domain
    % 

    dOut = zeros(p.sz(1),p.sz(2),ceil(p.nSe/p.seDensity*p.dsRate),'single');
    eOut = zeros(size(dOut),'int32');
    seSim = cell(0);
    evtCnt = 0;
    seCnt = 1;
    ftLen = numel(p.filter3D);

    % generate events in each fixed domain
    dmLst = label2idx(dmMap);
    dmLen = cellfun(@numel,dmLst);
    dxMin = log(min(dmLen));
    dxMax = log(max(dmLen));
    for nn=1:numel(dmLst)
        fprintf('Domain %d\n',nn)
        
        idx = dmSeIdx(nn);
        dx0 = log(dmLen(nn));
        rgh1Org = p.seRg(idx,1):p.seRg(idx,2);
        rgw1Org = p.seRg(idx,3):p.seRg(idx,4);
        
        % events in one domain
        [p1,seedIdx,initTime,sucRt] = sim1.initEvt(p,idx);
        
        if numel(seedIdx)==0  % only generate complex patterns in this step
            continue
        end
        
        gapMin = 10*p.dsRate;  % default: 5
        if dxMax>dxMin
            gapMax = round(gapMin+(dxMax-dx0)*20*p.dsRate/(dxMax-dxMin))+10*p.dsRate;
        else
            gapMax = gapMin;
        end
        tNow = ftLen;
        
        % default setting if fixed
        [evtMapx,regMapx,dlyMapx] = sim1.genSe(seedIdx,sucRt,initTime,p1);
        if p.noProp==1 || numel(dmLst{nn})<p.minPropSz
            regMapx = 1*(regMapx>0);
            x0 = sum(reshape(evtMapx,[],size(evtMapx,3)),1);
            t0 = find(x0>0,1);
            t1 = find(x0>0,1,'last');
            evtMapx = evtMapx*0;
            for tt=t0:t1
                evtMapx(:,:,tt) = regMapx;
            end
        end
        
        for uu=1:(p.nSe/numel(dmLst))
            fprintf('Event %d\n',uu)
            
            % generate an event or a super event
            if p.noProp==0 && p.fixed==0 && numel(dmLst{nn})>=p.minPropSz
                [p1,seedIdx,initTime,sucRt] = sim1.initEvt(p,idx);
                [evtMap,regMap,dlyMap] = sim1.genSe(seedIdx,sucRt,initTime,p1);
            else
                evtMap = evtMapx;
                regMap = regMapx;
                dlyMap = dlyMapx;
            end
            
            xx = regMap(regMap>0);
            if numel(unique(xx))==0
                continue
            end
            
            % trim events to pixel map                 
            evtMap = evtMap.*p1.pixMap;
            regMap = regMap.*p1.pixMap;
            dlyMap(p1.pixMap==0) = nan;   
                        
            % relative intensity for pixels
            mskIntensity = p.sePg{idx,2};
            switch p.unifBri
                case 0
                    datSeVal = (evtMap>0).*mskIntensity*p.seBri(idx);
                case 1
                    datSeVal = (evtMap>0)*p.seBri(idx)*0.5;
                case 2
                    datSeVal = (evtMap>0)*0.2;
            end
            datSeVal(datSeVal>0) = max(datSeVal(datSeVal>0),p.valMin);
                        
            % perturbate location of this event
            rgh1 = rgh1Org;
            rgw1 = rgw1Org;
            
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
    end   
    
    % post processing
    [datSim,evtLst] = sim1.postProcSim(dOut,eOut,p);
    
    % add sparklings outside domains
    if p.useSpk>0
        [datSim,evtSpk] = sim1.addSparkling(datSim,p);
        evtLstAll = [evtLst,evtSpk];
    else
        evtLstAll = evtLst;
    end
    
end













