function draw2D(resLst,xMax,bdLst,fxx)
    
    [H,W] = size(resLst);
    
    if ~exist('bdLst','var')
        figure;
        ha = tight_subplot(H,W,[.01 .01],[.01 .01],[.01 .01]);
        for hh=1:H
            for ww=1:W
                x0 = resLst{hh,ww};
                p0 = (hh-1)*W+ww;
                axes(ha(p0));
                imagesc(x0,[0,xMax]);
                axis image
                axis off
            end
        end        
        return
    end
    
    % with ROIs
    figure;
    ha = tight_subplot(H,W,[.01 .01],[.01 .01],[.01 .01]);
    for hh=1:H
        for ww=1:W
            x0 = resLst{hh,ww};
            
            % boundaries
            msk0 = x0*0;
            bdLst0 = bdLst{hh,ww};
            for ii=1:numel(bdLst0)
                bd0 = bdLst0{ii};
                bd0x = sub2ind(size(x0),bd0(:,1),bd0(:,2));
                msk0(bd0x) = 1;
            end
            msk0 = imdilate(msk0,strel('square',3));
            
            % color scale
            v = x0;
            map0 = parula;
            minv = 0;
            maxv = xMax;
            v(v>maxv) = maxv;
            ncol = size(map0,1);
            s = round(1+(ncol-1)*(v-minv)/(maxv-minv));
            x0rgb = ind2rgb(s,map0);
            
            msk0a = repmat(msk0,1,1,3);
            x0rgb(msk0a>0) = 0;
            msk0a = cat(3,msk0,msk0*0,msk0*0);
            x0rgb = x0rgb+msk0a; 
            
            f00 = [fxx,'_',num2str(hh),'_',num2str(ww),'.tif'];
            imwrite(x0rgb,f00);
            
            p0 = (hh-1)*W+ww;
            axes(ha(p0));
            imshow(x0rgb)
            axis image
            axis off
        end
    end    
end





