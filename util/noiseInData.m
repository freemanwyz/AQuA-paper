function [s,dx] = noiseInData(dat)
    dx = (sqrt((dat(:,:,2:end) - dat(:,:,1:end-1)).^2/2))/0.6743;
    s = median(dx(:));
end