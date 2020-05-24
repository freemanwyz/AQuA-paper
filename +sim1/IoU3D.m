function [gtIoU,evtMap0] = IoU3D(evtGt,evtDt,sz)    
    % reference
    evtMap0 = zeros(sz);
    for jj=1:numel(evtDt)
        evtMap0(evtDt{jj}) = jj;
    end
    
    % each one in gt
    gtIoU = nan(numel(evtGt),1);
    for jj = 1:numel(evtGt)
        vox0 = evtGt{jj};
        if isempty(vox0)
            continue
        end
        
        xOver = evtMap0(vox0);
        xOver = xOver(xOver>0);
        idxOver = unique(xOver);
        
        if isempty(idxOver)
            gtIoU(jj) = 0;
            continue
        end
        iouVox = 0;
        for kk=1:numel(idxOver)
            vox1 = evtDt{idxOver(kk)};
            iv0 = numel(intersect(vox0,vox1))/numel(union(vox0,vox1));
            iouVox = max(iouVox,iv0);
        end
        gtIoU(jj) = iouVox;
    end
end