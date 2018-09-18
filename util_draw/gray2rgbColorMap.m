function d0rgb = gray2rgbColorMap(d0,cMap)
    
    d0Int8 = round(d0*255)+1;
    d0Int8(d0Int8>256) = 256;
    d0Int8(d0Int8<1) = 1;
    x = cMap(:,1); d0r = x(d0Int8);
    x = cMap(:,2); d0g = x(d0Int8);
    x = cMap(:,3); d0b = x(d0Int8);
    d0rgb = cat(3,d0r,d0g,d0b);
    
end