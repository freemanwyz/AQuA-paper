function [ff,xmVec] = showCurves(x0,y0,dat,colx)
    
    gapxy = 5;
    nReg = numel(x0);
    T0 = size(dat,3);
    xmVec = zeros(nReg,T0);
    ff = figure;
    for ii=1:nReg
        x00 = x0(ii);
        y00 = y0(ii);
        dat00 = dat(y00-gapxy:y00+gapxy,x00-gapxy:x00+gapxy,:);
        dat00 = reshape(dat00,[],T0);
        xm = mean(dat00,1);
        
        xm = imgaussfilt(xm,1);
        
        xm = xm - mean(xm);
        xm = xm/std(xm);
        xm = (xm-min(xm))/(max(xm)-min(xm));
        %xm = (xm-min(xm))/(max(xm)-min(xm));
        
        plot(xm,'Color',colx(ii,:),'LineWidth',1); hold on
    end
    axis off
    
end