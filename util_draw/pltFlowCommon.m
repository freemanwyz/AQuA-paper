function ff = pltFlowCommon(datSel,p,xType)
    % pltFlowCommon generate plots based on two super events 
    % (each may contain several events)
    %
    % xType:
    % single_evt: smoothness constraint, some peaks in the event
    % two_evts_time: single cycle constraint
    % two_evts_spatial: single source constraint
    % peaks: some peaks in the movie, no color code
    % sv: super voxels only
    % sv_node: super voxels + nodes (un-grouped)
    % sv_node_grp: super voxels + nodes (grouped)
    % se: super events
    
    ff = figure;
    axRaw = axes(ff);
    [H0,W0,T0] = size(datSel);
    
    case_super_voxels = {'sv','sv_node','sv_node_a','sv_node_grp'};
    case_peak_squares = {'single_evt','two_evts_time','two_evts_spatial','peaks'};
    
    for ii=1:T0
        % raw data and events
        img0 = datSel(:,:,ii);
        img = repmat(img0,1,1,3);
        msk0 = p.msk(:,:,ii);  % for all events
        msk0Sel = p.mskSel(:,:,ii);  % for selected events
                
        % super voxles and events are differently treated
        if any(strcmp(xType,case_super_voxels))
            if ii<=p.T0
                Lx = p.L1rgb;
            else
                Lx = p.L2rgb;
            end
            Lx = Lx.*(msk0Sel>0);
        else
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
        end
        
        imgx = img*0.7+Lx;
        alphaMap = (msk0>0)*0.2+0.05;
        switch xType
            case 'two_evts_time'
                alphaMap = (msk0>0)*0.15+0.05;
            case 'two_evts_spatial'
                alphaMap = (msk0>0)*0.15+0.05;
            case 'peaks'
                alphaMap = (msk0>0)*0.15+0.05;
            case 'sv'
                alphaMap = (msk0>0)*0.4+0.05;
            case 'sv_node'
                alphaMap = (msk0>0)*0.1+0.05;
            case 'sv_node_a'
                alphaMap = (msk0>0)*0.1+0.05;
            case 'sv_node_grp'
                alphaMap = (msk0>0)*0.1+0.05;
            case 'se'
                alphaMap = (msk0>0)*0.3+0.05;
        end
        addSliceRGB(imgx,-ii,axRaw,alphaMap);
        
        % pixel regions
        if any(strcmp(xType,case_peak_squares))
            for kk=1:numel(p.bdLst)
                bd0 = p.bdLst{kk};
                if p.actFrame(kk,ii)>0  % frames with activities for this region
                    alp = 1;
                    if strcmp(p.curveCol,'curve')
                        colx = p.colxPixReg(kk,:);
                    else
                        c0 = p.actFrame(kk,ii);
                        colx = p.colEvt(c0,:);
                    end
                    patch(bd0(:,2),bd0(:,1),bd0(:,1)*0-ii+0.1,colx,'FaceAlpha',alp,...
                        'EdgeColor',colx);hold on
                else  % background frames for this region                      
                    if strcmp(p.curveCol,'curve')
                        alp = 0;
                        colx = p.colxPixReg(kk,:);
                    else
                        alp = 0;
                        colx = [1 1 1]*0.5;
                    end
                    patch(bd0(:,2),bd0(:,1),bd0(:,1)*0-ii+0.1,colx,'FaceAlpha',alp,...
                        'EdgeColor',colx);hold on
                end

            end
        end
    end 
    
    % super voxels graphs
    if strcmp(xType,'sv_node') || strcmp(xType,'sv_node_a') || strcmp(xType,'sv_node_grp')
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
                    line([x0,x1],[y0,y1],[z0,z1],'Color','r','LineWidth',1);
                end
            end
        end
        
        for ii=1:numel(p.neibLst12)
            neib0 = p.neibLst12{ii};
            x0 = p.sLoc1(ii,2);
            y0 = p.sLoc1(ii,1);
            z0 = -p.sLoc1(ii,3);
            for jj=1:numel(neib0)
                x1 = p.sLoc2(neib0(jj),2);
                y1 = p.sLoc2(neib0(jj),1);
                z1 = -p.sLoc2(neib0(jj),3)-p.T0;
                line([x0,x1],[y0,y1],[z0,z1],'Color','b','LineStyle','--');
            end
        end
    end
    
    % super voxel nodes
    if strcmp(xType,'sv_node')
        scatter3(p.sLoc1(:,2),p.sLoc1(:,1),-p.sLoc1(:,3)+0.1,50,[1 1 1],...
            'filled','MarkerEdgeColor','k');
        scatter3(p.sLoc2(:,2),p.sLoc2(:,1),-p.sLoc2(:,3)-p.T0+0.1,50,[1 1 1],...
            'filled','MarkerEdgeColor','k');
    end
    if strcmp(xType,'sv_node_a')
        scatter3(p.sLoc1(:,2),p.sLoc1(:,1),-p.sLoc1(:,3)+0.1,50,[1 0.5 0],...
            'filled','MarkerEdgeColor','k');
        scatter3(p.sLoc2(:,2),p.sLoc2(:,1),-p.sLoc2(:,3)-p.T0+0.1,50,[1 1 1],...
            'filled','MarkerEdgeColor','k');
    end
    if strcmp(xType,'sv_node_grp')
        scatter3(p.sLoc1(:,2),p.sLoc1(:,1),-p.sLoc1(:,3)+0.1,50,[1 0.5 0],...
            'filled','MarkerEdgeColor','k');
        scatter3(p.sLoc2(:,2),p.sLoc2(:,1),-p.sLoc2(:,3)-p.T0+0.1,50,[0 1 0.75],...
            'filled','MarkerEdgeColor','k');
    end
    
    % pixel map
    if isfield(p,'pixMap') && ~isempty(p.pixMap)    
        imgx = double(repmat(p.pixMap,1,1,3))*0.7;
        %cc = bwboundaries(pixMap);
        %imgx = cat(3,p.pixMap*0,p.pixMap*0.5,p.pixMap);
        alphaMap = ones(H0,W0)*0.5;        
        addSliceRGB(imgx,-size(datSel,3)-5,axRaw,alphaMap);
        
        for kk=1:numel(p.bdLst)
            bd0 = p.bdLst{kk};
            patch(bd0(:,2),bd0(:,1),bd0(:,1)*0-T0-1+0.1,[1 1 1],'EdgeColor','k');hold on
        end
    end    
    
    % camera view point    
    pbaspect([W0 H0 W0*4])
    %campos([-742.6770 -263.4675 78.5032]);
    axRaw.CameraUpVector = [0 1 0];
    campos([1158,596 52]);
    axis off
    
    % export_fig('./tmp/fig_1b_se_bg.tif');
    
end

