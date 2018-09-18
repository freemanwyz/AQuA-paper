%% Migrating events
% in vivo

startup
rng(8)

% folderDat = 'D:\OneDrive\projects\glia_kira\se_aqua\dat\invivo_1x_reg_200\';
% fDat = '2826451(4)_1_2_4x_reg_200um_dualwv-001_nr';

folderDat = 'D:\OneDrive\projects\glia_kira\raw_proc\GCaMP_May17\Lck_Gcamp with Aldh1l1-tdtomato\';
fDat = '1_2_4x_reg_200um_dualwv-001_4_nr';

% folderDat = 'D:\OneDrive\projects\glia_kira\raw\old\';
% fDat = 'TSeries-04192016-1625-013_Galvos_1xzoom_~1.3hz  20 minutes of large population activity';

dat = io.readTiffSeq([folderDat,fDat,'.tif']);
dat = dat(11:end-10,11:end-10,:);
dat = dat/max(dat(:));
datSmo = imgaussfilt3(dat,1);
dat = sqrt(dat);
[H,W,T] = size(dat);

datMov = movmean(dat,100,3);
dBg = min(datMov,[],3);
dF = dat - dBg;
s = noiseInData(dF);
dFSmo = imgaussfilt3(dF,1);

dFg = dF>3*s;
dFg = bwareaopen(dFg,12,6);
for tt=1:T
    tmp = dFg(:,:,tt);
    dFg(:,:,tt) = imfill(tmp,'holes');
end

%% parts
cc = bwconncomp(dFg,6);
ccLen = cellfun(@numel,cc.PixelIdxList);
dfx = nan(1,cc.NumObjects);
for ii=1:cc.NumObjects
    pix0 = cc.PixelIdxList{ii};
    dfx(ii) = mean(dF(pix0));
    %dfx(ii) = max(dFSmo(pix0));
end

evtFil = ccLen<100 & dfx>0.15;
cc.PixelIdxList = cc.PixelIdxList(evtFil);
cc.NumObjects = numel(cc.PixelIdxList);
dfx1 = dfx(evtFil);

dFg1 = labelmatrix(cc);
dFg1Vec = reshape(dFg1,[],size(dFg1,3));

ixcc = randperm(cc.NumObjects);

rng(8)
ntry = 0;

%% overlapping
close all
ntry = ntry + 1;
% kk0: 788
for ee=1:cc.NumObjects
    ii = randi(cc.NumObjects);
    kk0 = ixcc(ii);
    pix0 = cc.PixelIdxList{kk0};
    [ih0,iw0,it0] = ind2sub([H,W,T],pix0);
    ihw0 = unique(sub2ind([H,W],ih0,iw0));
    d0 = dFg1Vec(ihw0,:);
    d0 = d0(d0>0);
    grp0 = unique(d0);
    grp0Sel = grp0*0;
    for jj=1:numel(grp0)
        pix00 = cc.PixelIdxList{grp0(jj)};
        [ih,iw,it] = ind2sub([H,W,T],pix00);
        ihw = sub2ind([H,W],ih,iw);
        ihw = unique(ihw);
        ihw1 = intersect(ihw,ihw0);
        if numel(ihw)>0.2*numel(ihw0) && numel(ihw)<5*numel(ihw0) && numel(ihw1)>numel(ihw0)/5
            grp0Sel(jj) = 1;
        end
    end
    grp0 = grp0(grp0Sel>0);
    
    if numel(grp0)>=4
        ihMed = round(mean(ih0));
        iwMed = round(mean(iw0));
        rgh = max(ihMed-10,1):min(ihMed+10,H);
        rgw = max(iwMed-10,1):min(iwMed+10,W);
        
        dat0 = dF(rgh,rgw,:);
        evtmap0 = dFg1(rgh,rgw,:);
        dm0 = mean(reshape(dat0,[],T),1);
        tvec0 = cell(1,numel(grp0));
        evtbri0 = cell(1,numel(grp0));        
        
        figure('Name',num2str(kk0));
        msk0x = zeros(numel(rgh),numel(rgw),numel(grp0));
        for jj=1:numel(grp0)
            pix00 = cc.PixelIdxList{grp0(jj)};
            [ih,iw,it] = ind2sub([H,W,T],pix00);
            itMax = round(mean(it));
            itrg = min(it):max(it);
            tvec0{jj} = itrg;
            
            if 1  % use all frames
                ihw = sub2ind([H,W],ih,iw);
                ihw = unique(ihw);
                tmp = zeros(H,W);
                tmp(ihw) = 1;
                tmp = imfill(tmp,'holes');
                tmp = tmp(rgh,rgw);
            else  % use frame with largest area
                tmp = evtmap0(:,:,itMax)==grp0(jj);
                tmp = imfill(tmp,'holes');
            end
            
            if 1  % show average
                tmp1 = mean(dF(rgh,rgw,itrg),3)*2;
                tmp2 = mean(dat(rgh,rgw,itrg),3).^2*2;
            else  % show maximum
                tmp1 = dF(rgh,rgw,itMax)*2;
                tmp2 = dat(rgh,rgw,itMax).^2*2;
            end
            
            msk0x(:,:,jj) = tmp*jj;
            
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
            %evtbri0(jj) = mean(dF(pix00));
            
            subplot(3,numel(grp0),jj);
            imshow(tmp);
            text(0,-3,num2str(itrg(1)),'Color','b');
            subplot(3,numel(grp0),jj+numel(grp0));
            imshow(tmp1);
            subplot(3,numel(grp0),jj+2*numel(grp0));
            imshow(tmp2);
        end
        
        %figure;plot(dm0);hold on;scatter(tvec0,dm0(tvec0),'r');
        break
    end
end


%% draw
[~,ix] = sort(dm0);
tBg = ix(1:numel(grp0)+1);
tDraw = cell2mat(tvec0);
tShow = [tDraw,tBg];
% tShow = nan(1,numel(tDraw)*2+1);
% tShow(1:2:end) = tBg;
% tShow(2:2:end) = tDraw;

msk0 = zeros(numel(rgh),numel(rgw),numel(tShow));
xNow = 0;
for ii=1:numel(tvec0)
    tvec00 = tvec0{ii};
    msk0(:,:,xNow+1:xNow+numel(tvec00)) = repmat(msk0x(:,:,ii),1,1,numel(tvec00));
    xNow = xNow + numel(tvec00);
end

datShow = datSmo(rgh,rgw,tShow);
datShow(datShow<0) = 0;
datShow = datShow./max(datShow(:));
[H0,W0,T0] = size(datShow);

xType = 'migInvivo';

% evtbri0 = evtbri0/max(evtbri0);

evtbri1 = zeros(numel(grp0),T);
for ii=1:numel(evtbri0)
    evtbri1(ii,tvec0{ii}) = evtbri0{ii};
end
evtbri1 = evtbri1/max(evtbri1(:));

%%
cols = colormap('lines');
close all
for ii=1:T0
    dat00 = datShow(:,:,ii);
    msk00 = msk0(:,:,ii);
    idx = msk00(msk00>0);
    idx = unique(idx);
    figure;
    imagesc(dat00);
    axis off
    axNow = gca;
    axNow.DataAspectRatio = [1 1 1];
    colormap('gray');hold on
    caxis([0 1])
    for jj=1:numel(idx)
        tmp = msk00==idx(jj);
        tmp = imdilate(tmp,strel('square',3));
        cc00 = bwboundaries(tmp,'noholes');
        colxx = cols(idx(jj),:);
        colxx1 = colxx*evtbri1(idx(jj),tShow(ii));
        %colxx1 = colxx*evtbri0(idx(jj));
        for kk=1:numel(cc00)
            cc00x = cc00{kk};
            patch(cc00x(:,2),cc00x(:,1),colxx1,'FaceAlpha',0.2,...
                'EdgeColor','k','LineWidth',1);
            hold on
        end
    end
    export_fig(['./tmp/fig1a_',xType,'_',sprintf('%04d',tShow(ii)),'.tif']);
    close
end


















