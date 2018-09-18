function p = extractSe(dat,seLst)
    % extractSe extract information from detected super events for simulation
    
    sz = size(dat);
    seLst = seLst(~cellfun(@isempty,seLst));
    
    % delta F
    dBg = min(movmean(dat,10,3),[],3);
    dF = dat - dBg;    
    
    % super event properties --------
    % crop the se and get delay template for each se
    
    gap0 = 5;
    
    nSe = numel(seLst);
    bri = nan(nSe,1);
    rgLst = nan(nSe,6);  % range of se
    pixMapLst = cell(nSe,1);  % 2D map of spatial footprint
    voxMapLst = cell(nSe,1);  % 3D map of super events
    pgTmpLst = cell(nSe,2);  % propagation speed templates using std or avg
    actMap = zeros(sz);  % active voxel map, for foreground calculation
    cntMap = zeros(sz(1),sz(2));
    for ii=1:nSe
        if mod(ii,100)==0
            fprintf('%d\n',ii);
        end
        vox0 = seLst{ii};
        actMap(vox0) = ii;
        
        bri(ii) = mean(dF(vox0));

        [ih,iw,it] = ind2sub(sz,vox0);
        ihw = sub2ind([sz(1),sz(2)],ih,iw);
        ihw = unique(ihw);
        cntMap(ihw) = cntMap(ihw)+1;
        
        % crop super events
        rgh = max(min(ih)-gap0,1):min(max(ih)+gap0,sz(1));
        rgw = max(min(iw)-gap0,1):min(max(iw)+gap0,sz(2));
        ih1 = ih-min(rgh)+1;
        iw1 = iw-min(rgw)+1;
        it1 = it-min(it)+1;
        
        pixMap0 = zeros(numel(rgh),numel(rgw));
        voxMap0 = zeros(numel(rgh),numel(rgw),max(it1));
        pixMap0(sub2ind(size(pixMap0),ih1,iw1)) = 1;
        voxMap0(sub2ind(size(voxMap0),ih1,iw1,it1)) = 1;
                
        % clean the spatial map
        pixMap0 = bwmorph(pixMap0,'close');
        pixMap0 = imfill(pixMap0,'holes');
        pixMap0 = bwmorph(pixMap0,'open');
        cc0 = bwconncomp(pixMap0);
        if cc0.NumObjects==0
            continue
        end
        cc0L = cellfun(@numel,cc0.PixelIdxList);
        [~,ix] = max(cc0L);
        pixMap0 = pixMap0*0;
        pixMap0(cc0.PixelIdxList{ix}) = 1;        
        
        rgLst(ii,:) = [min(rgh),max(rgh),min(rgw),max(rgw),min(it),max(it)];
        pixMapLst{ii} = pixMap0;
        voxMapLst{ii} = voxMap0;
        
        % propagation speed template for this se
        tx = round(mean(it));
        dBurst = dat(min(rgh):max(rgh),min(rgw):max(rgw),max(tx-10,1):min(tx+10,sz(3)));
        xMap0 = nanstd(dBurst,0,3);
        xMap0 = xMap0 - min(xMap0(:));
        pgTmpLst{ii,1} = xMap0/max(xMap0(:));
        
        dBurstMin = nanmin(dBurst,3);
        xMap0 = mean(dBurst-nanmean(dBurstMin(:)),3);
        xMap0 = xMap0 - min(xMap0(:));
        pgTmpLst{ii,2} = xMap0/max(xMap0(:));       
    end
    duraMap = sum(actMap>0,3);
    fg = 1*(duraMap>0);
    
    % super event and event properties (events)
    p = [];
    p.se = seLst;
    p.seRg = rgLst;
    p.sePix = pixMapLst;
    p.seVox = voxMapLst;
    p.sePg = pgTmpLst;
    p.seBri = bri/max(bri(:));
    
    p.sz = sz;
    p.fg = fg;  % foreground part of data
    p.duraMap = duraMap;
    p.cntMap = cntMap;  % 2D map of event number per frame

end




