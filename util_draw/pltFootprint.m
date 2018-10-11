function ff = pltFootprint(datSel,p)
    % print spatial footprint, see pltFlowCommon for details
    
    ff = figure;
    axRaw = axes(ff);
    [H0,W0,T0] = size(datSel);
    
    % pixel map
    if isfield(p,'pixMap') && ~isempty(p.pixMap)    
        imgx = double(repmat(p.pixMap,1,1,3))*0.7;
        alphaMap = ones(H0,W0)*0.5;        
        addSliceRGB(imgx,-size(datSel,3)-4,axRaw,alphaMap);
        
        for kk=1:numel(p.bdLst)
            bd0 = p.bdLst{kk};
            patch(bd0(:,2),bd0(:,1),bd0(:,1)*0-T0-1+0.1,[1 1 1],'EdgeColor','k');hold on
        end
    end    
    
    % camera view point
    %pbaspect([W0 H0 W0*4])
    axRaw.CameraUpVector = [0 1 0];
    %campos([1158,596 52]);
    axis off
    
end

