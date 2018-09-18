%% Migrating events
startup

% folderDat = 'D:\OneDrive\projects\glia_kira\se_aqua\dat\invivo_1x_reg_200\';
% fDat = '2826451(4)_1_2_4x_reg_200um_dualwv-001_nr';
folderDat = 'D:\OneDrive\projects\glia_kira\raw_proc\GCaMP_May17\Lck_Gcamp with Aldh1l1-tdtomato\';
fDat = '1_2_4x_reg_200um_dualwv-001_4_nr';

fprintf('Reading ...\n')
dat = io.readTiffSeq([folderDat,fDat,'.tif']);
dat = dat(11:end-10,11:end-10,:);
dat = dat/max(dat(:));
[H,W,T] = size(dat);
dBg = mean(dat,3);


%% crop region
% load drawn masks
p0 = 'D:\OneDrive\projects\glia_kira\se_aqua\x_paper\labels\mig\';
X = 15;
evtMap = zeros(X,X,3);
for ii=1:3
    img = imread([p0,num2str(ii),'.png']);
    img = imresize(img==0,[X,X]);
    evtMap(:,:,ii) = img;
end

xy = [217,169];
rgx = xy(1):xy(1)+X-1;
rgy = xy(2):xy(2)+X-1;

d0 = dBg(rgx,rgy);

% generate events
s = 0.02;
tc = [[1 1 2 2 3 3],zeros(1,6)];
bri = [[0.4 0.8 0.5 0.7 0.6 0.9],zeros(1,6)];
datShow = zeros(X,X,numel(tc));
msk = zeros(X,X,numel(tc));

for ii=1:numel(tc)
    tc0 = tc(ii);
    if tc0>0
        tmp = evtMap(:,:,tc0);
        msk(:,:,ii) = tc0*(tmp);
        tmp = imgaussfilt(tmp,2);
        dx = d0+tmp*bri(ii)+randn([X,X])*s;
    else
        dx = d0+randn([X,X])*s;
    end
    datShow(:,:,ii) = dx;
end


%% write events in one CFU
xType = 'migDraw';
cols = colormap('lines');
tShow = 1:numel(tc);
for ii=1:size(datShow,3)
    dat00 = datShow(:,:,ii);
    
    figure;
    imagesc(dat00);
    axis off
    axNow = gca;
    axNow.DataAspectRatio = [1 1 1];
    colormap('gray');hold on
    caxis([0 1])
    
    msk00 = msk(:,:,ii);
    tmp = msk00>0;
    tmp = imdilate(tmp,strel('square',3));
    
    idx = msk00(msk00>0);
    idx = unique(idx);
    
    cc00 = bwboundaries(tmp,'noholes');
    colxx = cols(idx,:);
    colxx1 = colxx*bri(ii);
    for kk=1:numel(cc00)  % multiple regions in one event in this frame
        cc00x = cc00{kk};
        patch(cc00x(:,2),cc00x(:,1),colxx1,'FaceAlpha',0.2,...
            'EdgeColor','k','LineWidth',1);
        hold on
    end
        
    export_fig(['./tmp/evt_',xType,'_',sprintf('%04d',tShow(ii)),'.tif']);
    close
end






