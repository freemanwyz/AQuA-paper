function ff = seedWithFg(dat,hrg,wrg,tVec,res)
    
    nFrames = numel(tVec);
    [H,W,~] = size(dat);
    
    gapx = round(mean(tVec(2:end) - tVec(1:end-1)));
    
    ovCur = res.ov('Step 1: active voxels');
    locMap = zeros(size(dat));
    locMap(res.lmLoc) = 1;
    sexx = reshape(ones(1,5),1,1,gapx);
    locMap = imdilate(locMap,sexx);
    lmLoc = find(locMap);
    [ih,iw,it] = ind2sub(size(dat),lmLoc);
    
    ff = figure;
    axSeed = axes(ff);
    cMap00 = gray(256);
    for ii=1:nFrames
        t00 = tVec(ii);
        d0 = dat(hrg,wrg,t00)*2;
        
        % foreground
        ov0 = ovCur.frame{t00};
        tmpFg = zeros(H,W);
        for jj=1:numel(ov0.pix)
            tmpFg(ov0.pix{jj}) = 1;
        end
        tmpFg = tmpFg(hrg,wrg);
        
        % seeds
        xSel = it==t00;
        ih0 = ih(xSel);
        iw0 = iw(xSel);
        ihw0 = sub2ind([H,W],ih0,iw0);
        tmpSeed = zeros(H,W);
        tmpSeed(ihw0) = 1;
        tmpSeed = imdilate(tmpSeed,strel('square',3));
        tmpSeed = tmpSeed(hrg,wrg);
        
        d0c = gray2rgbColorMap(d0,cMap00);
        d0c = d0c+cat(3,tmpFg*0,tmpFg*0,tmpFg*0.5);
        tmpSeed3 = cat(3,tmpSeed,tmpSeed*0,tmpSeed*0);
        d0c = d0c.*(tmpSeed==0) + tmpSeed3;
        
        msk0 = d0*0+0.1;
        msk0(tmpFg>0) = d0(tmpFg>0)+0.1;
        msk0(tmpSeed>0) = 1;
        addSliceRGB(d0c,ii,axSeed,msk0);
    end
    axis off; grid off
    pbaspect([1 1 2]); camup([0 1 0])
    
end

