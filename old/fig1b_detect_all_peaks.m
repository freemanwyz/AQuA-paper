% data
startup
folderAnno = [folderTop,'x_paper\labels\'];
fDat = 'FilteredNRMCCyto16m_slice2_TTX3_L2 3-012cycle1channel1';

% propagation with two events
tmp = load([folderAnno,fDat,'_','prop1','.mat']);
msk = tmp.msk0; dat1 = tmp.dat0;
datSel1 = cat(3,tmp.dat0Sel,dat1(:,:,end));
msk1 = cat(3,msk,msk(:,:,1)*0);

% propagation with one events
tmp = load([folderAnno,fDat,'_','prop2','.mat']);
msk = tmp.msk0; dat2 = tmp.dat0;
datSel2 = cat(3,tmp.dat0Sel,dat2(:,:,end));
msk2 = cat(3,msk,msk(:,:,1)*0);

% combine two events
msk2(msk2>0) = msk2(msk2>0)+max(msk1(:));
msk = cat(3,msk1,msk2);
datSel = cat(3,datSel1,datSel2);
dat = cat(3,dat1,dat2);
nEvt = max(msk(:));


%% show peaks
mskFlip = msk(end:-1:1,:,:);
x0 = [33,24]; y0 = [174,88];
nReg = numel(x0);

gapxy = 2;
bdLst = cell(0);
[H0,W0,~] = size(msk);
actFrame = zeros(nReg,size(msk,3));
for ii=1:nReg
    rgx = x0(ii)-gapxy:x0(ii)+gapxy;
    rgy = y0(ii)-gapxy:y0(ii)+gapxy;
    pixMap = zeros(H0,W0);
    pixMap(rgy,rgx) = 1;
    cc = bwboundaries(pixMap);
    bdLst{ii} = cc{1};
    actFrame(ii,:) = squeeze(mskFlip(y0(ii),x0(ii),:));
end

%% add slices
figure;
axRaw = axes;

colxPixReg = [1 0 0; 0 1 0];
colxEvtBd = colormap('lines');

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
    alphaMap = img0.^1.5+0.025;
    z = -ii;
    addSliceRGB(img*2,z,axRaw,alphaMap);
    
    % pixel regions
    for kk=1:numel(bdLst)
        bd0 = bdLst{kk};
        alp = 0;
        colx = 'k';
        if actFrame(kk,ii)>0
            alp = 1;
            colx = colxPixReg(kk,:);
        end
        patch(bd0(:,2),bd0(:,1),bd0(:,1)*0+z-0.1,colx,'FaceAlpha',alp,...
            'EdgeColor',colx);hold on
    end
    
    % events
    msk00 = mskFlip(:,:,ii);
    idx = unique(msk00(:)); 
    idx = idx(idx>0);
    for jj=1:numel(idx)
        tmp = msk00==idx(jj);
        cc00 = bwboundaries(tmp);
        colxx = colxEvtBd(idx(jj),:);
        for kk=1:numel(cc00)
            cc00x = cc00{kk};
            patch(cc00x(:,2),cc00x(:,1),cc00x(:,2)*0+z-0.1,colxx,'FaceAlpha',0.5,...
                'EdgeColor',colxx,'LineWidth',1);
            hold on
        end
    end
end

pbaspect([W0 H0 W0*4])
% camup([1 0 0])
campos([-1.9509   -0.4542    0.0450]*1000);
axis off













