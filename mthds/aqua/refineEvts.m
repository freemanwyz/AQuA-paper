function evts = refineEvts(dat,evtLst,delta,osTb,showMe)
    % refineEvts use region growing to refine super events
    % dat: input data
    % evtLst: super events list
    % delta: dilation/erosion filter size for refinement range
    %
    
    if ~exist('showMe','var')
        showMe = 0;
    end
    
    % get noise level
    [H,W,T] = size(dat);
    xx = (dat(:,:,2:end)-dat(:,:,1:end-1)).^2;
    stdMap = sqrt(median(xx,3)/0.9133);
    stdEst = double(nanmedian(stdMap(:)));
    
    % transform to delta F
    datMA = movmean(dat,30,3);
    datMin = min(datMA,[],3);
    dF = dat - datMin;
    
    evts = cell(numel(evtLst,1));
    evtMap = lst2map(evtLst,size(dat));
    
    for nn=1:numel(evtLst)
        if mod(nn,1)==0
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
        if nn==51
            keyboard
        end
        [vox1,htMap0a,fiu0] = refineRegion(d0,e0,nn,stdEst,delta,osTb);
        if showMe
            zzshow(htMap0);zzshow(htMap0a);zzshow(fiu0);
        end

        if ~isempty(vox1)
            [ih2,iw2,it2] = ind2sub(size(e0),vox1);
            ih2a = ih2+min(rgh)-1;
            iw2a = iw2+min(rgw)-1;
            it2a = it2+min(rgt)-1;
            evts{nn} = sub2ind([H,W,T],ih2a,iw2a,it2a);
        end
    end
end





