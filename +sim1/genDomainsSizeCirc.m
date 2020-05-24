function [domainMap,domainSeIdx] = genDomainsSizeCirc(p)
    % generate domains for simulation
    % different size and circularity distribution
    % super events not need to be the location in real data
    %
    
    % collect valid regions
    nSeEx = numel(p.se);
    dSize = zeros(nSeEx,1);
    dCirc  = inf(nSeEx,1);
    
    for ii=1:nSeEx
        regMap = p.sePix{ii};
        dSize(ii) = sum(regMap(:)>0);
        if dSize(ii)>0
            p00 = regionprops(regMap>0,'Perimeter');
            s00 = sum(regMap(:)>0);
            dCirc(ii) = pi*(p00.Perimeter/2/pi)^2/s00;
        end
    end
    
    % select domains
    nDomainsTgt = 100;
    dsLog = log10(dSize+1);
    szMed = round(median(dsLog(dsLog>log10(25))))+p.dxOfst;
    szRg = [szMed-p.dxSz,szMed+p.dxSz];
    seLenIx = find(dsLog>szRg(1) & dsLog<szRg(2) & dCirc<p.circMax & dSize>25);
    seLenIx = datasample(seLenIx,nDomainsTgt);
    
    % build domain map
    domainMap = zeros(p.sz(1),p.sz(2));
    domainMapDi = zeros(p.sz(1),p.sz(2));
    domainSeIdx = zeros(0,1);
    
    % get one domain
    nDom = 1;
    for ii = 1:numel(seLenIx)
        fprintf('Domain %d\n',ii)
        
        idx = seLenIx(ii);
        regMap = p.sePix{idx};
        
        % get super event
        rgh1 = p.seRg(idx,1):p.seRg(idx,2);
        rgw1 = p.seRg(idx,3):p.seRg(idx,4);
        rgh2 = max(min(rgh1)-p.gapxy,1):min(max(rgh1)+p.gapxy,p.sz(1));
        rgw2 = max(min(rgw1)-p.gapxy,1):min(max(rgw1)+p.gapxy,p.sz(2));
        regMap1 = zeros(numel(rgh2),numel(rgw2));
        regMap1(rgh1-min(rgh2)+1,rgw1-min(rgw2)+1) = regMap>0;
        regMap1Di = imdilate(regMap1,strel('square',11));
        
        % locations where domain can live
        validPixMap = zeros(p.sz(1),p.sz(2));
        validPixMap(1:end-numel(rgh2),1:end-numel(rgw2)) = 1;
        validPixMap = validPixMap.*(domainMapDi==0);
        pixCand = find(validPixMap(:)>0);
        
        % randomly pick a location for this domain
        suc = 0;
        for tt=1:1000
            pix0 = pixCand(randi(numel(pixCand)));
            [ih0,iw0] = ind2sub(p.sz(1:2),pix0);
            rgh2a = ih0:ih0+numel(rgh2)-1;
            rgw2a = iw0:iw0+numel(rgw2)-1;
            msk = domainMapDi(rgh2a,rgw2a);
            
            if sum(msk(regMap1Di(:)>0))==0
                suc = 1;
                domainMap(rgh2a,rgw2a) = max(domainMap(rgh2a,rgw2a),regMap1*nDom);
                domainMapDi(rgh2a,rgw2a) = max(domainMapDi(rgh2a,rgw2a),regMap1Di);
                domainSeIdx(nDom) = idx;
                nDom = nDom+1;
                break
            end
        end
        if suc==0
            %break
        end
    end
    
end


