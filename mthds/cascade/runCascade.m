% C:\Users\Eric\Dropbox\code\repo\cascade
addpath('../../repo/cascade/');

[folderDat,fDat] = runCfg();
% folderDat = 'D:\neuro_WORK\glia_kira\raw_proc\Mar14_Invivo\';
% fDat = '2826451(4)_1_2_4x_reg_200um_dualwv-001_nr';

folderPrj = 'D:\neuro_WORK\glia_kira\projects\cascade\';

dat = io.readTiffSeq([folderDat,fDat,'.tif'],1);
res0 = Cal_anl_main2sa_forreview_x(dat);


%% save
nRoi = res0.obnum;
bdLst = cell(nRoi,1);
[H,W] = size(res0.L);
roiLst = label2idx(res0.L);
for ii=1:nRoi
    if mod(ii,100)==0
        fprintf('%d\n',ii)
    end
    roi0 = roiLst{ii};
    tmp = zeros(H,W);
    tmp(roi0) = 1;
    roi0Bd = bwboundaries(tmp);
    bdLst{ii} = roi0Bd;
end

xDff = zeros(nRoi,T);
xDff(:,res0.frameset0) = res0.intoutb2';

dffSpk = zeros(nRoi,T);
dffSpk(:,res0.frameset0) = res0.intoutbw';

res = [];
res.dff = xDff; % dff
res.dffDeconv = xDff;
res.dffSpk = dffSpk;
res.opts = res0.param;
res.bdLst = bdLst;
res.roiLst = roiLst;
res.evtMap = res0.L;
res.res0 = res0;

save([folderPrj,fDat,'_cascade.mat'],'res');



