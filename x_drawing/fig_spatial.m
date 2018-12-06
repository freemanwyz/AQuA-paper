%% flowchart 2D maps
% !! event 1 drawn by hand earlier than event two - adjust delay maps

folderTop = getWorkPath();
folderAnno = [folderTop,'x_paper\labels\'];
fDat = 'FilteredNRMCCyto16m_slice2_TTX3_L2 3-012cycle1channel1';

rghCrop = 12:190;
rgwCrop = 11:67;

% propagation with two events
[datSel,msk,dat,tVec] = readEvtAnno(folderAnno,fDat,'prop1_less',...
    rghCrop,rgwCrop,'upDown');
[L,Lrgb,sLoc] = msk2sv(msk,datSel,2000);

% event map
evtMap = zeros(size(L));
for ii=1:size(msk,3)
    tmp = msk(:,:,ii);
    for jj=1:max(tmp(:))
        idx1 = find(tmp==jj);
        idxNow = evtMap(idx1);
        idxNow(idxNow==0) = jj;
        evtMap(idx1) = idxNow;
    end
end


%% rising time
pixMap = sum(msk,3)>0;
svLst = label2idx(L);
nSv = numel(svLst);
datVec = reshape(dat,[],size(dat,3));

val0 = 5;
val1 = 10;

% rising edge for super pixels
riseMap = nan(size(pixMap));
riseMapOrg = nan(size(pixMap));
for ii=1:nSv
    sv0 = svLst{ii};
    
    x = datVec(sv0,:);
    xm = mean(x,1);
    xs = std(x,0,1);
    xs0 = mean(xs)/sqrt(numel(sv0));
    xb0 = min(xm)+xs0;
    z0 = (xm-xb0)./xs0;
    
    rise0 = nan(1,100);
    for tt=5:numel(z0)
        zx = min(round(z0(tt)),100);
        rise0(1:zx) = nanmin(rise0(1:zx),tt);
    end
    
    rise00 = nanmean(rise0);
    riseMapOrg(sv0) = rise00;
    if mode(evtMap(sv0))==2  % !! make event 2 later
        rise00 = 0.5*(rise00-val0)+val0+(val1-val0)*0.5;
    end
    riseMap(sv0) = rise00;
end

riseMap(riseMap<val0) = val0;
riseMap(riseMap>val1) = val1;

riseMapMed = medfilt2Nan(riseMap,1);

% delay maps
fDelay = figure;
imagesc(riseMapMed,'AlphaData',~isnan(riseMap));colorbar;
axis image  % DataAspectRatio
axis off

% delay maps, but darker
fDelayDim = figure;
imagesc(riseMapMed,'AlphaData',~isnan(riseMap)*0.3);colorbar;
axis image  % DataAspectRatio
axis off

print(fDelay,'flow_se_rise_time.svg','-dsvg','-r800');
print(fDelayDim,'flow_se_rise_time_transparent.svg','-dsvg','-r800');


%% find smooth domains
idx = find(L>0);
L0 = L*0;
L0(idx) = 1:numel(idx);

spLst = label2idx(L0);
nSp = numel(spLst);
distMat = nan(nSp,nSp);
[H,W] = size(L0);

% rising time for each sp
tRiseSp = nan(nSp,1);
for ii=1:nSp
    sp0 = spLst{ii};
    tRiseSp(ii) = nanmedian(riseMapOrg(sp0));    
end

% distance matrix
dh = [0 -1 1 0];
dw = [-1 0 0 1];
for ii=1:nSp
    sp0 = spLst{ii};
    t0 = tRiseSp(ii);
    [ih0,iw0] = ind2sub([H,W],sp0);
    neib0 = ii;
    % find neighbors
    for kk=1:numel(dh)
        ih1 = min(max(ih0+dh(kk),1),H);
        iw1 = min(max(iw0+dw(kk),1),W);       
        pix1 = sub2ind([H,W],ih1,iw1);
        neib1 = L0(pix1);
        neib1 = neib1(neib1>0);
        neib0 = union(neib0,neib1);
    end
    % fill matrix
    for kk=1:numel(neib0)
        t1 = tRiseSp(neib0(kk));
        distMat(ii,neib0(kk)) = abs(t0-t1);
        distMat(neib0(kk),ii) = abs(t0-t1);
    end
end

% connected components
connMat = double(~isnan(distMat) & distMat<0.5);
G = graph(connMat);
cc = conncomp(G,'OutputForm','cell');
[~,ix] = sort(cellfun(@numel,cc),'descend');
cc = cc(ix);

colx = [0 0 1;1 0 0; 1 0 0; 1 0 0];
L1 = zeros(H,W,3);
L1x = zeros(H,W);
L1y = zeros(H,W);
u = 0;
for ii=1:numel(cc)
    cc0 = cc{ii};
    for jj=1:numel(cc0)
        pix0 = spLst{cc0(jj)};
        for kk=1:3
            tmp = L1(:,:,kk);
            if ii==1
                tmp(pix0) = colx(1,kk);
                L1x(pix0) = 1;
            else
                tmp(pix0) = colx(mod(u,3)+2,kk);
                L1y(pix0) = 1;
            end
            L1(:,:,kk) = tmp;
        end
    end
    u = u+1;
end
L1x = imfill(L1x,'holes');

evtMap(L1x==0) = 0;

% smooth domain, blue for main part and red for outlier
L1bg = L1+sqrt(mean(dat,3));
fL1 = figure;
image(L1bg);
axis image
axis off
print(fL1,'flow_se_smooth_domain.svg','-dsvg','-r800');


%% delay maps
% cleaned delay map
fDelay1 = figure;
riseMapMed1 = riseMapMed.*(evtMap>0);
riseMapMed1(riseMapMed1==0) = nan;
imagesc(riseMapMed1,'AlphaData',evtMap>0);colorbar;
axis image
axis off

% cleaned delay map, but darker
fDelay1Dim = figure;
imagesc(riseMapMed1,'AlphaData',(evtMap>0)*0.3);colorbar;
axis image
axis off

% cleaned delay map in gray color
tMap1 =  nanmax(riseMapMed(:))-riseMapMed+1;
tMap1 = tMap1/nanmax(tMap1(:));
tMap1(evtMap==2) = tMap1(evtMap==2).^1.2;  % !! make event 2 darker
evtCol = cat(3,(evtMap==2).*tMap1,evtMap*0,(evtMap==1).*tMap1);

fDelayGray = figure;  % get gray colorbar
imagesc(riseMapMed.*L1x);colormap('gray');colorbar
axis image
axis off

print(fDelay1,'flow_se_rise_time_smooth_domain.svg','-dsvg','-r800');
print(fDelay1Dim,'flow_se_rise_time_smooth_domain_transparent.svg','-dsvg','-r800');
print(fDelayGray,'flow_se_rise_time_gray.svg','-dsvg','-r800');


%% events
fEvt = figure;
image(evtCol);
axis image
axis off

% delay map for single event (the larger one)
tMap1 =  nanmax(riseMapMed(:))-riseMapMed+3;
tMap1 = tMap1/nanmax(tMap1(:));
evtColOne = cat(3,evtMap*0,evtMap*0,(evtMap==1).*tMap1);

fEvtOne = figure;
image(evtColOne);
axis image
axis off

print(fEvt,'flow_evt.svg','-dsvg','-r800');
print(fEvtOne,'flow_evt_single.svg','-dsvg','-r800');









