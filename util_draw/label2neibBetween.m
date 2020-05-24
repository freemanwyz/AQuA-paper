function neibLst = label2neibBetween(L1,L2,overRt)
    
    pixLst = label2idx(L1);
    neibLst = cell(numel(pixLst),1);
    for ii=1:numel(pixLst)
        pix0 = pixLst{ii};
        pix1 = L2(pix0);
        pix1 = pix1(pix1>0);
        
        idx1 = unique(pix1);
        idx1Good = idx1*0;
        for jj=1:numel(idx1)
            if sum(pix1==idx1(jj))>numel(pix0)*overRt
                idx1Good(jj) = 1;
            end
        end        
        neibLst{ii} = idx1(idx1Good>0);
    end
    
end