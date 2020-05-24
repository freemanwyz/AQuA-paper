function s = addSliceRGB(img,z,axRaw,alphaMap)
    
    [H0,W0,~] = size(img);
    [gX,gY,gZ] = meshgrid(1:W0,1:H0,z);
    
    s = surf(axRaw,gX,gY,gZ,img);hold on
    s.AlphaData = alphaMap;
    s.AlphaDataMapping = 'none';
    s.FaceAlpha = 'flat';
    s.EdgeColor = 'none'; 
        
end