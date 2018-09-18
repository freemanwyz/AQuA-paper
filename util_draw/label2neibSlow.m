function neibLst = label2neibSlow(L1)
    
    pixLst = label2idx(L1);
    neibLst = cell(numel(pixLst),1);
    for ii=1:numel(pixLst)
        tmp = L1*0;
        tmp(pixLst{ii}) = 1;
        tmp = imdilate(tmp,strel('square',3));
        idx1 = unique(L1(tmp>0));
        idx1 = idx1(idx1>ii);
        neibLst{ii} = idx1;
    end
    
end