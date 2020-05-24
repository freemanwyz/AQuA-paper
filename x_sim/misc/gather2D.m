function [resLst,xMax,bdLst] = gather2D(fTop,fName,mthdLst,fltx)
    
    resLst = cell(size(mthdLst));
    bdLst = cell(size(mthdLst));
    xMax = 0;
    for ii=1:numel(mthdLst)
        mthd0 = mthdLst{ii};
        fprintf('%s\n',mthd0)
        x0 = contains(fName,mthd0);
        for jj=1:numel(fltx)
            x0 = x0 & contains(fName,fltx{jj});
        end
        idx0 = find(x0);
        f0 = fName{idx0(1)};
        
        tmp = load([fTop,filesep,f0]);
        m0 = tmp.m0;
        %figure;imagesc(m0);
        resLst{ii} = m0;    
        if isfield(tmp,'roi0')
            roi0 = tmp.roi0;
            bd0 = [];
            for jj=1:numel(roi0)
                roi00 = roi0{jj};
                if sum(m0(roi00))>0
                    tmp = zeros(size(m0));
                    tmp(roi00) = 1;
                    bd00 = bwboundaries(tmp,'noholes');
                    bd0 = [bd0;bd00];
                end
            end            
            bdLst{ii} = bd0;
        end
        xMax = max(max(m0(:)),xMax);        
    end        
    
end