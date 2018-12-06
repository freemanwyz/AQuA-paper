function [bdLst,actFrame] = getRegInfo(x0,y0,msk)
    
    nReg = numel(x0);
    
    gapxy = 4;
    bdLst = cell(0);
    [H0,W0,~] = size(msk);
    actFrame = zeros(nReg,size(msk,3));
    for ii=1:nReg
        rgx = x0(ii)-gapxy:x0(ii)+gapxy;
        rgy = y0(ii)-gapxy:y0(ii)+gapxy;
        pixMap = zeros(H0,W0);
        pixMap(rgy,rgx) = 1;
        cc = bwboundaries(pixMap);
        bdLst{ii} = cc{1};
        actFrame(ii,:) = squeeze(msk(y0(ii),x0(ii),:));
    end
    
end