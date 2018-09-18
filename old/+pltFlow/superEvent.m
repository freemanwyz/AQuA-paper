function fSe = superEvent(dat,hrg,wrg,tVec,res)
    
    nFrames = numel(tVec);
    [H,W,~] = size(dat);    
    
    fSe = figure;
    axSe = axes(fSe);
    cMap00 = gray(256);
    ovCur = res.ov('Step 3a: super events');
    col0 = ovCur.col;
    for ii=1:nFrames
        t00 = tVec(ii);
        d0 = dat(hrg,wrg,t00)*2;
        d0 = d0*0;
        d0c = gray2rgbColorMap(d0,cMap00);
        
        % super events
        ov0 = ovCur.frame{t00};
        rMap = zeros(H,W);
        gMap = zeros(H,W);
        bMap = zeros(H,W);
        mskX = zeros(H,W);
        for jj=1:numel(ov0.pix)
            col00 = (col0(ov0.idx(jj),:));
            rMap(ov0.pix{jj}) = ov0.val{jj}*col00(1);
            gMap(ov0.pix{jj}) = ov0.val{jj}*col00(2);
            bMap(ov0.pix{jj}) = ov0.val{jj}*col00(3);
            mskX(ov0.pix{jj}) = ov0.val{jj};
        end
        dat0a = cat(3,rMap,gMap,bMap);
        dat0aSel = dat0a(hrg,wrg,:);
        dat0b = dat0aSel/1.2+d0c/2;
        
        %msk0 = d0+0.05;
        msk0 = mskX(hrg,wrg)+0.1;
        %msk0(sum(dat0aSel,3)>0) = 0.8;
        addSliceRGB(dat0b,ii,axSe,msk0);        
    end
    
    axis off; grid off
    pbaspect([1 1 2]); camup([0 1 0])
    
end