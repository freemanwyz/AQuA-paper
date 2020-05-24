function [datSim,evtLst,seSim] = genEvt_locDrift(p,dmMap,chgStd)
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
    
    pixNumLst = cellfun(@numel,p.sePix);
    
    diTime = 3*p.dsRate;
    tLen = 4*p.dsRate;
    
    [H,W,T] = size(dOut);
    
    szRg = 450:550;
    
    gapMin = 10*p.dsRate;
    gapMax = 30*p.dsRate;
    
    % generate events in each fixed domain
    dmLst = label2idx(dmMap);
    for nn=1:numel(dmLst)
        fprintf('Domain %d\n',nn)
        
        % seed
        pix0 = dmLst{nn};
        [ih0,iw0] = ind2sub(size(dmMap),pix0);
        ihSeed = round(mean(ih0));
        iwSeed = round(mean(iw0));
        
        % event template
        sz0 = szRg(randi(numel(szRg)));
        diameter0 = 2*sqrt(sz0/pi);
        
        % put template at new center
        idxGood = find(pixNumLst>sz0/1.5 & pixNumLst<sz0*1.5);
        shapeIdx0 = idxGood(randi(numel(idxGood)));

        % generate one event
        tNow = ftLen;
        for uu=1:p.nSe
            % select new center
            d00 = rand()*diameter0*chgStd*2;
            theta00 = rand()*2*pi;
            dh00 = round(d00*sin(theta00));
            dw00 = round(d00*cos(theta00));      
            
            % pick a shape
            xMap00 = p.sePix{shapeIdx0};
            nPix00 = sum(xMap00(:)>0);
            scl00 = sqrt(sz0/nPix00);  % rescale           
            xMap00s = imresize(xMap00,ceil(size(xMap00)*scl00));
            [~,ix00s] = sort(xMap00s(:),'descend');
            xMap00b = xMap00s*0;
            xMap00b(ix00s(1:sz0)) = 1;
            
            % current mask
            [ih00,iw00] = find(xMap00b);
            ih00m = round(mean(ih00));
            iw00m = round(mean(iw00));
            dia0h = max(ih00m-min(ih00),max(ih00)-ih00m);
            dia0w = max(iw00m-min(iw00),max(iw00)-iw00m);
            dia0 = ceil(max(dia0h,dia0w));
            ih1a = min(max(ihSeed+dh00,dia0),H-dia0);
            iw1a = min(max(iwSeed+dw00,dia0),W-dia0);   
            
            ih00e = min(max(ih00-ih00m+ih1a,1),H);
            iw00e = min(max(iw00-iw00m+iw1a,1),W);
            ihw00e = sub2ind([H,W],ih00e,iw00e);    
            
            regMapx = zeros(H,W);
            regMapx(ihw00e) = 1;
            evtMap = repmat(regMapx,1,1,tLen);
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













