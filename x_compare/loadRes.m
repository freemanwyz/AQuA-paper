function [dat,res] = loadRes(mthd,useSqrt)
    
    startup;
    
    [folderDat,fDat] = runCfg();
    
    dat = readTiffSeq([folderDat,fDat,'.tif']);
    if useSqrt>0
        dat = sqrt(dat);
    end
    dat = dat/max(dat(:));
    
    res = [];
    switch mthd
        case 'aqua'
            folderResAqua = 'D:\neuro_WORK\glia_kira\projects\aqua\';
            tmp = load([folderResAqua,fDat,'_aqua.mat']);
            res = tmp.res;
    end
    
end