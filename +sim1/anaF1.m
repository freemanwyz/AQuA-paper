function [prMov,rcMov,f1Mov] = anaF1(rDt,gt,thrxx,mthdX)
       
    nNoise = numel(gt.noise);
    evtGt = gt.evt;
    evtGtPix = gt.pix;
    
    [evtDtLst,evtDtPixLst] = sim1.anaExtractDt(rDt,mthdX,thrxx,gt.sz);
        
    % multiple criteria for detected
    % Ground truth vs detected
    % Each item has area 50%, 25%, 10%, volume 50%, 25%, 10%
    hitLst = cell(nNoise,2);
    mType = [0,0,0,1,1,1]; % 0: area, 1: volume
    thrX = [0.5,0.25,0.1,0.5,0.25,0.1];
    
    gtSz = cellfun(@numel,evtGt);  % event size
    [~,gtSzIdx] = sort(gtSz,'descend');
    
    for ii=1:nNoise        
        evtDt = evtDtLst{ii};
        fprintf('SNR %d # %d\n',ii,numel(evtDt));
        gtHit = zeros(numel(evtGt),6);
        dtHit = zeros(numel(evtDt),6);
        
        % event map for detected
        evtMap0 = zeros(gt.sz);
        for jj=1:numel(evtDt)
            evtMap0(evtDt{jj}) = jj;
        end
        
        % hit or miss
        for gtNow=gtSzIdx  % begin with largest one
            vox0 = evtGt{gtNow};
            pix0 = evtGtPix{gtNow};
            
            xOver = evtMap0(vox0);
            xOver = xOver(xOver>0);
            
            for kk=1:numel(mType)
                xOver = xOver(dtHit(xOver,kk)==0);  % not paired yet
                if ~isempty(xOver)
                    [ix,~,ic] = unique(xOver);
                    ixCnt = accumarray(ic,1);  % count each index
                    [~,ix1] = max(ixCnt);
                    dtSel = ix(ix1);  % choose highest overlapping one
                    
                    pix1 = evtDtPixLst{ii}{dtSel};
                    vox1 = evtDtLst{ii}{dtSel};
                    
                    voxOver = numel(intersect(vox0,vox1));
                    pixOver = numel(intersect(pix0,pix1));
                    
                    if mType(kk)==0
                        rt1 = voxOver/numel(vox0);
                        rt2 = voxOver/numel(vox1);
                    else
                        rt1 = pixOver/numel(pix0);
                        rt2 = pixOver/numel(pix1);
                    end
                    if rt1>=thrX(kk) && rt2>=thrX(kk)
                        gtHit(gtNow,kk) = 1;
                        dtHit(dtSel,kk) = 1;
                    end
                end
            end
        end
        hitLst{ii,1} = gtHit;
        hitLst{ii,2} = dtHit;
    end
        
    % precision-recall-f1
    prMov = nan(nNoise,6);
    rcMov = prMov;
    for ii=1:nNoise
        x = hitLst{ii,1};
        rcMov(ii,:) = sum(x,1)./size(x,1);
        x = hitLst{ii,2};
        prMov(ii,:) = sum(x,1)./size(x,1);
    end
    f1Mov = 2*prMov.*rcMov./(prMov+rcMov);
    
end




