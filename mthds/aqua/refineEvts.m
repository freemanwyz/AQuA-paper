function evts = refineEvts(dat,evtLst,delta)
    % refineEvts use region growing to refine super events
    % dat: input data
    % evtLst: super events list
    % delta: dilation/erosion filter size for refinement range
    %
    
    [H,W,T] = size(dat);
    xx = (dat(:,:,2:end)-dat(:,:,1:end-1)).^2;
    stdMap = sqrt(median(xx,3)/0.9133);
    stdEst = double(nanmedian(stdMap(:)));
    
    datMA = movmean(dat,30,3);
    datMin = min(datMA,[],3);
    dF = dat - datMin;
    
    evts = cell(numel(evtLst,1));
    
    evtMap = zeros(size(dat));
    for nn=1:numel(evtLst)
        evtMap(evtLst{nn}) = nn;
    end
    
    for nn=1:numel(evtLst)
        if mod(nn,100)==0
            fprintf('%d\n',nn);
        end
        pix0 = evtLst{nn};
        if isempty(pix0)
            continue
        end
        
        [ih,iw,it] = ind2sub([H,W,T],pix0);
        rgh = max(min(ih)-5,1):min(max(ih)+5,H);
        rgw = max(min(iw)-5,1):min(max(iw)+5,W);
        rgt = max(min(it)-10,1):min(max(it)+10,T);
        d0 = dF(rgh,rgw,rgt);
        e0 = evtMap(rgh,rgw,rgt);
        
        % refine region
        %[vox1,htMap0,fiu0] = refineRegionNoProp(d0,e0,nn,stdEst,delta);
        [vox1,htMap0a,fiu0] = refineRegion(d0,e0,nn,stdEst,delta);
        %zzshow(htMap0);zzshow(htMap0a);zzshow(fiu0);

        if ~isempty(vox1)
            [ih2,iw2,it2] = ind2sub(size(e0),vox1);
            ih2a = ih2+min(rgh)-1;
            iw2a = iw2+min(rgw)-1;
            it2a = it2+min(rgt)-1;
            evts{nn} = sub2ind([H,W,T],ih2a,iw2a,it2a);
        end
    end
end


function [vox1,htMap0,fiu0] = refineRegionNoProp(d0,e0,nn,stdEst,delta)    
    d0(e0>0 & e0~=nn) = -100;
    e0(e0~=nn) = 0;

    ix = find(d0==-100);
    d0(ix) = d0(ix) + randn(numel(ix),1)*stdEst;
    fiu0 = sum(e0,3)>0;
    
    % region to refine
    fiu0Di = imdilate(fiu0,strel('square',delta));
    fiuEr = imerode(fiu0,strel('square',delta));
    
    % get curves and z-scores
    d0Vec = reshape(d0,[],size(d0,3));
    charx0 = mean(d0Vec(fiu0>0,:),1);
    
    z0Vec = zeros(size(d0Vec,1),1);
    p0Vec = z0Vec;
    for ii=1:numel(z0Vec)
        [r,p] = corrcoef(charx0,d0Vec(ii,:));
        p0Vec(ii) = p(1,2);
        z00 = abs(norminv(p(1,2)/2));  % p value is two sided
        if r(1,2)>0
            z0Vec(ii) = z00;
        else
            z0Vec(ii) = -z00;
        end
    end
    zMap0 = reshape(z0Vec,size(fiu0));
    vMap0 = fiu0Di;
    
    % HTRG
    res0 = HTregionGrowingSuper(zMap0,vMap0,2,4,4,0);
    htMap00 = double(res0.connDmIDmap);
    htMap00 = htMap00.*fiu0Di;
    htMap00(fiuEr>0) = 1;
    
    % choose desired component
    cc = bwconncomp(htMap00>0);
    htMap0 = zeros(size(fiu0));
    lbl = labelmatrix(cc);
    lblx = lbl(fiu0>0 & lbl>0);
    
    % for new pixels. find it nearest existing neighbor for curves
    if ~isempty(lblx)
        lblSel = mode(lblx);
        htMap0(cc.PixelIdxList{lblSel}) = 1;
        
        [ih0,iw0] = find(htMap0>0 & fiu0==0);
        fiuInter = htMap0>0 & fiu0>0;
        [ih1,iw1] = find(fiuInter>0);
        e1 = e0.*htMap0;  % remove bad voxels
        for ii=1:numel(ih0)
            [~,ix0] = min((ih0(ii)-ih1).^2+(iw0(ii)-iw1).^2);
            e1(ih0(ii),iw0(ii),:) = e1(ih1(ix0),iw1(ix0),:);
        end
        vox1 = find(e1>0);
    else
        vox1 = [];
    end    
end


function [vox1,htMap0,fiu0] = refineRegion(d0,e0,nn,stdEst,delta)
    d0(e0>0 & e0~=nn) = -100;
    e0(e0~=nn) = 0;
    
    % FIXME imputation, set to NaN in real data?
    ix = find(d0==-100);
    d0(ix) = d0(ix) + randn(numel(ix),1)*stdEst;
    fiu0 = sum(e0,3)>0;
    
    % region to refine
    fiu0Di = imdilate(fiu0,strel('square',delta));
    fiuEr = imerode(fiu0,strel('square',delta));
    
    % partition according to rising time (level sets) and find z scores
    zMap0 = zeros(size(fiu0))-10;
    usedMap = zeros(size(fiu0));
    d0Vec = reshape(d0,[],size(d0,3));
    for tt=1:size(e0,3)
        tmp = e0(:,:,tt)>0 & usedMap==0;
        pixSel = find(tmp>0);        
        if isempty(pixSel)
            continue
        end
        usedMap(pixSel) = 1;
        
        % get z-scores
        charx0 = zscore(mean(d0Vec(pixSel,:),1),0,2); 
        d0Sel = zscore(d0Vec(pixSel,:),0,2);        
        r0Vec = mean(d0Sel.*charx0,2);        
        zMap0(pixSel) = getFisherTrans(r0Vec,size(e0,3));
    end
    
    vMap0 = fiu0Di;
    
    % HTRG Java code
    res0 = HTregionGrowingSuper(zMap0,vMap0,2,4,4,0);
    htMap00 = double(res0.connDmIDmap);
    htMap00 = htMap00.*fiu0Di;
    htMap00(fiuEr>0) = 1;
    
    % 
    
    
    
    % choose desired component
    cc = bwconncomp(htMap00>0);
    htMap0 = zeros(size(fiu0));
    lbl = labelmatrix(cc);
    lblx = lbl(fiu0>0 & lbl>0);
    
    % for new pixels. find it nearest existing neighbor for curves
    if ~isempty(lblx)
        lblSel = mode(lblx);
        htMap0(cc.PixelIdxList{lblSel}) = 1;
        
        [ih0,iw0] = find(htMap0>0 & fiu0==0);
        fiuInter = htMap0>0 & fiu0>0;
        [ih1,iw1] = find(fiuInter>0);
        e1 = e0.*htMap0;  % remove bad voxels
        for ii=1:numel(ih0)
            [~,ix0] = min((ih0(ii)-ih1).^2+(iw0(ii)-iw1).^2);
            e1(ih0(ii),iw0(ii),:) = e1(ih1(ix0),iw1(ix0),:);
        end
        vox1 = find(e1>0);
    else
        vox1 = [];
    end    
end




