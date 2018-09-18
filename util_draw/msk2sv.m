function [L1,L1rgb,sLoc] = msk2sv(mskIn,datIn,nSp)    
    % super pixels and colors    
    if ~exist('nSp','var')
        nSp = 100;
    end    
    
    datSmo = imgaussfilt3(datIn,2);
    
    x1 = sum(mskIn,3); x2 = x1; x2(x2==0)= -100;
    L1 = superpixels(x2,nSp);
    L1(x2<0) = 0;
    
    pixLst = label2idx(L1);
    L1 = zeros(size(L1));
    nSv = 1;
    for nn=1:numel(pixLst)
        pix0 = pixLst{nn};
        if ~isempty(pix0)
            L1(pix0) = nSv;
            nSv = nSv+1;
        end
    end
    L1rgb = double(label2rgb(L1,'jet','k','shuffle'))/255;
    
    % seed point
    nSv = max(L1(:));
    L1x = repmat(L1,1,1,size(mskIn,3));
    L1x = L1x.*(mskIn>0);
    svLst = label2idx(L1x);
    sLoc = zeros(nSv,3);
    for nn = 1:nSv
        sv0 = svLst{nn};
        [~,ix] = max(datSmo(sv0));
        [~,~,tMax] = ind2sub(size(mskIn),sv0(ix));
        [ih,iw,it] = ind2sub(size(mskIn),sv0);
        ih0 = ih(it==tMax);
        iw0 = iw(it==tMax);
        hMax = mean(ih0);
        wMax = mean(iw0);
        sLoc(nn,:) = [hMax,wMax,tMax];
    end
    
end