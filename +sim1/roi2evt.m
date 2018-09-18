function [evt,z] = roi2evt(dff,roi,HW,zThr)
    % events by thresholding dff
    % input can also be df
    
    [~,dx] = noiseInVec(dff,1);
    nn = 1;
    evt = cell(0);
    z = [];
    for jj=1:size(dff,1)
        dff0 = dff(jj,:);        
        dff0 = dff0 - min(movmean(dff0,20));
        
        z0 = dff0/dx(jj);
        z0x = z0>zThr;
        cc0 = bwconncomp(z0x);
        roi0 = roi{jj};
        for kk=1:cc0.NumObjects
            t0 = cc0.PixelIdxList{kk};
            vox0 = reshape(roi0,[],1)+(reshape(t0,1,[])-1)*HW;
            evt{nn} = vox0(:);
            z(nn) = max(z0(t0)); %#ok<AGROW>
            nn = nn + 1;
        end
    end    
    
end