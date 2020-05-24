% data
startup

% xType = 'overlap';
xType = 'prop1';
% xType = 'mig';
folderAnno = [folderTop,'x_paper\labels\'];
cofst = 0;
colMin = 0.2;
switch xType
    case 'overlap'
        folderDat = [folderTop,'dat\exvivo_baseline_015\'];
        fDat = 'FilteredNRMCCyto16m_slice3_Baseline3_L2 3-015cycle1channel1';
        rgh = 291:400; rgw = 231:300; tShow = 101:130;
        tDraw = [108 110 114 118 125];
        thrZ = 1.5; sclMov = 1;
    case 'prop1'
        folderDat = [folderTop,'dat\exvivo_ttx_012\'];
        fDat = 'FilteredNRMCCyto16m_slice2_TTX3_L2 3-012cycle1channel1';
        rgh = 157:373; rgw = 218:305; tShow = 94:115;
        tDraw = [98,100:115];
        thrZ = 0.25; sclMov = 2;
    case 'prop2'
        folderDat = [folderTop,'dat\exvivo_ttx_012\'];
        fDat = 'FilteredNRMCCyto16m_slice2_TTX3_L2 3-012cycle1channel1';
        rgh = 157:373; rgw = 218:305; tShow = 166:192;
        tDraw = [171 175 177 179 182:190];
        thrZ = 0.25; sclMov = 2;
        cofst = 2;
    case 'mig'
        folderDat = [folderTop,'dat\exvivo_baseline_009\'];
        fDat = 'FilteredNRMCCyto16m_slice2_Baseline3_L2 3-009cycle1channel1';
        rgh = 182:252; rgw = 263:323; 
        tShow = [20 42 91 103 121 136 160 168];
        tDraw = [36 68 100 112 130 144 162];
        tShow = sort([tShow,tDraw]);
        thrZ = 1.5; sclMov = 2;
end
dat = io.readTiffSeq([folderDat,fDat,'.tif']);
dat = dat/max(dat(:));


%% draw events
datCrop = dat(rgh,rgw,:);
datShow = datCrop(:,:,tShow);
datShow = datShow/max(datShow(:));
datDraw = datCrop(:,:,tDraw);

tmpAnno = load([folderAnno,fDat,'_',xType,'.mat']);
evtLst = tmpAnno.evtLst;

if 0  % get dF
    datC1 = sqrt(dat(rgh,rgw,:)); 
    dMov = movmean(datC1,100,3); 
    dMin = min(dMov,[],3); 
    dF = datC1-dMin; zzshow(dF);
    %dx = sqrt((dF(:,:,2:end)-dF(:,:,1:end-1)).^2/2); s = median(dx(:)); zzshow(dF>4*s)
    vis.anno(dF(:,:,tDraw));
end

if 0  % draw regions
    vis.anno(sqrt(datDraw));
    vis.anno(sqrt(datDraw),evtLst);
end

if 0  % extend events
    evtLst{1}.frames = 1:13;
    for ii=6:13
        evtLst{1}.bds{ii} = evtLst{1}.bds{5};
    end
end

%% auto refine selection
[H0,W0,T0] = size(datShow);
msk0 = zeros(H0,W0,T0);
for ii=1:numel(evtLst)
    evt0 = evtLst{ii};
    for jj=1:numel(evt0.frames)
        t0d = evt0.frames(jj);
        %t0 = tDraw(t0d)-min(tShow)+1;
        t0 = find(tDraw(t0d)==tShow);
        d0 = datShow(:,:,t0);
        tmp = msk0(:,:,t0);
        bd0 = evt0.bds{jj};
        msk00 = poly2mask(bd0(:,1),H0-bd0(:,2)+1,H0,W0);
        
        msk00Out = imdilate(msk00,strel('square',5))-msk00;
        x = d0(msk00Out>0);
        z = (d0-median(x))/std(x);
        msk00(z<thrZ) = 0;
        msk00 = imdilate(msk00,strel('square',3));
        
        tmp(msk00>0) = ii;
        msk0(:,:,t0) = tmp;
    end
end
zzshow(msk0)
% save(['./tmp/',fDat,'_',xType,'.mat'],'evtLst','rgh','rgw','tShow','tDraw','thrZ','msk0','datShow','datDraw');


%% brightness per frame per event
evtBri = nan(numel(evtLst),T0);
mskv = reshape(msk0,[],T0);
for nn=1:numel(evtLst)
    msk0x = sum(msk0==nn,3)>0;
    evtBri0 = zeros(1,T0);
    for ii=1:T0
        dat00 = datShow(:,:,ii);
        msk00 = msk0(:,:,ii);
        msk00x = find(msk00==nn);
        if ~isempty(msk00x)
            evtBri0(ii) = mean(dat00(msk00x));
            %evtBri0(ii) = mean(dat00(msk0x));
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
    dat00 = datShow(:,:,ii);
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
    for jj=1:numel(idx)
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
    export_fig(['./tmp/fig1a_',xType,'_',sprintf('%04d',tShow(ii)),'.tif']);
    close
end







