function filter3D = getDecayFilter(tfUp,tfDn,useLinDn)
    
    gapUp = 1/(tfUp-1);
    fKerUp = 0:gapUp:1;
    if useLinDn>0
        gapDn = 1/(tfDn-1);
        fKerDn = 1:-gapDn:0;
    else
        fKerDn = exp(-(1:tfDn)/(tfDn/3));  % exponential decay
    end
    fKer = [fKerUp,fKerDn];
    fKer = fKer/sum(fKer);
    filter3D = reshape(fKer(end:-1:1),1,1,[]);  % filter in time direction
    
end