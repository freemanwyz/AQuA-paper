function [fRiseSv,fRiseSe,fRiseSeLm,fRiseEvt] = risingMap(res,xLoc)    
    % draw rising maps and events for a given location
        
    sz = res.opts.sz;
    
    riseLst = res.riseLstAll;
    riseX = res.riseX;
    sv = res.svLst;
    evt = res.evtLstAll;
    se = res.seLstAll;
    
    evtMap = zeros(sz);
    seMap = zeros(sz);
    svMap = zeros(sz);
    
    for ii=1:numel(evt)
        evtMap(evt{ii}) = ii;
    end
    for ii=1:numel(se)
        seMap(se{ii}) = ii;
    end
    for ii=1:numel(sv)
        svMap(sv{ii}) = ii;
    end
    
    seIdx = seMap(xLoc(1),xLoc(2),xLoc(3));
    if seIdx==0
        return
    end
    
    se0 = se{seIdx};
    [ih,iw,~] = ind2sub(sz,se0);
    hrg = (min(ih)-2):(max(ih)+2);
    wrg = (min(iw)-2):(max(iw)+2);
    
    tmp = evtMap(se{seIdx});
    tmp = tmp(tmp>0);
    evtIdx = unique(tmp);
    tmp = svMap(se{seIdx});
    tmp = tmp(tmp>0);
    svIdx = unique(tmp);
    
    svRise0 = nanmedian(riseX(svIdx,:),2);
    evtRise0 = riseLst(evtIdx);       
    
    % rough rising time map (riseX and sv)
    svRiseMap = nan(sz(1),sz(2));
    for ii=1:numel(svIdx)
        svVox = sv{svIdx(ii)};
        [ih,iw,~] = ind2sub(sz,svVox);
        ihw = sub2ind([sz(1),sz(2)],ih,iw);        
        svRiseMap(ihw) = svRise0(ii);
    end
    svRiseMapCrop = svRiseMap(hrg,wrg);    
    fRiseSv = figure;
    imagesc(svRiseMapCrop,'AlphaData',~isnan(svRiseMapCrop));colorbar;
    
    % super event rising time (riseLst)
    seRiseMap = nan(sz(1),sz(2));
    for ii=1:numel(evtIdx)
        r00 = evtRise0{ii};
        seRiseMap(r00.rgh,r00.rgw) = nanmax(seRiseMap(r00.rgh,r00.rgw),r00.dlyMap);  
    end  
    seRiseMapCrop = seRiseMap(hrg,wrg);        
    fRiseSe = figure;
    imagesc(seRiseMapCrop,'AlphaData',~isnan(seRiseMapCrop));colorbar;   
    
    
    % local earlist point (riseLst)
    xMap = seRiseMapCrop;
    xMap(isnan(xMap)) = Inf;
    lm = imregionalmin(xMap);
    lm = bwareaopen(lm,4);
    lmcc = bwconncomp(lm);
    lmCenterx = zeros(lmcc.NumObjects,1);
    lmCentery = lmCenterx;
    for ii=1:lmcc.NumObjects
        [ih,iw] = ind2sub(size(lm),lmcc.PixelIdxList{ii});
        lmCentery(ii) = round(mean(ih));
        lmCenterx(ii) = round(mean(iw));
    end
    
    lm3 = cat(3,lm,lm*0,lm*0);
    fRiseSeLm = figure;
    imagesc(seRiseMapCrop,'AlphaData',~isnan(seRiseMapCrop));colorbar;hold on;
    im = image(lm3); im.AlphaData = lm>0;   
        
    % events map (evt)
    evtBdMap = zeros(sz(1),sz(2));
    evtPixMap = zeros(sz(1),sz(2),3);
    for ii=1:numel(evtIdx)
        col0 = rand(1,3); col0 = col0/max(col0);
        bd0 = res.fts.bds{evtIdx(ii)};
        for jj=1:numel(bd0)
            bd00 = bd0{jj};
            pix00 = sub2ind([sz(1),sz(2)],bd00(:,2),bd00(:,1));
            evtBdMap(pix00) = ii;
        end
        pix0 = res.fts.loc.x2D{evtIdx(ii)};
        for jj=1:3
            tmp = evtPixMap(:,:,jj);
            tmp(pix0) = col0(jj);
            evtPixMap(:,:,jj) = tmp;
        end
    end
    evtPixMapCrop = evtPixMap(hrg,wrg,:);
    
    fRiseEvt = figure;
    imagesc(seRiseMapCrop,'AlphaData',~isnan(seRiseMapCrop));colorbar;hold on;
    colormap gray
    im = image(evtPixMapCrop); im.AlphaData = 0.3*(sum(evtPixMapCrop,3)>0);
    scatter(lmCenterx,lmCentery,15,'r','filled');
    %im = image(lm3); im.AlphaData = lm>0; 
    
end



