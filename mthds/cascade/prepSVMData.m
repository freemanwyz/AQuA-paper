function testdata = prepSVMData(pkf,minVm,maxVm)
    
    [MaxV,~] = max(pkf);
    [MinV,~] = min(pkf);
    if ~exist('minVm','var')
        maxVm = ones(size(pkf(:,1)))*MaxV(:)';
        minVm = ones(size(pkf(:,1)))*MinV(:)';
    end
    cc = isnan(pkf);
    pkf(cc) = minVm(cc);
    cc = isinf(pkf);
    pkf(cc) = maxVm(cc);
    pkf = ScaleW(pkf);
    cc = isnan(pkf);
    pkf(cc) = 0;
    testdata = pkf(:,:);
    
end