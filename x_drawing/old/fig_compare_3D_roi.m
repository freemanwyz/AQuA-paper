%% 3D plots
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
folderResCalmAn = 'D:\neuro_WORK\glia_kira\projects\calman\';
tmp = load([folderResCalmAn,fDat,'_calman.mat']);
resCalmAn = tmp.res;


%% CalmAn
% tVec = 1:5:281;
tVec = 166:3:190;
hrg = 141:380;
wrg = 161:400;

thrx = 3;
gapz = 1;

dSel = dat(hrg,wrg,tVec);

% boundaries and regions
roiLst = resCalmAn.roiLst;
roiMap = zeros(size(dat,1),size(dat,2));
for ii=1:numel(roiLst)
    roiMap(roiLst{ii}) = ii;
end

% ROIs in region
roiMapSel = roiMap(hrg,wrg);
roi1 = label2idx(roiMapSel);
roiSel = find(cellfun(@numel,roi1)>20);
roi1 = roi1(roiSel);
bdLst1 = cell(numel(roi1),1);
for ii=1:numel(roi1)
    tmp = zeros(size(roiMapSel));
    tmp(roi1{ii}) = 1;
    tmp = imfill(tmp,'holes');
    cc = bwboundaries(tmp>0);
    bdLst1{ii} = cc;
end

% curves and colors
roiX = zeros(numel(roi1),T);
roiZ = zeros(numel(roi1),T);
colROI = zeros(numel(roi1),3);
for ii=1:numel(roi1)  
    nn = roiSel(ii);
    tmp = mean(dffVec(roiLst{nn},:),1);    
    roiX(ii,:) = tmp;
    
    tmpStd = sqrt(median((tmp(2:end)-tmp(1:end-1)).^2)/0.9);
    zNow = tmp./tmpStd;    
    roiZ(ii,:) = zNow;
    
    col0 = rand(1,3);
    col0 = col0/max(col0(:));
    colROI(ii,:) = col0;
end
roiZMax = max(roiZ,[],2);


%% all ROIs
% fRoi = drawSlice(dSel,grx);

fRoi=figure;
imshow(mean(dSel,3));
axRoi = findobj(fRoi,'Type','axes');

fRoiCurve = figure;
axRoiCurve = axes(fRoiCurve);
nEvtSel = 1;
for ii=1:numel(roi1)    
    if roiZMax(ii)<thrx
       continue
    end
    
    zNow = roiZ(ii,:);
    tmp = roiX(ii,:);
    col0 = colROI(ii,:);
    
    % curves
    if nEvtSel<11
        tSel = find(zNow>=thrx);
        plot(axRoiCurve,tmp(:)+(nEvtSel-1)*gapz,'Color','k');hold on
        scatter(axRoiCurve,tSel,tmp(tSel)+(nEvtSel-1)*gapz,4,'r','filled');hold on
        nEvtSel = nEvtSel + 1;
    end
    
    % patches
    bd0 = bdLst1{ii};
    for jj=1:numel(bd0)
        cc0 = bd0{jj};
        for tt=1:size(dSel,3)
            x0 = cc0(:,2);
            y0 = cc0(:,1);
            z0 = x0*0+tt;
            if tt==1
                patch(axRoi,x0,y0,z0,col0,'FaceAlpha',1);
            else
                patch(axRoi,x0,y0,z0,col0,'FaceAlpha',0.5,'EdgeColor',[0.5 0.5 0.5]);
            end
        end
    end    
end

figure(fRoiCurve)
axis off;

%% ROIs shown in 3D
fRoi0 = drawSlice(dSel,grx);
axRoi0 = findobj(fRoi0,'Type','axes');

for ii=1:numel(roi1)
    if roiZMax(ii)<thrx
       continue
    end
    
    % patches
    bd0 = bdLst1{ii};
    col0 = colROI(ii,:);
    zNow = roiZ(ii,:);
    for jj=1:numel(bd0)
        cc0 = bd0{jj};
        for tt=1:size(dSel,3)
            x0 = cc0(:,2);
            y0 = cc0(:,1);
            z0 = x0*0+tt;
            patch(axRoi0,x0,y0,z0,col0,'FaceAlpha',0.7,'EdgeColor',[0.5 0.5 0.5]);
        end
    end
end


%% events in ROIs
fRoi1 = drawSlice(dSel,grx);
axRoi1 = findobj(fRoi1,'Type','axes');

nEvtSel = 1;
for ii=1:numel(roi1)
    if roiZMax(ii)<thrx
       continue
    end
    
    % patches
    bd0 = bdLst1{ii};
    col0 = colROI(ii,:);
    zNow = roiZ(ii,:);
    for jj=1:numel(bd0)
        cc0 = bd0{jj};
        for tt=1:size(dSel,3)
            x0 = cc0(:,2);
            y0 = cc0(:,1);
            z0 = x0*0+tt;
            if zNow(tVec(tt))>=thrx
                patch(axRoi1,x0,y0,z0,col0,'FaceAlpha',1);
            else
                patch(axRoi1,x0,y0,z0,col0,'FaceAlpha',0.1,'EdgeColor',[0.5 0.5 0.5]);
            end
        end
    end
end

%%
addpath('../toolbox/plots/altmany-export_fig/')
export_fig(fRoi,'fig1a_roi.png');
export_fig(fRoi0,'fig1a_roi3d.png');
export_fig(fRoi1,'fig1a_roi2event.png');
export_fig(fRoiCurve,'fig1a_roi_curves.pdf');
export_fig(fRoiCurve,'fig1a_roi_curves.png');












