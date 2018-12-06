function [iouVoxCom,iouPixCom] = anaIoU(rDt,gt)
    % anaIoU calculates Jaccard scores
    %
    % rDt is a noise by repetition cell array containing detection results
    % gt contains corresponding groundtruth
    % output is noise by 2, first is mean, second is 95% CI
    %
    
    nNoise = size(rDt,1);
    nRep = size(rDt,2);
    sz = gt{1}.sz;
    
    %evtGt = gt.evt;
    %evtGtPix = gt.pix;
    iouPix = zeros(nNoise,nRep,2);
    iouVox = zeros(nNoise,nRep,2);
    
    for nn=1:nRep
        evtGt = gt{nn}.evt;
        evtGtPix = gt{nn}.pix;
        [evtDtLst,evtDtPixLst] = sim1.anaExtractDt(rDt(:,nn),[],0,sz);
        
        for ii=1:nNoise
            evtDt = evtDtLst{ii};
            evtDtPix = evtDtPixLst{ii};            
            fprintf('SNR %d # %d\n',ii,numel(evtDt));
            
            % event map for detected            
            [iouVoxGt,iouPixGt] = sim1.IoU(evtGt,evtGtPix,evtDt,evtDtPix,sz);  % gt as ref
            [iouVoxDt,iouPixDt] = sim1.IoU(evtDt,evtDtPix,evtGt,evtGtPix,sz);  % dt as ref 
            
            iouVox(ii,nn,1) = nanmean(iouVoxGt);
            iouVox(ii,nn,2) = nanmean(iouVoxDt);
            iouPix(ii,nn,1) = nanmean(iouPixGt);
            iouPix(ii,nn,2) = nanmean(iouPixDt);            
        end
    end
    
    x0 = nanmean(iouVox,3);
    iouVoxCom = [nanmean(x0,2),2*nanstd(x0,0,2)];
    x0 = nanmean(iouPix,3);
    iouPixCom = [nanmean(x0,2),2*nanstd(x0,0,2)];
    
end







