function fSv = superVoxel(dat,hrg,wrg,tVec,res)
    
    nFrames = numel(tVec);
    [H,W,~] = size(dat);
    
    ovCur = res.ov('Step 2: super voxels');
    col0 = ovCur.col;

    col0 = col0(randperm(size(col0,1)),:);
    
    fSv = figure;
    axSv = axes(fSv);
    cMap00 = gray(256);
    for ii=1:nFrames
        t00 = tVec(ii);
        d0 = dat(hrg,wrg,t00)*2;
        d0c = gray2rgbColorMap(d0,cMap00);
        
        % super voxels
        ov0 = ovCur.frame{t00};
        rMap = zeros(H,W);
        gMap = zeros(H,W);
        bMap = zeros(H,W);
        for jj=1:numel(ov0.pix)
            col00 = col0(ov0.idx(jj),:);
            rMap(ov0.pix{jj}) = ov0.val{jj}*col00(1);
            gMap(ov0.pix{jj}) = ov0.val{jj}*col00(2);
            bMap(ov0.pix{jj}) = ov0.val{jj}*col00(3);
        end
        svMap0 = cat(3,rMap,gMap,bMap);
        svMap0Sel = svMap0(hrg,wrg,:);
        dat0b = svMap0Sel/2+d0c/2;
        
        msk0 = d0*0+0.1;
        msk0(sum(svMap0Sel,3)>0) = 0.8;
        addSliceRGB(dat0b,ii,axSv,msk0);
    end
    axis off; grid off
    pbaspect([1 1 2]); camup([0 1 0])
    
end