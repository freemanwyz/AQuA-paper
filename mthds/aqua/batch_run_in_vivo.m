startup;  % initialize

preset = 1;
pDat = 'D:\neuro_WORK\glia_kira\raw\Mar14_InVivoDataSet\';
pRes = 'D:\neuro_WORK\glia_kira\projects\x20180528_in_vivo\';
opts = util.parseParam(preset,0);

ccLst = {'2826451(4)_1_2_4x_reg_200um_dualwv-001.tif',...
    '2x_200um_reg_gcampwLP_10min_moco.tif',...
    '2x_190um_gcampwLEP_10min_moco'};

% cc = dir(pDat); cc = cc(~[cc.isdir]);

%% detect events and extract features
for ii=1:numel(ccLst)
    f0 = ccLst{ii};
    [datOrg,opts] = burst.prep1(pDat,f0,[],opts);  % read data
    res = aqua_top_reg_lmk(datOrg,opts);
    save([pRes,filesep,opts.fileName,'_results.mat'],'res','-v7.3');
end

runInfo = [];
runInfo.files = cc;
runInfo.pDat = pDat;
runInfo.pRes = pRes;
runInfo.opts = opts;
runInfo.preset = preset;
save([pRes,filesep,'info.mat'],'runInfo');




