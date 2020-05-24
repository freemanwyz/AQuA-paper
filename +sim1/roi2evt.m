function [evt,z] = roi2evt(dff,roi,HW,zThrPk,zThrRatio)
    % events by thresholding dff
    % different thresholds for peak and boundary
    % input can also be df
    %
    % FIXME: still too ad hoc
    %

    [~,dx] = noiseInVec(dff,1);
    T = size(dff,2);
    nn = 1;
    evt = cell(0);
    z = [];
    for jj=1:size(dff,1)
        dff0 = dff(jj,:);
        dff0 = dff0 - min(movmean(dff0,20));
        
        z0 = dff0/dx(jj);
        z0x = z0>zThrPk;
        cc0 = bwconncomp(z0x);
        L0 = bwlabel(z0x);
        roi0 = roi{jj};
        for kk=1:cc0.NumObjects
            % extract
            t0 = cc0.PixelIdxList{kk};
            ta = max(min(t0)-10,1);
            tb = min(max(t0)+10,T);
            zSel = z0(ta:tb);
            LSel = L0(ta:tb);
            zSel(LSel>0 & LSel~=kk) = -1;
            
            % find peak and borders
            [xp,tp] = max(zSel);
            ta1 = find(zSel(1:tp)<zThrRatio*xp,1,'last');
            if isempty(ta1)
                ta1 = 1;
            else
                ta1 = min(ta1+1,tp);
            end
            tb1 = find(zSel(tp:end)<zThrRatio*xp,1);
            if isempty(tb1)
                tb1 = numel(zSel);
            else
                tb1 = max(tb1+tp-1-1,tp);
            end
            
            % new range
            t1 = (ta+ta1-1):(ta+tb1-1);          
            
            vox0 = reshape(roi0,[],1)+(reshape(t1,1,[])-1)*HW;
            evt{nn} = vox0(:);
            z(nn) = max(z0(t0)); %#ok<AGROW>
            nn = nn + 1;
        end
    end    
    
end


