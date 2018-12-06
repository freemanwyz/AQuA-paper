function p = extractSeFromAquaResults(pDat,pRes,f0)
    
    % read data
    tmp = load([pRes,f0,'.mat']);
    res = tmp.res;
    
    dat = readTiffSeq([pDat,f0,'.tif']);
    gapx = res.opts.regMaskGap;
    dat = dat(gapx+1:end-gapx,gapx+1:end-gapx,:);
    dat = sqrt(dat/max(dat(:)));
    dAvg = mean(dat,3)*0;
    
    % extract super events with augmentation
    p1 = sim1.extractSe(dat,res.seLst,0);
    p2 = sim1.extractSe(dat,res.seLst,5);
    p3 = sim1.extractSe(dat,res.seLst,9);
    
    p = p1;
    p.se = [p1.se,p2.se,p3.se];
    p.sePix = [p1.sePix;p2.sePix;p3.sePix];
    p.seVox = [p1.seVox;p2.seVox;p3.seVox];
    p.seRg = [p1.seRg;p2.seRg;p3.seRg];
    p.sePg = [p1.sePg;p2.sePg;p3.sePg];
    % p.seBri = [p1.seBri;p2.seBri;p3.seBri];
    
    p = sim1.simParamEx(p);
    p.dAvg = dAvg;
    
end