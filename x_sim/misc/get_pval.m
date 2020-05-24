function pVec = get_pval(dtTb,tName,fName,x0,chgSNR)

pVec = x0*0;

for ii=1:numel(x0)
    xSel = strcmp(dtTb.test,tName) & strcmp(dtTb.file,fName);
    if chgSNR==0
        xSel = xSel & (dtTb.exp==x0(ii));
    else
        xSel = xSel & abs(dtTb.snr-x0(ii))<0.3;
    end
    xName = dtTb.mthd(xSel);
    xMean = dtTb.voxIouMean(xSel);
    xVox = dtTb.voxIou(xSel,:);
    xa = find(strcmp(xName,'aqua-stable'));
    xMean(xa) = -100;
    [~,xb] = max(xMean);
    da = xVox(xa,:);
    db = xVox(xb,:);
    [~,p] = ttest2(da,db,'Vartype','unequal','Tail','right');
    pVec(ii) = p;
    fprintf('%d - %d\n',mean(da),mean(db))
end

end


