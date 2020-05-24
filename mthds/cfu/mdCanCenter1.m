function [mdCan,evtCenter,evtIso,mdLen] = mdCanCenter1( locy,locx,locRad,minNum,resDist,rtRg )
%mdCanCenter1 Micordomian candidates and hub events
% multiple thresholds

% symmtric distance metric
% size ratio: abs(log(s1/s2))
% distance: residual_motion + f(r)

if ~exist('resDist','var')
    resDist = 2;
end
if ~exist('rtRg','var')
    rtRg = 2:10;  % size ratio thresholds
end

szEvt = pi*locRad.^2;
szInv = 1./szEvt;
szRatio = abs(log2(szEvt*szInv'));

disty = abs(locy - locy');
distx = abs(locx - locx');
distxy = sqrt(disty.^2+distx.^2);

r0 = repmat(locRad,1,numel(locRad));
r1 = repmat(locRad',numel(locRad),1);
r01 = max(r0,r1);

mdCan = [];  % microdomain candidates
evtCenter = [];  % microdomain center (hub) events

nCnt = 1;
connMatMask = ones(size(distxy));
for nn=rtRg
    fprintf('Ratio: %d\n',nn)
    
    % adjacency matrix
    connMat = (round(szRatio*1000/log2(nn))<1000 & distxy<(max(r01,resDist)+(nn-2)/2)).*connMatMask;
    connMat(eye(size(connMat))>0) = 0;
    
    % add events to existing hubs if they can belong to these hubs under current threshold
    if ~isempty(evtCenter)
        connMatCenter = connMat(evtCenter,:);
        distxyCenter = distxy(evtCenter,:);
        evtToAdd = find(sum(connMatCenter,1)>0);
        for ii=1:numel(evtToAdd)
            evtDist2Center = distxyCenter(:,evtToAdd(ii));
            [~,ix] = min(evtDist2Center);  % use minimum distance
            mdCan{ix} = union(mdCan{ix},evtToAdd(ii)); %#ok<AGROW>
            connMat(:,evtToAdd(ii)) = 0;  % an added event should disconnect all other events
            connMat(evtToAdd(ii),:) = 0;
            connMatMask(:,evtToAdd(ii)) = 0;
            connMatMask(evtToAdd(ii),:) = 0;
        end
    end

    % find new hubs
    while 1     
        if mod(nCnt,100)==0
            fprintf('%d\n',nCnt);
        end
        
        nNeib = sum(connMat,2);
        [nNeibCnt,ixCenter] = max(nNeib);
        
        % last threshold and others may have different minimum number of events requirement
        %if nNeibCnt<=2
        if (nNeibCnt<minNum && nn<rtRg(end)) || nNeibCnt==0  
            break
        end
        
        ixNeib = find(connMat(ixCenter,:));
        
        if sum(cell2mat(mdCan)==ixCenter)>0
            keyboard
        end

        mdCan{nCnt} = [ixNeib,ixCenter]; %#ok<AGROW>
        evtCenter(nCnt) = ixCenter; %#ok<AGROW>
        nCnt = nCnt + 1;

        % non-hub events disconnected from outside
        % hub connects events not belong to this MD
        connMat([ixNeib,ixCenter],:) = 0;  
        connMat(:,[ixNeib,ixCenter]) = 0;        
        connMatMask(ixNeib,:) = 0;
        connMatMask(:,ixNeib) = 0;
        connMatMask(ixNeib,ixCenter) = 0;  
        connMatMask(ixCenter,ixNeib) = 0;
    end    
end

% isolated events
evtIso = setdiff(1:numel(locx),unique(cell2mat(mdCan)));

mdIso = cell(1,numel(evtIso));
for kk=1:numel(evtIso)
    mdIso{kk} = evtIso(kk);
end

mdCan  = [mdCan,mdIso];
evtCenter = [evtCenter,evtIso];
mdLen = cellfun(@numel,mdCan);

end





