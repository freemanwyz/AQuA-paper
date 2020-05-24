function [datSim,evtLst,seSim] = genEvt_locDrift_circle(p,dmMap,chgStd)
    % generate super events and events based on each seed
    % simulate the location drifting effects for non-ROI events
    % drifting distance relative to diameter
    % not limited by boundary. Only use the center of domain as seed
    %
    
    dOut = zeros(p.sz(1),p.sz(2),ceil(p.nSe/p.seDensity*p.dsRate),'single');
    eOut = zeros(size(dOut),'int32');
    usedMov = zeros(size(dOut),'logical');
    seSim = cell(0);
    evtCnt = 0;
    ftLen = numel(p.filter3D);
    
    diTime = 3*p.dsRate;
    tLen = 4*p.dsRate;
    
    [H,W,T] = size(dOut);
    
    szRg = 300:600;
    
    gapMin = 10*p.dsRate;
    gapMax = 30*p.dsRate;
    
    % generate events in each fixed domain
    dmLst = label2idx(dmMap);
    [ihAll,iwAll] = find(ones(size(dmMap))>0);
    for nn=1:numel(dmLst)
        fprintf('Domain %d\n',nn)
        
        % seed
        pix0 = dmLst{nn};
        [ih0,iw0] = ind2sub(size(dmMap),pix0);
        ihSeed = round(mean(ih0));
        iwSeed = round(mean(iw0));
        
        % distance to seed
        dist0 = sqrt((ihAll-ihSeed).^2+(iwAll-iwSeed).^2);
        [~,distOrder0] = sort(dist0);
        
        % event template
        sz0 = szRg(randi(numel(szRg)));
        regTemplate0 = zeros(H,W);
        regTemplate0(dist0<dist0(distOrder0(sz0))) = 1;
        [ih1,iw1] = find(regTemplate0>0);
        rgh1 = min(ih1):max(ih1);
        rgw1 = min(iw1):max(iw1);
        regTemplate0 = regTemplate0(rgh1,rgw1);
        diameter0 = 2*sqrt(sz0/pi);

        % generate one event
        tNow = ftLen;
        for uu=1:p.nSe
            % select new center
            d00 = rand()*diameter0*chgStd*2;
            theta00 = rand()*2*pi;
            dh00 = round(d00*sin(theta00));
            dw00 = round(d00*cos(theta00));            
            ih1a = min(max(ih1+dh00,round(diameter0)),H-round(diameter0));
            iw1a = min(max(iw1+dw00,round(diameter0)),W-round(diameter0));         
            
            % put template at new center
            regMapx = zeros(H,W);
            hLeft = floor(numel(rgh1)/2); hRight = numel(rgh1)-hLeft-1;
            wLeft = floor(numel(rgw1)/2); wRight = numel(rgw1)-wLeft-1;
            regMapx(ih1a-hLeft:ih1a+hRight,iw1a-wLeft:iw1a+wRight) = regTemplate0;
            evtMap = repmat(regMapx,1,1,tLen);
            
            % current mask
            regMapxDi = imdilate(regMapx,strel('square',9));
            evtMapDi = repmat(regMapxDi,1,1,tLen+2*diTime);
            
            % relative intensity for pixels
            datSeVal = (evtMap>0)*0.2;
            
            % find frame and add SE to movie
            tEvt = size(evtMap,3);
            suc = 0;
            while 1
                t0 = tNow + randi([gapMin,gapMax]);
                rgt = t0:t0+tEvt-1;
                if max(rgt)>T-ftLen
                    break
                end
                tmp = usedMov(:,:,rgt);
                if sum(tmp(evtMap>0))==0
                    suc = 1;
                    break
                end
                tNow = tNow + 5*p.dsRate;
            end
            
            if suc==0
                break
            end
            
            rgt1 = t0-diTime:t0+tEvt-1+diTime;
            if min(rgt1)<=0
                dxx = find(rgt1>0,1);
                evtMapDi = evtMapDi(:,:,dxx:end);
                rgt1 = rgt1(dxx:end);
            end
            if max(rgt1)>T
                dxx = find(rgt1<=T,1,'last');
                evtMapDi = evtMapDi(:,:,1:dxx);
                rgt1 = rgt1(1:dxx);
            end
            tNow = max(rgt)+1;
            
            dOut(:,:,rgt) = dOut(:,:,rgt) + single(datSeVal);
            evtMap(evtMap>0) = evtMap(evtMap>0)+evtCnt;
            evtCnt = max(evtMap(:));
            eOut(:,:,rgt) = max(eOut(:,:,rgt),int32(evtMap));
            usedMov(:,:,rgt1) = max(usedMov(:,:,rgt1),evtMapDi>0);
        end
    end
    
    % post processing
    [datSim,evtLst] = sim1.postProcSim(dOut,eOut,p);
    datSim = uint16(datSim*65535);
    
end













