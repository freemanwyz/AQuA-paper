function [roiLst,bdLst] = readROI(folderRoi,fRoi,H,W)
    
    xroi = ReadImageJROI([folderRoi,fRoi]);
    
    nRoi = numel(xroi);
    roiLst = cell(nRoi,1);
    bdLst = cell(nRoi,1);
    for ii=1:nRoi
        if mod(ii,100)==0
            fprintf('%d\n',ii)
        end
        if nRoi>1
            xx = xroi{ii}.mnCoordinates;
        else
            xx = xroi.mnCoordinates;
        end
        bw = poly2mask(xx(:,1),xx(:,2),H,W);
        roi0 = find(bw>0);
        roiLst{ii} = roi0;
        bdLst{ii} = xx;
    end
    
    
end