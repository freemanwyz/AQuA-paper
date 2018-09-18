function fFg = foreground(dat,hrg,wrg,tVec,res)
    
    nFrames = numel(tVec);
    [H,W,~] = size(dat);
    
    fFg = figure;
    axFg = axes(fFg);
    cMap00 = gray(256);
    ovCur = res.ov('Step 1: active voxels');
    for ii=1:nFrames
        t00 = tVec(ii);
        d0 = dat(hrg,wrg,t00)*2;
        %d0 = d0*0+0.1;
        
        ov0 = ovCur.frame{t00};
        tmpFg = zeros(H,W);
        for jj=1:numel(ov0.pix)
            tmpFg(ov0.pix{jj}) = 1;
        end
        tmpFg = tmpFg(hrg,wrg);
        
        d0c = gray2rgbColorMap(d0,cMap00);
        d0c = d0c/1.5+cat(3,tmpFg*0,tmpFg*0,tmpFg);
        msk0 = d0*0+0.1;
        msk0(tmpFg>0) = 1;
        addSliceRGB(d0c,ii,axFg,msk0);
    end
    axis off; grid off
    pbaspect([1 1 2]); camup([0 1 0])
    
end