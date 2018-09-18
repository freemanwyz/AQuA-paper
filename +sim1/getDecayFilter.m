function filter3D = getDecayFilter(tfUp,tfDn)
    
    gapUp = 1/(tfUp-1);
    fKerUp = 0:gapUp:1;
    fKerDn = exp(-(1:tfDn)/(tfDn/3));  % exponential decay
    fKer = [fKerUp,fKerDn];
    fKer = fKer/sum(fKer);
    filter3D = reshape(fKer(end:-1:1),1,1,[]);  % filter in time direction
    
end