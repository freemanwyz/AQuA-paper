function [iou,gtLst,dtLst] = anaIoU(rDt,gt,thrxx,mthdX)
    % anaIoU calculates Jaccard scores
    % iou is noise levels by 4: gt-pix, gt-vox, dt-pix, dt-vox
    % gt: ground truth, dt: detected, pix: pixel overlap, vox: voxel overlap
    
    nNoise = numel(gt.noise);
    evtGt = gt.evt;
    evtGtPix = gt.pix;
    
    [evtDtLst,evtDtPixLst] = sim1.anaExtractDt(rDt,mthdX,thrxx,gt.sz);
    
    gtLst = cell(nNoise,1);
    dtLst = cell(nNoise,1);
    
    iou = zeros(nNoise,4);
    
    for ii=1:nNoise
        evtDt = evtDtLst{ii};
        evtDtPix = evtDtPixLst{ii};
        
        fprintf('SNR %d # %d\n',ii,numel(evtDt));
        
        % event map for detected
        
        gtLst{ii} = IoU(evtGt,evtGtPix,evtDt,evtDtPix,gt.sz);  % gt as ref
        dtLst{ii} = IoU(evtDt,evtDtPix,evtGt,evtGtPix,gt.sz);  % dt as ref
        
        iou(ii,1:2) = mean(gtLst{ii},1);
        iou(ii,3:4) = mean(dtLst{ii},1);
    end
    
end


function gtIoU = IoU(evtGt,evtGtPix,evtDt,evtDtPix,sz)    
    % reference
    evtMap0 = zeros(sz);
    for jj=1:numel(evtDt)
        evtMap0(evtDt{jj}) = jj;
    end
    
    % each one in gt
    gtIoU = zeros(numel(evtGt),2);
    for jj = 1:numel(evtGt)
        vox0 = evtGt{jj};
        pix0 = evtGtPix{jj};
        
        xOver = evtMap0(vox0);
        xOver = xOver(xOver>0);
        idxOver = unique(xOver);
        
        if isempty(idxOver)
            continue
        end
        iouPix = 0;
        iouVox = 0;
        for kk=1:numel(idxOver)
            vox1 = evtDt{idxOver(kk)};
            pix1 = evtDtPix{idxOver(kk)};
            iv0 = numel(intersect(vox0,vox1))/numel(union(vox0,vox1));
            ip0 = numel(intersect(pix0,pix1))/numel(union(pix0,pix1));
            iouPix = max(iouPix,ip0);
            iouVox = max(iouVox,iv0);
        end
        gtIoU(jj,:) = [iouPix,iouVox];
    end
end







