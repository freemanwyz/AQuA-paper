function [datSim,evtLst,seSim] = genEvt_domain_sizeChange(p,dmMap,chgStd)
    % generate super events and events based on each domain
    % simulate the size changing effects for non-ROI events
    % size from 20% to 100%, mean is 60%, and user gives s.d.
    
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
        
        pix0 = dmLst{nn};
        [ih0,iw0] = ind2sub(size(dmMap),pix0);
        rgh1 = min(ih0):max(ih0);
        rgw1 = min(iw0):max(iw0);
        pixMap = dmMap(rgh1,rgw1);
        pixMap(pixMap>0 & pixMap~=nn) = 0;
        pixMap = 1*(pixMap>0);
        
        % seed and distance to seed
        [ih,iw] = find(pixMap>0);
        ihw = sub2ind(size(pixMap),ih,iw);
        nPix = numel(ihw);
        idx0 = randi(nPix);
        ih0 = ih(idx0);
        iw0 = iw(idx0);
        d0 = bwdistgeodesic(pixMap>0,iw0,ih0,'quasi-euclidean');
        [~,s0] = sort(d0(ihw),'ascend');
        d1 = inf(size(d0));
        d1(ihw(s0)) = 1:nPix;
        
        % temporal gap between events
        gapMin = 10*p.dsRate;
        dx0 = log(dmLen(nn));
        gapMax = round(gapMin+(dxMax-dx0)*2*gapMin/max(dxMax-dxMin,1))+gapMin;
        tNow = ftLen;
        
        for uu=1:p.nSe
            %fprintf('Event %d\n',uu)
            
            % select pixel
            a0 = 1-chgStd;
            a1 = 1+chgStd;
            rt = 0.5*(rand()*(a1-a0)+a0);

            regMapx = pixMap*0;
            regMapx(d1<round(nPix*rt)) = 1;
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
    
end













