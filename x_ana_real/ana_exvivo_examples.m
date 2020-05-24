% analyze results for ex vivo data, draw example events
% heterogeneities among single astrocytes
% similar to some subfigues in fig 3 of the AQuA paper

folderTop = 'D:/OneDrive/projects/glia_kira/tmp/disser/exvivo/';

imgLst = {...
    'FilteredNRMCCyto16m_slice1_baseline1_L2 3-001cycle1channel1',...
    };

fOutTop = './tmp_disser/';

nImg = numel(imgLst);

for ii=1:nImg
    disp(ii);
    resCur = load([folderTop,imgLst{ii},'/',imgLst{ii},'_aqua.mat']);
    res = resCur.res;
    nEvtCur = numel(res.evt);
    
    xArea = res.fts.basic.area';
    xDuration = res.fts.curve.width55';    
    xMinDistSoma = res.fts.region.landmarkDist.distMin;    
    xAwayCur = res.fts.region.landmarkDir.chgAway;
    xTowardCur = res.fts.region.landmarkDir.chgToward;
end

%%
datMean = mean(double(res.datOrg),3)/65535;

isStatic = xAwayCur==0 & xTowardCur==0;
newArea = xArea.*isStatic;
[area0,idxStatic] = max(newArea);

% isAway = xAwayCur./xTowardCur > 5;
% newAway = xArea.*isAway;
[away0,idxAway] = max(xAwayCur);

% isToward = xTowardCur./xAwayCur > 5;
% newToward = xArea.*isToward;
[toward0,idxToward] = max(xTowardCur);

%%
[H,W] = size(datMean);
lst0 = [idxStatic,idxAway,idxToward];
rgH = 74:378;
rgW = 145:361;

for ii=1:numel(lst0)
    evt0 = res.evt{lst0(ii)};    
    [ih,iw,it] = ind2sub(size(res.datOrg),evt0);
    datSelAll = double(res.datOrg(:,:,min(it):max(it)));
    datSelAll = datSelAll/max(datSelAll(:))/2;
    for tt=1:size(datSelAll,3)
        tx = min(it)+tt-1;
        ih0 = ih(it==tx);
        iw0 = iw(it==tx);
        ihw0 = sub2ind([H,W],ih0,iw0);
        datLvl0 = double(res.datRAll(:,:,tx))/255;        
        datMsk0 = zeros(H,W); datMsk0(ihw0) = 1;
        datMsk0 = datMsk0.*datLvl0;
        %datMsk0 = imfill(datMsk0,'holes');
        datSel = datSelAll(:,:,tt);
        switch ii
            case 1
                datOv0 = cat(3,datSel,datSel+datMsk0/2,datSel);
            case 2
                datOv0 = cat(3,datSel,datSel,datSel+datMsk0/2);
            case 3
                datOv0 = cat(3,datSel+datMsk0/2,datSel,datSel);
        end
        datOv0 = datOv0(rgH,rgW,:);
        fOut = [fOutTop,'Type ',num2str(ii),' ',num2str(min(it)+tt-1),'.png'];
        imwrite(datOv0,fOut);
    end    
end

datMean0 = datMean(rgH,rgW)*2;
imwrite(datMean0,[fOutTop,'datMean.png']);



