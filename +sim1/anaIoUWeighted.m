function [iou,gtLst,dtLst] = anaIoUWeighted(rIn,gt,thrxx,mthdX)
    % anaIoUWeighted calculates weighted IoU score
    % iou is noise levels by 2: gt-vox, dt-vox
    % gt: ground truth, dt: detected, vox: voxel overlap
    
    nNoise = numel(gt.noise);
    evtGt = gt.evt;
    datSim = rIn.xx.datSim;
    datSim(datSim<0.1) = 0;
    
    [evtDtLst,~] = sim1.anaExtractDt(rIn.resx,mthdX,thrxx,gt.sz);
    
    gtLst = cell(nNoise,1);
    dtLst = cell(nNoise,1);
    
    iou = zeros(nNoise,2);    
    for ii=1:nNoise
        evtDt = evtDtLst{ii};
        
        fprintf('SNR %d # %d\n',ii,numel(evtDt));
        
        % event map for detected        
        gtLst{ii} = IoU(datSim,evtGt,evtDt,gt.sz);  % gt as ref
        dtLst{ii} = IoU(datSim,evtDt,evtGt,gt.sz);  % dt as ref
        
        iou(ii,1) = mean(gtLst{ii},1);
        iou(ii,2) = mean(dtLst{ii},1);
    end    
end


function gtIoU = IoU(datSim,evtGt,evtDt,sz)    
    % reference
    evtMap0 = zeros(sz);
    for jj=1:numel(evtDt)
        evtMap0(evtDt{jj}) = jj;
    end
    
    % each one in gt
    gtIoU = zeros(numel(evtGt),1);
    for jj = 1:numel(evtGt)
        vox0 = evtGt{jj};
        
        xOver = evtMap0(vox0);
        xOver = xOver(xOver>0);
        idxOver = unique(xOver);
        
        if isempty(idxOver)
            continue
        end
        iouVox = 0;
        for kk=1:numel(idxOver)
            vox1 = evtDt{idxOver(kk)};
            xInter = intersect(vox0,vox1);
            xUnion = union(vox0,vox1);        
            iv0 = sum(datSim(xInter))/sum(datSim(xUnion));
            iouVox = max(iouVox,iv0);
        end
        gtIoU(jj) = iouVox;
    end
end



