function ff = pltFlowRaw(datSel)
    % pltFlowRaw draw raw data
    
    ff = figure;
    axRaw = axes(ff);
    [H0,W0,T0] = size(datSel);
    
    datSel = sqrt(datSel);
    
    for ii=1:T0
        img0 = 1-datSel(:,:,ii);
        img0 = medfilt2(img0);
        img0 = imgaussfilt(img0,1);
        img = repmat(img0,1,1,3);
        imgx = img*0.7;
        alphaMap = max(1-img0,0.1);
        addSliceRGB(imgx,-ii,axRaw,alphaMap);
    end

    % camera view point    
    pbaspect([W0 H0 W0*4])
    axRaw.CameraUpVector = [0 1 0];
    campos([1158,596 52]);
    axis off
end

