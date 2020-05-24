function f = drawSlice(dSel,colMapxx,ofst)
    
    if ~exist('ofst','var')
        ofst = 0.05;
    end
    
    V = dSel;
    
    [s1,s2,s3] = size(V);
    [X,Y,Z] = meshgrid(1:s2,1:s1,1:s3);
    
    f = figure;
    h = slice(X,Y,Z,V,[],[],1:s3);
    set(h,'EdgeColor','none',...
        'FaceColor','interp',...
        'FaceAlpha','interp')
    alpha('color')
    
    xlabel('x'); ylabel('y'); zlabel('z')
    
    alphamap('rampup')
    alphamap('increase',ofst)
    
    axis off
    grid off
    
    % colormap hsv
    colormap(colMapxx)
    pbaspect([1 1 2])
    
    % view([0 0 1])
    camup([0 1 0])
    
end