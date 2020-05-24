function [datSim,evtLst,seSim] = genEvt_domain_roi(p,dmMap)
    % generate super events and events based on each domain
    % simulate pure ROI
    
    dOut = zeros(p.sz(1),p.sz(2),ceil(p.nSe/p.seDensity*p.dsRate),'single');
    eOut = zeros(size(dOut),'int32');
    seSim = cell(0);
    evtCnt = 0;
    ftLen = numel(p.filter3D);
    tLen = 4*p.dsRate;
    
    % generate events in each fixed domain
    dmLst = label2idx(dmMap);
    dmLen = cellfun(@numel,dmLst);
    dxMin = log(min(dmLen));
    dxMax = log(max(dmLen));
    for nn=1:numel(dmLst)
        fprintf('Domain %d\n',nn)

        dx0 = log(dmLen(nn));
        
        pix0 = dmLst{nn};
        [ih0,iw0] = ind2sub(size(dmMap),pix0);
        rgh1 = min(ih0):max(ih0);
        rgw1 = min(iw0):max(iw0);
        pixMap = dmMap(rgh1,rgw1);
        pixMap(pixMap>0 & pixMap~=nn) = 0;
        pixMap = 1*(pixMap>0);
        
        % temporal gap between events
        gapMin = 10*p.dsRate;
        gapMax = round(gapMin+(dxMax-dx0)*2*gapMin/max(dxMax-dxMin,1))+gapMin;
        tNow = ftLen;
        
        for uu=1:p.nSe            
            regMapx = pixMap;
            evtMap = repmat(regMapx,1,1,tLen);
            
            % relative intensity for pixels
            datSeVal = (evtMap>0)*0.2;
            datSeVal(datSeVal>0) = max(datSeVal(datSeVal>0),p.valMin);
            
            % find frame and add SE to movie
            t0 = tNow + randi([gapMin,gapMax]);
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
    evtLst = evtLst(~cellfun(@isempty,evtLst));
    
end













