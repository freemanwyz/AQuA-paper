function [iouVox,iouPix] = IoU(evtGt,evtGtPix,evtDt,evtDtPix,sz)    
    % reference
    evtMap0 = zeros(sz);
    for jj=1:numel(evtDt)
        evtMap0(evtDt{jj}) = jj;
    end
    
    % each one in gt
    iouVox = zeros(numel(evtGt),1);
    iouPix = zeros(numel(evtGt),1);
    for jj = 1:numel(evtGt)
        vox0 = evtGt{jj};
        pix0 = evtGtPix{jj};
        
        xOver = evtMap0(vox0);
        xOver = xOver(xOver>0);
        idxOver = unique(xOver);
        
        if isempty(idxOver)
            continue
        end
        iouPix0 = 0;
        iouVox0 = 0;
        for kk=1:numel(idxOver)
            vox1 = evtDt{idxOver(kk)};
            pix1 = evtDtPix{idxOver(kk)};
            iv0 = numel(intersect(vox0,vox1))/numel(union(vox0,vox1));
            ip0 = numel(intersect(pix0,pix1))/numel(union(pix0,pix1));
            iouPix0 = max(iouPix0,ip0);
            iouVox0 = max(iouVox0,iv0);
        end
        iouVox(jj) = iouVox0;
        iouPix(jj) = iouPix0;
    end
end
