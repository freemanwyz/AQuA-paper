function [regMap,delayMap,pixLst] = growSeed(seedIdx,initTime,sucRt,regMask,p)
    % events from all seeds must merge to single component
    
    H = p.sz(1);
    W = p.sz(2);
    nEvt = numel(seedIdx);
    
    % a bound on propagation steps
    %nStpGrow = p.dist/p.xSeedLoc/p.sucRtOverall;
    nStpGrow = 1e4;
    
    regMap = zeros(H,W);
    regMap(seedIdx) = 1:nEvt;
    delayMap = nan(H,W);
    delayMap(seedIdx) = initTime;
    pixLst = num2cell(seedIdx);
    
    dh = [0 -1 1 0];
    dw = [-1 0 0 1];
    gap1 = 1/p.xOverSample;
    for tt=1:gap1:nStpGrow
        nNow = sum(regMap(:)>0);
        if nNow/p.nPix>=0.5
            cc = bwconncomp(regMap>0,4);
            if cc.NumObjects==1 && nNow/p.nPix>=0.9
                break
            else
                sucRt = sucRt*1;  % 1.05 or 1.1 for more natural growth
            end
        end
        for nn=1:nEvt
            if tt<=initTime(nn)
                continue
            end
            suc0 = sucRt(nn);
            pix0 = pixLst{nn};
            tGap = max(delayMap(pix0))-initTime(nn);
            tScl = max(tGap^p.speedUpProp/5,1);
            [ih0,iw0] = ind2sub([H,W],pix0);
            for ii=randperm(numel(dh))
                ih0a = min(max(ih0+dh(ii),1),H);
                iw0a = min(max(iw0+dw(ii),1),W);
                pix0a = sub2ind([H,W],ih0a,iw0a);
                pix0a = pix0a(regMap(pix0a)==0);  % not visited yet
                pix0a = pix0a(p.fg(pix0a)>0);  % in foreground
                if ~isempty(regMask)  % use same mask as previous round
                    pix0a = pix0a(regMask(pix0a)==nn);
                end
                isSuc = rand(size(pix0a))>1-p.sucRtBase(pix0a)*suc0*tScl;
                pix0a = pix0a(isSuc);
                pix0 = union(pix0,pix0a);
                regMap(pix0a) = nn;
                delayMap(pix0a) = floor(tt);
            end
            
            % fill small holes
            regx = regMap==nn;
            xhole = find(imfill(regx,'holes')-regx);
            regMap(xhole) = nn;
            pix0 = union(pix0,xhole);
            
            % fill delay time
            for ii=1:numel(xhole)
                [ih00,iw00] = ind2sub([H,W],xhole(ii));
                rgh00 = max(ih00-2,1):min(ih00+2,H);
                rgw00 = max(iw00-2,1):min(iw00+2,W);
                x00 = delayMap(rgh00,rgw00);
                delayMap(ih00,iw00) = nanmean(x00(:));
            end
            
            pixLst{nn} = pix0;
        end
    end
    
end



