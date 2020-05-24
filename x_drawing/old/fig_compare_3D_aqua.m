%% 3D plots
% tmp = load('greenFireBlue.mat');
% greenFireBlue = tmp.greenFireBlue/255;
grx = gray;
[folderDat,fDat] = runCfg();

dat = io.readTiffSeq([folderDat,fDat,'.tif']);
dat = sqrt(dat);
dat = dat/max(dat(:));
[H,W,T] = size(dat);

F0 = min(movmean(dat,20,3),3);
dff = (dat - F0)./F0;
dffVec = reshape(dff,[],T);


%% data
folderResAqua = 'D:\neuro_WORK\glia_kira\projects\aqua\';
tmp = load([folderResAqua,fDat,'_aqua.mat']);
res = tmp.res; ov = res.ov;


%% aqua
% tVec = 1:5:281;
tVec = 166:3:190;
hrg = 141:380;
wrg = 161:400;

% data figure
dSel = dat(hrg,wrg,tVec);
evtMap = zeros(size(dat));
for ii=1:numel(res.evt)
    evtMap(res.evt{ii}) = ii;
end
evtMapSel = evtMap(hrg,wrg,tVec);
lblIdx = label2idx(evtMapSel);
[~,pixNumRnk] = sort(cellfun(@numel,lblIdx),'descend');


%% aqua
fShow = drawSlice(dSel,jet,0.2);
fAqua = drawSlice(dSel,grx);
axAqua = findobj(fAqua,'Type','axes');

fAquaCurve = figure;
axAquaCurve = axes(fAquaCurve);

% evtCurve = zeros(1,T);
nEvtSel = 1;
for ii=1:20
    % for ii=1:numel(pixNumRnk)
    nn = pixNumRnk(ii);
    pix0 = lblIdx{nn};
    if numel(pix0)<20
        break
    end
    tmp = zeros(size(dSel));
    tmp(pix0) = 1;
    col0 = rand(1,3);
    %col0(2) = 0;
    col0 = col0/max(col0(:));
    col0 = col0.^3;
    for tt=1:size(tmp,3)
        tmp0 = tmp(:,:,tt);
        if sum(tmp0(:))>0
            tmp0 = imfill(tmp0,'holes');
            cc = bwboundaries(tmp0>0);
            for jj=1:numel(cc)
                cc0 = cc{jj};
                x0 = cc0(:,2);
                y0 = cc0(:,1);
                z0 = x0*0+tt;
                patch(axAqua,x0,y0,z0,col0,'FaceAlpha',1);
            end
        end
    end
    
    % curves
    if nEvtSel<11
        gapz = 1;
        tmp = mean(dffVec(res.fts.loc.x2D{nn},:),1);
        %tmp = res.dffMat(nn,:,2);
        t0 = res.fts.curve.tBegin(nn);
        t1 = res.fts.curve.tEnd(nn);
        plot(axAquaCurve,tmp(:)-(nEvtSel-1)*gapz,'Color','k');hold on
        plot(axAquaCurve,t0:t1,tmp(t0:t1)-(nEvtSel-1)*gapz,'Color','r','LineWidth',2);hold on
        nEvtSel = nEvtSel+1;
    end
end

figure(fAquaCurve);
axis off

%% export
addpath('../toolbox/plots/altmany-export_fig/')
export_fig(fShow,'fig1a_raw.png');
export_fig(fAqua,'fig1a_aqua.png');
export_fig(fAquaCurve,'fig1a_aqua_curves.pdf');
export_fig(fAquaCurve,'fig1a_aqua_curves.png');









