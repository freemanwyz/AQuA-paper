addpath('../toolbox/misc/');
[folderDat,fDat] = runCfg();
% folderDat = 'D:\neuro_WORK\glia_kira\raw_proc\Mar14_Invivo\';
% fDat = '2826451(4)_1_2_4x_reg_200um_dualwv-001_nr';

folderPrj = 'D:\neuro_WORK\glia_kira\projects\geciquant\';
fRoi = '2a_soma_RoiSet.zip';

dat = io.readTiffSeq([folderDat,fDat,'.tif'],1);
[H,W,T] = size(dat);
datVec = reshape(dat,[],T);

xroi = ReadImageJROI([folderPrj,fRoi]);

%%
nRoi = numel(xroi);
roiLst = cell(nRoi,1);
bdLst = cell(nRoi,1);
evtMap = zeros(H,W);
dMat = zeros(nRoi,T);
for ii=1:nRoi
    if mod(ii,100)==0
        fprintf('%d\n',ii)
    end
    xx = xroi{ii}.mnCoordinates;
    bw = poly2mask(xx(:,1),xx(:,2),H,W);
    roi0 = find(bw);
    evtMap(roi0) = ii;
    roiLst{ii} = roi0;
    roi0Bd = bwboundaries(bw>0);
    bdLst{ii} = roi0Bd;
    dMat(ii,:) = mean(datVec(roi0,:),1);
end

res = [];
res.dff = dMat;
res.dffDeconv = dMat;
res.bdLst = bdLst;
res.roiLst = roiLst;
res.evtMap = evtMap;

output_filename = [folderPrj,fDat,'_geciquant.mat'];
save(output_filename,'res');

