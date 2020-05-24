function res0 = aquaThr(dat,res0,opts)
    % Use raw data to determine events
    % Avoid the impact of smoothing
    
    global dbg
    
    noiseEstMask = zeros(size(dat,1),size(dat,2));
    
    datMed = zeros(size(dat));
    for ii=1:size(dat,3)
        tmp = dat(:,:,ii);
        datMed(:,:,ii) = medfilt2(tmp);
    end
    
    % foreground
    xx = (datMed(:,:,2:end)-datMed(:,:,1:end-1)).^2;
    stdMap = sqrt(median(xx,3)/0.9133);
    stdEst = double(nanmedian(stdMap(:)));
    dF = burst.getDfBlk(datMed,noiseEstMask,opts.cut,opts.movAvgWin,stdEst^2);
    
    keyboard
    
    evt = res0.evt;
    for ii=1:numel(evt)
        evt0 = evt{ii};
        xx = dF(evt0);
        evt{ii} = evt0(xx>3*stdEst);
    end
    res0.evtBak = res0.evt;
    res0.evt = evt;    
    
end