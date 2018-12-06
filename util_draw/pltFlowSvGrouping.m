function ff = pltFlowSvGrouping(datSel,p,xType)
    % pltFlowSvSimple generate plots for grouping super voxels
    % do not show super voxels them selves
    %
    % xType:
    % sv_node: super voxels + nodes (un-grouped)
    % sv_node_grp: super voxels + nodes (grouped)
    
    ff = figure;
    axRaw = axes(ff);
    [H0,W0,T0] = size(datSel);
    
%     case_peak_squares = cell(0);
    
    % data with pixels chosen
    for ii=1:T0
        % raw data and events
        img0 = datSel(:,:,ii);
        img = repmat(img0,1,1,3);
        msk0 = p.msk(:,:,ii);  % for all events
        msk0Sel = p.mskSel(:,:,ii);  % for selected events
                
        % super voxles and events are differently treated
        Lx = zeros(H0,W0,3);
        nevt0 = max(msk0Sel(:));
        for hh=1:3
            Lx0 = Lx(:,:,hh);
            for nn=1:nevt0
                ix0 = find(msk0Sel==nn);
                if ~isempty(ix0)
                    Lx0(ix0) = p.colEvt(nn,hh);
                end
            end
            Lx(:,:,hh) = Lx0;
        end
        
        imgx = img*0.7+Lx*0;
        alphaMap = (msk0>0)*0.1+0.05;
        addSliceRGB(imgx,-ii,axRaw,alphaMap);
        
%         % pixel regions
%         if any(strcmp(xType,case_peak_squares))
%             for kk=1:numel(p.bdLst)
%                 bd0 = p.bdLst{kk};
%                 if p.actFrame(kk,ii)>0  % frames with activities for this region
%                     alp = 1;
%                     if strcmp(p.curveCol,'curve')
%                         colx = p.colxPixReg(kk,:);
%                     else
%                         c0 = p.actFrame(kk,ii);
%                         colx = p.colEvt(c0,:);
%                     end
%                     patch(bd0(:,2),bd0(:,1),bd0(:,1)*0-ii+0.1,colx,'FaceAlpha',alp,...
%                         'EdgeColor',colx);hold on
%                 else  % background frames for this region                      
%                     if strcmp(p.curveCol,'curve')
%                         alp = 0;
%                         colx = p.colxPixReg(kk,:);
%                     else
%                         alp = 0;
%                         colx = [1 1 1]*0.5;
%                     end
%                     patch(bd0(:,2),bd0(:,1),bd0(:,1)*0-ii+0.1,colx,'FaceAlpha',alp,...
%                         'EdgeColor',colx);hold on
%                 end
% 
%             end
%         end
    end 
    
    % super voxels graphs for two components
    for nn=1:2
        if nn==1
            sLocx = p.sLoc1;
            neibLstx = p.neibLst1;
            ofst = 0;
        else
            sLocx = p.sLoc2;
            neibLstx = p.neibLst2;
            ofst = p.T0;
        end
        for ii=1:numel(neibLstx)
            neib0 = neibLstx{ii};
            x0 = sLocx(ii,2);
            y0 = sLocx(ii,1);
            z0 = -sLocx(ii,3)-ofst;
            for jj=1:numel(neib0)
                x1 = sLocx(neib0(jj),2);
                y1 = sLocx(neib0(jj),1);
                z1 = -sLocx(neib0(jj),3)-ofst;
                line([x0,x1],[y0,y1],[z0,z1],'Color','k','LineWidth',1);
            end
        end
    end
    
    % super voxel nodes
    if strcmp(xType,'none')
        scatter3(p.sLoc1(:,2),p.sLoc1(:,1),-p.sLoc1(:,3)+0.1,50,[1 1 1],...
            'filled','MarkerEdgeColor','k');
        scatter3(p.sLoc2(:,2),p.sLoc2(:,1),-p.sLoc2(:,3)-p.T0+0.1,50,[1 1 1],...
            'filled','MarkerEdgeColor','k');
    end
    if strcmp(xType,'one')
        scatter3(p.sLoc1(:,2),p.sLoc1(:,1),-p.sLoc1(:,3)+0.1,50,[0.5 0.5 1],...
            'filled','MarkerEdgeColor','k');
        scatter3(p.sLoc2(:,2),p.sLoc2(:,1),-p.sLoc2(:,3)-p.T0+0.1,50,[1 1 1],...
            'filled','MarkerEdgeColor','k');
    end
    if strcmp(xType,'two')
        scatter3(p.sLoc1(:,2),p.sLoc1(:,1),-p.sLoc1(:,3)+0.1,50,[0.5 0.5 1],...
            'filled','MarkerEdgeColor','k');
        scatter3(p.sLoc2(:,2),p.sLoc2(:,1),-p.sLoc2(:,3)-p.T0+0.1,50,[1 0.7 0.4],...
            'filled','MarkerEdgeColor','k');
    end
    
    % camera view point    
    pbaspect([W0 H0 W0*4])
    axRaw.CameraUpVector = [0 1 0];
    campos([1158,596 52]);
    axis off
    
end

