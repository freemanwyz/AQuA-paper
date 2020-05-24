function reMappedBins = candReg(loc,sz,IoUThres)
    
    % parameter setting
    if ~exist('IoUThres','var')
        IoUThres = 0.05;        % for detection of microdomain candidate
    end
    %tpNum = 0;              % 0 means do not add any true positives
    %avgTimeInterval = 100;  % time interval of true positives, if tpNum=0, no use
    
    h = sz(1);
    w = sz(2);
    t = sz(3);
    
    % data preprocessing
    evtCnt = 1;
    for i=1:numel(loc)
        if ~isempty(loc{i})
            evtCnt = evtCnt+1;
        end
    end
    
    numEvt = evtCnt-1;
    EvtMap = zeros(numEvt,1);   % map the rearranged event label back to 'm'
    locy = zeros(numEvt,1);     % event center y-coordinate
    locx = zeros(numEvt,1);     % event center x-coordinate
    loct = zeros(numEvt,1);     % event start time
    mSize = zeros(numEvt,1);    % event size (2D)
    evtCells = cell(numEvt,1);  % event coordinates (2D)
    %actReg = false(h,w);        % active region
    evtCnt = 1;
    for i=1:numel(loc)
        if ~isempty(loc{i})
            EvtMap(evtCnt) = i;            
            [locyAll,locxAll, loctAll] = ind2sub([h,w,t],loc{i});            
            loc0 = sub2ind([h,w],locyAll,locxAll);
            mSize(evtCnt) = numel(unique(loc0));            
            loct(evtCnt) = min(loctAll); % start time
            uniLoc = unique([locyAll,locxAll],'rows');
            evtCells{evtCnt} = (uniLoc(:,2)-1)*h+uniLoc(:,1);
            locy(evtCnt) = round(mean(uniLoc(:,1)));
            locx(evtCnt) = round(mean(uniLoc(:,2)));
            %actReg(evtCells{evtCnt}) = true;
            evtCnt = evtCnt+1;
        end
    end
    
    % rearrange all events by time
    [loct,newOrder] = sort(loct,'ascend');
    locy = locy(newOrder);
    locx = locx(newOrder);
    mSize = mSize(newOrder);
    evtCells = evtCells(newOrder);
    EvtMap = EvtMap(newOrder);
    EvtRadiuses = sqrt(mSize/pi); % event radius: all events are viewed as circles
    
    %[actY,actX] = find(actReg);     % coordinates of active region
    %actSize = length(actY);
    
    % adjacent relationship based on IoU threshold
    PairwiseP = adjEvtMat(numEvt,locy,locx,loct,evtCells,IoUThres,EvtRadiuses);
    
    % get all microdomain candidates
    % e.g. bins{1} = [1,2,3] means this candidate contain event 1,2, and 3
    bins = evt2Bins(PairwiseP, numEvt);
    
    % remap the bins back to 'm'
    reMappedBins = cell(numel(bins),1);
    for i=1:numel(bins)
        reMappedBins{i} = EvtMap(bins{i});
    end    
    
end





