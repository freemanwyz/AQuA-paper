%% control recall rate

ccgt = bwconncomp(datSim>0);
voxLst = ccgt.PixelIdxList;

datx = datSim + randn(size(datSim))*0.1;
datsmo = imgaussfilt(datx,1);

xxbg = datsmo(datSim==0);
stdEst = std(xxbg);

%
dFg = datsmo>3*stdEst;
for tt=1:size(dFg,3)
    tmp = dFg(:,:,tt);
    tmp = bwareaopen(tmp,4);
    dFg(:,:,tt) = tmp;
end
cc1 = bwconncomp(dFg);

xVis = zeros(numel(voxLst),1);
for ii=1:numel(voxLst)
    vox0 = voxLst{ii};
    if sum(dFg(vox0))>0
        xVis(ii) = 1;
    end
end

sum(xVis)

