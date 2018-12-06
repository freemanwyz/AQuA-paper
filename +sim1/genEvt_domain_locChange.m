function [datSim,evtLst,q] = genEvt_domain_locChange(p,dmMap,chgStd)
    % genEvt_domain_locChange generate events based on each domain
    % simulate the location drifting effects for non-ROI events
    % 
    % each event takes szRatio of domain size
    % relative distance of event centers to domain centroid is abs(N(0,1))
    % the distances are normalized by radius of the event at centroid
    %
    % domain centroid -> distance -> radius
    % for loop: event center -> distance -> event
    %
    
    tLen = 4*p.dsRate;  % event length
    szRatio = 0.2;  % event spatial size ratio to domains
    T = ceil(p.nSe/p.seDensity*p.dsRate);  % movie frames
    
    dOut = zeros(p.sz(1),p.sz(2),T,'single');
    eOut = zeros(size(dOut),'int32');
    ftLen = numel(p.filter3D);
    
    % generate events in each fixed domain
    dmLst = label2idx(dmMap);
    dmLen = cellfun(@numel,dmLst);
    dLMin = log(min(dmLen));
    dLMax = log(max(dmLen));
    dLDif = max(dLMax-dLMin,1);
    gapMin = 10*p.dsRate;
    
    q = [];
    locDist = [];
    locDistNorm = [];
    
    for nn=1:numel(dmLst)
        fprintf('Domain %d\n',nn)
        
        % event location and spatial footprint
        pix0 = dmLst{nn};
        [ih0,iw0] = ind2sub(size(dmMap),pix0);
        rgh1 = min(ih0):max(ih0);
        rgw1 = min(iw0):max(iw0);
        pixMap = dmMap(rgh1,rgw1);
        pixMap(pixMap>0 & pixMap~=nn) = 0;
        pixMap = 1*(pixMap>0);
        
        % temporal gap between events
        % smaller event has lower frequency
        dL0 = log(dmLen(nn));
        gapMax = round(gapMin+(dLMax-dL0)*2*gapMin/dLDif)+gapMin;
        tNow = ftLen;
        
        % seed and event size
        % using centroid
        [ih,iw] = find(pixMap>0);
        d0 = sum((ih-ih').^2 + (iw-iw').^2,2);
        [~,idx0] = min(d0);
        ih0 = ih(idx0);
        iw0 = iw(idx0);        
        ihw = sub2ind(size(pixMap),ih,iw);
        nPix = numel(ihw);
        nPixEvt = round(nPix*szRatio);
        
        % distance and radius
        d0 = bwdistgeodesic(pixMap>0,iw0,ih0,'quasi-euclidean');
        [~,s0] = sort(d0(ihw),'ascend');
        d1 = inf(size(d0));
        d1(ihw(s0)) = 1:nPix;
        %rEvt = d0(d1==nPixEvt);
        rMax = d0(d1==nPix); 
        %rtMax = rMax/rEvt;        
        
        [ih0a,iw0a] = find(d1==nPixEvt);
        r00 = sqrt((ih0-ih0a).^2+(iw0-iw0a).^2);

        for uu=1:p.nSe            
            % select pixel based on distance            
            rt = rand()*chgStd*rMax;
            [~,seed0] = min(abs(d0(:)-rt));
            
            % distance map based on seed
            d0a = bwdistgeodesic(pixMap>0,seed0,'quasi-euclidean');
            [~,s0a] = sort(d0a(ihw),'ascend');
            d1a = inf(size(d0a));
            d1a(ihw(s0a)) = 1:nPix;
            
            regMapx = pixMap*0;
            regMapx(d1a<round(nPixEvt)) = 1;
            evtMap = repmat(regMapx,1,1,tLen);
            
            % find drifting distance
            [ih2,iw2] = ind2sub(size(pixMap),seed0);
            dist00 = sqrt((ih2-ih0).^2+(iw2-iw0).^2);
            dist00Norm = dist00/r00;
            locDist(end+1) = dist00; %#ok<AGROW>
            locDistNorm(end+1) = dist00Norm; %#ok<AGROW>
            
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
            evtCnt = double(max(eOut(:)));
            evtMap(evtMap>0) = evtMap(evtMap>0)+evtCnt;
            eOut(rgh1,rgw1,rgt) = max(eOut(rgh1,rgw1,rgt),int32(evtMap));                       
        end
    end
    
    % post processing
    [datSim,evtLst] = sim1.postProcSim(dOut,eOut,p);
    datSim = uint16(datSim*65535);
    
    q.locDist = locDist;
    q.locDistNorm = locDistNorm;
    
end













