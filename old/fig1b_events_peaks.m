% data
startup

folderAnno = [folderTop,'x_paper\labels\'];
fDat = 'FilteredNRMCCyto16m_slice2_TTX3_L2 3-012cycle1channel1';
xType = 'prop2'; tmp = load([folderAnno,fDat,'_',xType,'.mat']);
msk = tmp.msk0;
datSel = tmp.dat0Sel;
dat = tmp.dat0;
tVec = tmp.tVec;
datSel = cat(3,datSel,dat(:,:,end));
msk = cat(3,msk,msk(:,:,1)*0);

%% show peaks
datFlip = dat(end:-1:1,:,:);
mskFlip = msk(end:-1:1,:,:);

x0 = [33,24]; y0 = [174,88];
figure;
gapxy = 2;
bdLst = cell(0);
[H0,W0,~] = size(datFlip);
pixMapAll = zeros(H0,W0);
actFrame = zeros(2,size(msk,3));
for ii=1:2
    rgx = x0(ii)-gapxy:x0(ii)+gapxy;
    rgy = y0(ii)-gapxy:y0(ii)+gapxy;
    x = datFlip(rgy,rgx,:);
    xm = mean(reshape(x,[],size(x,3)),1);
    xm = xm-min(xm);
    xm = xm/max(xm);
    plot(xm);hold on
    pixMap = zeros(H0,W0);
    pixMap(rgy,rgx) = 1;
    cc = bwboundaries(pixMap);
    bdLst{ii} = cc{1};
    pixMapAll(rgy,rgx) = ii;
    actFrame(ii,:) = squeeze(mskFlip(y0(ii),x0(ii),:));
end

%% add slices
figure;
axRaw = axes;

colxPixReg = [1 0 0; 0 1 0];
colxEvtBd = colormap('lines');
cofst = 0;

msk2D = sum(mskFlip,3);
msk3 = cat(3,msk2D*0+0.1,msk2D*0+0.1,msk2D/5);
addSliceRGB(msk3,0,axRaw,ones(size(msk2D))*0.5);
for ii=1:numel(bdLst)
    bd0 = bdLst{ii};
    patch(bd0(:,2),bd0(:,1),bd0(:,1)*0-0.1,colxPixReg(ii,:),'FaceAlpha',0,'EdgeColor',colxPixReg(ii,:));hold on
end

for ii=1:size(datSel,3)
    img0 = flipud(datSel(:,:,ii));
    img = repmat(img0,1,1,3);
    [H0,W0] = size(img0);
    alphaMap = img0*3+0.2;
    z = -ii;
    addSliceRGB(img*2,z,axRaw,alphaMap);
    
    % pixel regions
    for kk=1:numel(bdLst)
        bd0 = bdLst{kk};
        alp = 0;
        if actFrame(kk,ii)>0
            alp = 1;
        end
        patch(bd0(:,2),bd0(:,1),bd0(:,1)*0+z-0.1,colxPixReg(kk,:),'FaceAlpha',alp,...
            'EdgeColor',colxPixReg(kk,:));hold on
    end
    
    % events
    msk00 = mskFlip(:,:,ii);
    idx = unique(msk00(:)); 
    idx = idx(idx>0);
    for jj=1:numel(idx)
        tmp = msk00==idx(jj);
        cc00 = bwboundaries(tmp);
        colxx = colxEvtBd(idx(jj)+cofst,:);
        for kk=1:numel(cc00)
            cc00x = cc00{kk};
            patch(cc00x(:,2),cc00x(:,1),cc00x(:,2)*0+z-0.1,colxx,'FaceAlpha',0,...
                'EdgeColor',colxx,'LineWidth',2,'LineStyle',':');
            hold on
        end
    end
end

pbaspect([W0 H0 W0*2])
camup([1 0 0])
axis off







