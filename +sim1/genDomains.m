function [domainMap,domainSeIdx] = genDomains(p)
    % generate domains for simulation
    
    nSeEx = numel(p.se);

    seLen = zeros(nSeEx,1);
    for ii=1:nSeEx
        x0 = p.sePix{ii};
        seLen(ii) = sum(x0(:)>0);
    end
    switch p.domainType
        case 'large'
            [~,seLenIx] = sort(seLen,'descend');
        case 'average'
            seLenIx = find(seLen>50 & seLen<500);
        case 'random'
            seLenIx = find(seLen>30);
    end
    
    domainMap = zeros(p.sz(1),p.sz(2));
    domainMapDi = zeros(p.sz(1),p.sz(2));
    seUsed = zeros(nSeEx,1);
    domainSeIdx = zeros(nSeEx,1);
    
    for nn=1:p.nDomain
        fprintf('Domain: %d\n',nn)
        
        % get one domain
        suc = 0;
        for ii = 1:nSeEx
            idx = seLenIx(ii);
            if seUsed(idx)>0
                continue
            end
            
            regMap = p.sePix{idx};
            rgh1 = p.seRg(idx,1):p.seRg(idx,2);
            rgw1 = p.seRg(idx,3):p.seRg(idx,4);
            rgh2 = max(min(rgh1)-5,1):min(max(rgh1)+5,p.sz(1));
            rgw2 = max(min(rgw1)-5,1):min(max(rgw1)+5,p.sz(2));
            regMap1 = zeros(numel(rgh2),numel(rgw2));
            regMap1(rgh1-min(rgh2)+1,rgw1-min(rgw2)+1) = regMap>0;
            %regMap1 = imfill(regMap1,'holes');
            %regMap1 = bwmorph(regMap1,'spur');
            regMap1Di = imdilate(regMap1,strel('square',11));
            msk = domainMapDi(rgh2,rgw2);
            
            if msk(regMap1Di>0)==0
                suc = 1;
                domainMap(rgh2,rgw2) = max(domainMap(rgh2,rgw2),regMap1*nn);
                domainMapDi(rgh2,rgw2) = max(domainMapDi(rgh2,rgw2),regMap1);
                domainSeIdx(nn) = idx;
                break
            end
        end
        if suc==0
            break
        end
    end   
    
end


