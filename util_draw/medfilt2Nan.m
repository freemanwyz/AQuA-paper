function riseMapMed = medfilt2Nan(riseMap,dhw)
    
    if dhw<=0
        riseMapMed = riseMap;
        return
    end
    
    [h0,w0] = size(riseMap);
    riseMapMed = nan(h0,w0);
    for ii=1:h0
        for jj=1:w0
            if ~isnan(riseMap(ii,jj))
                rgh = max(ii-dhw,1):min(ii+dhw,h0);
                rgw = max(jj-dhw,1):min(jj+dhw,w0);
                x00 = riseMap(rgh,rgw);
                riseMapMed(ii,jj) = nanmedian(x00(:));
            end
        end
    end
    
end