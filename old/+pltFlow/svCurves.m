function fc = svCurves(dat,h,w,t)
    
    nLm = numel(h);
    T = size(dat,3);
        
    fc = figure;
    for ii=1:nLm
        x = dat(h(ii)-2:h(ii)+2,w(ii)-2:w(ii)+2,:);
        x = mean(reshape(x,[],T),1);
        x = x + ii;
        plot(x,'k');hold on
        scatter(t(ii),x(t(ii)),'r','filled');
    end
    
end

