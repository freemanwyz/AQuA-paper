%% Migrating events
startup
rng(8)

% folderDat = 'D:\OneDrive\projects\glia_kira\se_aqua\dat\invivo_1x_reg_200\';
% fDat = '2826451(4)_1_2_4x_reg_200um_dualwv-001_nr';
folderDat = 'D:\OneDrive\projects\glia_kira\raw_proc\GCaMP_May17\Lck_Gcamp with Aldh1l1-tdtomato\';
fDat = '1_2_4x_reg_200um_dualwv-001_6_nr';
% folderDat = 'D:\OneDrive\projects\glia_kira\raw\old\';
% fDat = 'TSeries-04192016-1625-013_Galvos_1xzoom_~1.3hz  20 minutes of large population activity';

fprintf('Reading ...\n')
dat = io.readTiffSeq([folderDat,fDat,'.tif']);
dat = dat(11:end-10,11:end-10,:);
dat = dat/max(dat(:));
datSmo = imgaussfilt3(dat,1);
dat = sqrt(dat);
[H,W,T] = size(dat);

fprintf('Noise ...\n')
% datMov = movmean(dat,100,3);
% dBg = min(datMov,[],3);
dBg = median(dat,3);
dF = dat - dBg;
% dFSmo = imgaussfilt3(dF,0.5);
s = noiseInData(dF);
dFSmo = datSmo - dBg;

%%
fprintf('Foreground ...\n')
dFg = dFSmo>s;
dFg = bwareaopen(dFg,12,6);

fprintf('Fill holes ...\n')
for tt=1:T
    tmp = dFg(:,:,tt);
    dFg(:,:,tt) = imfill(tmp,'holes');
end
cc = bwconncomp(dFg,6);
ccLen = cellfun(@numel,cc.PixelIdxList);

fprintf('Intensity ...\n')
dfx = nan(1,cc.NumObjects);
for ii=1:cc.NumObjects
    pix0 = cc.PixelIdxList{ii};
    dfx(ii) = mean(dF(pix0));
    %dfx(ii) = max(dFSmo(pix0));
end
figure;hist(dfx)


%% CFU
evtFil = ccLen<10000 & dfx>0.32;
evtLst = cc.PixelIdxList(evtFil);
dfxSel = dfx(evtFil);

fprintf('CFU ...\n')

% CIPS
if 1
    reMappedBins = candReg(evtLst,size(dFg),0.2);
end

% WYZ
if 0
    [ loc2d,locy,locx,loct,locRad,actReg ] = getLocProp( evtLst,size(dFg) );
    [reMappedBins,evtCenter,evtIso] = mdCanCenter1(locy,locx,locRad,6,1,2:3);
end

cntx = cellfun(@numel,reMappedBins);
bins = reMappedBins(cntx>5);
ix = randperm(numel(bins));
bins = bins(ix);

%% show CFUs
mskLst = cell(0);
mixLst = cell(0);
tVecLst = cell(0);
dmLst = cell(0);
evtBriLst = cell(0);
rghLst = cell(0);
rgwLst = cell(0);

for ii=1:numel(bins)
    grp0 = bins{ii};
    ih0 = [];
    iw0 = [];
    for jj=1:numel(grp0)
        pix0 = evtLst{grp0(jj)};
        [ih00,iw00,~] = ind2sub([H,W,T],pix0);
        ih0 = union(ih0,ih00);
        iw0 = union(iw0,iw00);
    end
    rgh = max(min(ih0)-3,1):min(max(ih0)+3,H);
    rgw = max(min(iw0)-3,1):min(max(iw0)+3,W);
    
    dat0 = dat(rgh,rgw,:);
    dm0 = mean(reshape(dat0,[],T),1);
    tvec0 = cell(1,numel(grp0));
    evtbri0 = cell(1,numel(grp0));
    
    % draw events
    msk0x = zeros(numel(rgh),numel(rgw),numel(grp0));
    mix0x = zeros(numel(rgh),numel(rgw)*3,numel(grp0));
    for jj=1:numel(grp0)
        pix00 = evtLst{grp0(jj)};
        [ih,iw,it] = ind2sub([H,W,T],pix00);
        itrg = min(it):max(it);
        tvec0{jj} = itrg;
        
        ihw = sub2ind([H,W],ih,iw);
        ihw = unique(ihw);
        tmp = zeros(H,W);
        tmp(ihw) = 1;
        tmp = imfill(tmp,'holes');
        tmp_msk = tmp(rgh,rgw);
        
        tmp_dF = mean(dF(rgh,rgw,itrg),3)*2;
        tmp_dat = mean(dat(rgh,rgw,itrg),3).^2*2;
        
        msk0x(:,:,jj) = tmp_msk*jj;
        evtbri00 = nan(numel(itrg),1);
        for tt=1:numel(itrg)
            itSel = it==itrg(tt);
            ihSel = ih(itSel);
            iwSel = iw(itSel);
            ihwSel = sub2ind([H,W],ihSel,iwSel);
            xSel = dF(:,:,itrg(tt));
            evtbri00(tt) = mean(xSel(ihwSel));
        end
        evtbri0{jj} = evtbri00;
        
        mix0x(:,:,jj) = cat(2,tmp_msk,tmp_dF,tmp_dat);
    end
    zzshow(mix0x,num2str(ii))
    
    mskLst{ii} = msk0x;
    mixLst{ii} = mix0x;
    tVecLst{ii} = tvec0;
    dmLst{ii} = dm0;
    evtBriLst{ii} = evtbri0;
    rghLst{ii} = rgh;
    rgwLst{ii} = rgw;
    
    keyboard
    close
end


%% prepare one CFU to output
nNow = 9;  % selected CFU
eSel = 1:numel(bins{nNow});  % selected events

grp0 = bins{nNow}; grp0 = grp0(eSel);
msk0x = mskLst{nNow}; msk0x = msk0x(:,:,eSel);
dm0 = dmLst{nNow};
evtbri0 = evtBriLst{nNow}; evtbri0 = evtbri0(eSel);
tvec0 = tVecLst{nNow}; tvec0 = tvec0(eSel);
rgh = rghLst{nNow};
rgw = rgwLst{nNow};

% frames to draw
[~,ix] = sort(dm0);
tBg = ix(1:2*numel(grp0)+1);
tDraw = cell2mat(tvec0);
tShow = [tDraw,tBg];

% same mask for frames in one event
msk0 = zeros(numel(rgh),numel(rgw),numel(tShow));
xNow = 0;
for ii=1:numel(tvec0)
    tvec00 = tvec0{ii};
    msk0(:,:,xNow+1:xNow+numel(tvec00)) = repmat(msk0x(:,:,ii),1,1,numel(tvec00));
    xNow = xNow + numel(tvec00);
end

% raw data for events
datCrop = dat(rgh,rgw,:).^2;
dfCrop = dF(rgh,rgw,:);
datCropSmo = imgaussfilt3(datCrop,0.5);
datShow = datCropSmo(:,:,tShow);
datShow(datShow<0) = 0;
datShow = datShow./max(datShow(:));

% brightness for labelling
evtbri1 = zeros(numel(grp0),T);
for ii=1:numel(evtbri0)
    evtbri1(ii,tvec0{ii}) = evtbri0{ii};
end
evtbri1 = evtbri1/max(evtbri1(:));


%% write events in one CFU
xType = 'migInvivo';
cols = colormap('lines');
addCol = 0;
close all
for ii=1:size(datShow,3)
    dat00 = datShow(:,:,ii);
    
    figure;
    imagesc(dat00);
    axis off
    axNow = gca;
    axNow.DataAspectRatio = [1 1 1];
    colormap('gray');hold on
    caxis([0 1])
    
    if addCol
        msk00 = msk0(:,:,ii);
        idx = msk00(msk00>0);
        idx = unique(idx);
        for jj=1:numel(idx)  % multiple events in a frame
            tmp = msk00==idx(jj);
            tmp = imdilate(tmp,strel('square',3));
            cc00 = bwboundaries(tmp,'noholes');
            colxx = cols(idx(jj),:);
            colxx1 = colxx*evtbri1(idx(jj),tShow(ii));
            for kk=1:numel(cc00)  % multiple regions in one event in this frame
                cc00x = cc00{kk};
                patch(cc00x(:,2),cc00x(:,1),colxx1,'FaceAlpha',0.2,...
                    'EdgeColor','k','LineWidth',1);
                hold on
            end
        end
    end
    export_fig(['./tmp/evt_',xType,'_',sprintf('%04d',tShow(ii)),'.tif']);
    close
end






