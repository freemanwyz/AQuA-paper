% FASP is slow or un-usable for bursts or large events
folderPrj = 'D:\neuro_WORK\glia_kira\projects\fasp\';
[folderDat,fDat] = runCfg();
% folderDat = 'D:\neuro_WORK\glia_kira\raw_proc\Mar14_Invivo\';
% fDat = '2826451(4)_1_2_4x_reg_200um_dualwv-001_nr';

dat = io.readTiffSeq([folderDat,fDat,'.tif'],1);

%% downsample (input for FASP)
datx2 = imresize(dat,[256,256]);
datx2f = imgaussfilt3(datx2,[0.01,0.01,1]);
datx3 = datx2f(:,:,1:2:end);
datx3n = datx3 + randn(size(datx3))*0.01;

io.writeTiffSeq([folderPrj,fDat,'_256_256_807.tif'],datx3n,16);

%% post process
H0 = 128;
W0 = 128;
addpath('../../toolbox/misc/');
fRoi = 'RoiSet_128_128_807.zip';

[H,W,T] = size(dat);
datVec = reshape(dat,[],T);
xroi = ReadImageJROI([folderPrj,fRoi]);

% extract information
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
    bw = poly2mask(xx(:,1),xx(:,2),H0,W0);
    bw = imresize(bw,[H,W]);
    roi0 = find(bw>0);
    evtMap(roi0) = ii;
    roiLst{ii} = roi0;
    roi0Bd = bwboundaries(bw>0);
    bdLst{ii} = roi0Bd;
    dMat(ii,:) = mean(datVec(roi0,:),1);
end

% output
res = [];
res.dff = dMat;
res.dffDeconv = dMat;
res.bdLst = bdLst;
res.roiLst = roiLst;
res.evtMap = evtMap;
res.fRoi = fRoi;

output_filename = [folderPrj,fDat,'_fasp.mat'];
save(output_filename,'res');








