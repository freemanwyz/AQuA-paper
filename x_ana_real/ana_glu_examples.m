% analyze results for glutamate data, draw example events

folderTop = 'D:\OneDrive\projects\glia_kira\tmp\disser\transmitter\';

imgLst = {...
    'gfap-122616-slice1-baseline2-006-channel1_2_reg',...
    'hsyn-102816-Slice1-ACSF-001_reg'...
    };

fOutTop = '.\tmp_disser\';
nImg = numel(imgLst);

nn = 2;

% read data -----
resCur = load([folderTop,imgLst{nn},'\',imgLst{nn},'_aqua.mat']);
res = resCur.res;
nEvtCur = numel(res.evt);
xArea = res.fts.basic.area';
xDuration = res.fts.curve.width55';
datMean = mean(double(res.datOrg),3)/65535;
[H,W,T] = size(res.datOrg);


%% draw all events -----
xDynamic = sum(res.fts.propagation.propGrowOverall,2);
idxStatic = find(xDynamic==0);
idxDynamic = find(xDynamic>0);
[~,idx00] = sort(res.fts.loc.t0(idxDynamic));
idxDynamic = idxDynamic(idx00);

nDynamic = sum(xDynamic>0);
col0 = [0,0,1];  % gradually change to [1,0,0]
msk = zeros(H,W,3);

% dynamic
for ii = 1:numel(idxDynamic)
    evt0 = res.evt{idxDynamic(ii)};
    [ih,iw,it] = ind2sub(size(res.datOrg),evt0);
    ihw = sub2ind([H,W],ih,iw);
    c1 = msk(:,:,1);
    c3 = msk(:,:,3);
    c1(ihw) = (ii-1)/(nDynamic-1);
    c3(ihw) = 1-(ii-1)/(nDynamic-1);
    msk(:,:,1) = c1;
    msk(:,:,3) = c3;
end

% static
for ii = 1:numel(idxStatic)
    evt0 = res.evt{idxStatic(ii)};
    [ih,iw,it] = ind2sub(size(res.datOrg),evt0);
    ihw = sub2ind([H,W],ih,iw);
    c1 = msk(:,:,1);
    c2 = msk(:,:,2);
    c3 = msk(:,:,3);
    c1(ihw) = 0;
    c2(ihw) = 0.5;
    c3(ihw) = 0;
    msk = cat(3,c1,c2,c3);
end

datWithEvt = msk+datMean.^2;
zzshow(datWithEvt)
imwrite(datWithEvt,[fOutTop,imgLst{nn},'_AllEvt.png']);

% show time course -----
figure;
%raster0 = zeros(15,T);
for ii=1:min(nEvtCur,15)
    x = res.dffMat(ii,:,2);
    x = x(1:300);
    plot(x(:)-ii/5,'k');hold on
%     x = x/max(x);
    %raster0(ii,:) = x;
end
%figure;imagesc(raster0);caxis([0,1]);
%colormap(parula); colorbar


%% event example -----
lst0 = idxDynamic;
for ii=1:numel(lst0)
    evt0 = res.evt{lst0(ii)};
    [ih,iw,it] = ind2sub(size(res.datOrg),evt0);
    rgh = max(min(ih)-20,1):min(max(ih)+20,H);
    rgw = max(min(iw)-20,1):min(max(iw)+20,W);
    
    fprintf('%d,%d\n',ii,numel(rgw));
    
    datSelAll = double(res.datOrg(:,:,min(it):max(it)));
    datSelAll = datSelAll/max(datSelAll(:))/2;
    for tt=1:size(datSelAll,3)
        tx = min(it)+tt-1;
        ih0 = ih(it==tx);
        iw0 = iw(it==tx);
        ihw0 = sub2ind([H,W],ih0,iw0);
        
        datLvl0 = double(res.datRAll(:,:,tx))/255;
        datMsk0 = zeros(H,W); datMsk0(ihw0) = 1;
        datMsk0 = datMsk0.*datLvl0;
        datSel = datSelAll(:,:,tt);
        datOv0 = cat(3,datSel+datMsk0,datSel,datSel);
        datOv0 = datOv0(rgh,rgw,:);
        fOut = [fOutTop,'Image ',num2str(nn),' event ',num2str(ii),...
            ' ',num2str(min(it)+tt-1),'.png'];
        imwrite(datOv0,fOut);
    end
end

