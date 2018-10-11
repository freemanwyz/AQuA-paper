% Get propagation and overlapping examples
%
% workflow:
% event mask by thresholding -> photo editor -> load edited masks -> events
% we use Paint.net
%
% TODO: include alpha channel when exporting
%

folderTop = 'D:\OneDrive\projects\glia_kira\se_aqua\';
addpath(genpath('../../repo/aqua/'));

xType = 'overlap';
% xType = 'prop1';
colMin = 0.2;
switch xType
    case 'overlap'
        f0 = 'FilteredNRMCCyto16m_slice3_Baseline3_L2 3-015cycle1channel1';
        rgh = 220:436; rgw = 218:305; rgt = 107:140;
        thrZ = 1.5; sclMov = 1; cofst = 3;
    case 'prop1'
        f0 = 'FilteredNRMCCyto16m_slice2_TTX3_L2 3-012cycle1channel1';
        rgh = 157:373; rgw = 218:305; rgt = 94:115;
        thrZ = 0.25; sclMov = 2; cofst = 0;
    case 'prop2'
        f0 = 'FilteredNRMCCyto16m_slice2_TTX3_L2 3-012cycle1channel1';
        rgh = 157:373; rgw = 218:305; rgt = 166:192;
        thrZ = 0.25; sclMov = 2; cofst = 2;
end

opts = util.parseParam(3,0,'parameters1.csv');
opts.thrARScl = 3;
[datOrg,opts] = burst.prep1([folderTop,'dat',filesep],[f0,'.tif'],[],opts);
dat = datOrg.^2;


%% ---> before drawing. Find masks and refine them
[~,dF,arLst,~,opts] = burst.actTop(datOrg,opts);
dfCrop = dF(rgh,rgw,rgt);

dfx = 1*(dfCrop>3*sqrt(opts.varEst));
for tt=1:size(dfx,3)
    pixMap0 = dfx(:,:,tt);
    pixMap0 = bwareaopen(pixMap0,8);
    pixMap0 = bwmorph(pixMap0,'close');
    pixMap0 = imfill(pixMap0,'holes');
    pixMap0 = bwmorph(pixMap0,'open');
    dfx(:,:,tt) = pixMap0;
end

zzshow(regionMapWithData(dfx,dfCrop*5,0.2))

t0 = min(rgt);
for tt=1:size(dfx,3)
    x0 = double(dfCrop(:,:,tt)*5);
    x1 = double(dfx(:,:,tt));
    imwrite(x0,['tmp/',num2str(t0+tt-1),'.tif']);
    imwrite(x1,['tmp/msk_',num2str(t0+tt-1),'.tif']);
end


%% ---> after drawing. Load edited masks and export
% TODO: support color labels

switch xType
    case 'overlap'  % use frame labels
        rgh = 220:436; rgw = 218:305;
        folderDraw = [folderTop,'\x_paper\fig1\events\overlap_20180925\'];
        evtTimeLst = {[107,114,116,118,120],[125,126,127],[130,132,136,140]};                                
end

tps = cell2mat(evtTimeLst);
msk0 = zeros(numel(rgh),numel(rgw),numel(tps));
tt = 1;
for ii=1:numel(evtTimeLst)
    evtTime0 = evtTimeLst{ii};
    for jj=1:numel(evtTime0)
        x = imread([folderDraw,'msk_',num2str(evtTime0(jj)),'.tif']);
        x = double(x(:,:,1))/255;
        x(x<0.5) = 0;
        x(x>0.5) = ii;
        msk0(:,:,tt) = double(x);
        tt = tt+1;
    end
end

% brightness per frame per event
evtLst = label2idx(msk0);
datCrop = dat(rgh,rgw,tps);
T0 = size(datCrop,3);
evtBri = nan(numel(evtLst),T0);  % brightness for all frames
mskv = reshape(msk0,[],T0);
for nn=1:numel(evtLst)
    msk0x = sum(msk0==nn,3)>0;
    evtBri0 = zeros(1,T0);
    for ii=1:T0
        dat00 = datCrop(:,:,ii);
        msk00 = msk0(:,:,ii);
        msk00x = find(msk00==nn);
        if ~isempty(msk00x)
            evtBri0(ii) = mean(dat00(msk00x));
        else
            evtBri0(ii) = mean(dat00(msk0x));
        end
    end
    evtBri0 = evtBri0-min(evtBri0);
    evtTime0 = sum(mskv==nn,1)>0;
    evtMax0 = max(evtBri0(evtTime0));
    evtBri(nn,:) = (evtBri0/evtMax0+colMin)/(colMin+1);
end

%% export
cols = colormap('lines');
close all
for ii=1:T0
    dat00 = datCrop(:,:,ii);
    msk00 = msk0(:,:,ii);
    idx = msk00(msk00>0);
    idx = unique(idx);
    
    figure;
    imagesc(sqrt(dat00));
    axis off
    axNow = gca;
    axNow.DataAspectRatio = [1 1 1];
    colormap('gray');hold on
    caxis([0 1])
    
    for jj=1:numel(idx)  % draw for each event in this frame
        tmp = msk00==idx(jj);
        cc00 = bwboundaries(tmp,'noholes');
        colxx = cols(idx(jj)+cofst,:);
        colxx1 = colxx*evtBri(idx(jj),ii);
        for kk=1:numel(cc00)
            cc00x = cc00{kk};
            patch(cc00x(:,2),cc00x(:,1),colxx1,'FaceAlpha',0.4,...
                'EdgeColor','k','LineWidth',1);
            hold on
        end
    end
    
    export_fig(['./tmp/',xType,'_',sprintf('%04d',tps(ii)),'.tif']);
    pause(0.5);close
end







