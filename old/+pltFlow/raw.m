function fRaw = raw(dat,hrg,wrg,tVec)
    
    nFrames = numel(tVec);
    
    fRaw = figure;
    axRaw = axes(fRaw);
    cMap00 = jet(256);
    for ii=1:nFrames
        d0 = dat(hrg,wrg,tVec(ii))*2;
        d0 = imgaussfilt(d0,1);
        d0c = gray2rgbColorMap(d0,cMap00);
        addSliceRGB(d0c,ii,axRaw,d0);
    end
    axis off; grid off
    pbaspect([1 1 2]); camup([0 1 0])
    
end