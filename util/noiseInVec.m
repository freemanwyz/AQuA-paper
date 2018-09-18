function [s,dx] = noiseInVec(dat,useBase)
    
    if ~exist('useBase','var')
        useBase = 0;
    end
    
    % std
    if useBase==0  % use all signals for noise
        dx = mean((sqrt((dat(:,2:end) - dat(:,1:end-1)).^2/2))/0.6743,2);
    else  % use baseline part for noise
        dx = zeros(size(dat,1),1);
        Tww = 20;
        T = size(dat,2);
        for ii=1:size(dat,1)
            charx1 = dat(ii,:);
            charxMv1 = movmean(charx1,Tww);
            [~,ixMin] = min(charxMv1);
            rg00 = max(ixMin-round(Tww/2),1):min(ixMin+round(Tww/2),T);
            charx1Base = charx1(rg00);
            dx(ii) = sqrt(median((charx1Base(2:end)-charx1Base(1:end-1)).^2)/0.9113);
            %dx(ii) = std(charx1Base);
        end        
    end
    s = median(dx(:));
    
end