function [iouVox,iouPix] = IoU(evtGt,evtGtPix,evtDt,evtDtPix,sz)    
    % reference
    evtMap0 = zeros(sz);
    for jj=1:numel(evtDt)
        evtMap0(evtDt{jj}) = jj;
    end
    
    % each one in gt
    iouVox = zeros(numel(evtGt),1);
    iouPix = zeros(numel(evtGt),1);
    
    dtMap = lst2map(evtDt,sz);
    gtMap = lst2map(evtGt,sz);
    for jj = 1:numel(evtGt)
        vox0 = evtGt{jj};
        pix0 = evtGtPix{jj};
        
        xOver = evtMap0(vox0);
        xOver = xOver(xOver>0);
        idxOver = unique(xOver);
        
        if isempty(idxOver)
            continue
        end
        ip0 = nan(numel(idxOver),1);
        iv0 = nan(numel(idxOver),1);
        for kk=1:numel(idxOver)
            vox1 = evtDt{idxOver(kk)};
            pix1 = evtDtPix{idxOver(kk)};
            if numel(vox0)>numel(vox1)
                voxInt = gtMap(vox1);
                iv0(kk) = sum(voxInt==jj)/(numel(vox0)+sum(voxInt~=jj));
            else
                voxInt = dtMap(vox0);
                uu = idxOver(kk);
                iv0(kk) = sum(voxInt==uu)/(numel(vox1)+sum(voxInt~=uu));               
            %else
            %    iv0(kk) = numel(intersect(vox0,vox1))/numel(union(vox0,vox1));      
            end
            ip0(kk) = numel(intersect(pix0,pix1))/numel(union(pix0,pix1)); 
        end
        
%         if numel(vox0)<1e5
%             for kk=1:numel(idxOver)
%                 vox1 = evtDt{idxOver(kk)};
%                 pix1 = evtDtPix{idxOver(kk)};
%                 iv0(kk) = numel(intersect(vox0,vox1))/numel(union(vox0,vox1));
%                 ip0(kk) = numel(intersect(pix0,pix1))/numel(union(pix0,pix1));
%             end
%         else
%             tmp = zeros(sz);
%             tmp2 = zeros(sz(1),sz(2));
%             tmp(vox0) = 1;
%             tmp2(pix0) = 1;
%             for kk=1:numel(idxOver)
%                 vox1 = evtDt{idxOver(kk)};
%                 pix1 = evtDtPix{idxOver(kk)};
%                 vox1a = tmp(vox1);
%                 pix1a = tmp2(pix1);
%                 iv0(kk) = sum(vox1a>0)/(numel(vox0)+sum(vox1a==0));
%                 ip0(kk) = sum(pix1a>0)/(numel(pix0)+sum(pix1a==0)); 
%             end
%         end

        iouPix0 = nanmax(nanmax(ip0),0);
        iouVox0 = nanmax(nanmax(iv0),0);        
        iouVox(jj) = iouVox0;
        iouPix(jj) = iouPix0;
    end
end




