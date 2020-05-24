function [evtMap,regMap1,dlyMap1] = genSe(sIdx,sucRt,initTime,p)
    % genSe generate events in a super event (SE)
    % First generate rising time map, then generate events from that map
    %
    % Inputs:
    % suRt: a scaling factor applied on sucRtBase
    % initTime: start time for each seed
    %
    % -- Fields in p:
    % cRiseMin: minimum rising time distance on boundary
    % speedUpProp: propagate faster and faster
    % sz: size of this SE
    % fg: foreground map limits the propagation
    % sucRtAvg: average success rate
    % sucRtBase: 2D map of base success rate
    %
    % Output:
    % evtMap: index movie of event voxels
    % regM1: event 2D map in this SE
    % dlyMap1: onset time map for this SE
    %

    % generate events region and delay maps by region growing
    [regMap,dlyMap,pixLst] = sim1.growSeed(sIdx,initTime,sucRt,[],p);
    
    % merge non-detectable events
    if numel(sIdx)>1
        bins = sim1.mergeSeed(regMap,dlyMap,initTime,p.cRiseMin,0);
    else
        bins = {1};
    end
    
    % update seed information
    nEvt1 = numel(bins);
    sIdx1 = zeros(nEvt1,1);
    initTime1 = zeros(nEvt1,1);
    sucRt1 = zeros(nEvt1,1);
    regMap1 = zeros(p.sz(1),p.sz(2));
    for ii=1:nEvt1
        b0 = bins{ii};
        t0 = initTime(b0);
        [~,ix0] = min(t0);
        b0Sel = b0(ix0);
        sIdx1(ii) = sIdx(b0Sel);
        initTime1(ii) = min(initTime(b0));
        sucRt1(ii) = sucRt(b0Sel);
        for jj=1:numel(b0)
            regMap1(pixLst{b0(jj)}) = ii;
        end
    end
    
    % update region and delay map
    if numel(sIdx1)<numel(sIdx)
        [regMap1,dlyMap1,pixLst1] = sim1.growSeed(sIdx1,initTime1,sucRt1,regMap1,p);
    else
        dlyMap1 = dlyMap; pixLst1 = pixLst;
    end
    
    % 2D map to data, with beginning time
    % clip by extTime
    maxRiseTime = nanmax(dlyMap1(:));
    extTime = max(4*p.dsRate,ceil(maxRiseTime/2));
    dAct = zeros(p.sz(1),p.sz(2),maxRiseTime+extTime);
    for tt=1:maxRiseTime+extTime
        dAct(:,:,tt) = 1*(dlyMap1<=tt);
    end
    
    % duration as a function of Tsim and extTime
    % if td0~extTime, then behaves like moving
    % if td0>>extTime, then looks like growing
    dAct = reshape(dAct,[],size(dAct,3));
    k = p.propTypeScore;
    for nn=1:numel(pixLst1)
        td0 = k*maxRiseTime+extTime+2;  % FIXME: set k as a parameter
        %td0 = duraTime1(nn);
        pix0 = pixLst1{nn};
        for ii=1:numel(pix0)
            x = dAct(pix0(ii),:);
            t0 = find(x,1);
            x(t0+td0-1:end) = 0;
            dAct(pix0(ii),:) = x;
        end
    end
    dAct = reshape(dAct,[p.sz(1),p.sz(2),size(dAct,2)]);
    
    % (optional) make propagation faster
    % !! OK for growing type, strange for moving type
    if p.propAccel>0
        dAct0 = dAct(:,:,1:maxRiseTime);
        dAct1 = dAct(:,:,maxRiseTime+1:end);
        dAct0a = dAct0(:,:,1:p.propAccel:end);
        dt = size(dAct0,3) - size(dAct0a,3);
        dAct0b = repmat(dAct0(:,:,end),1,1,dt);
        dAct = cat(3,dAct0a,dAct0b,dAct1);
    end    
    
    % event map
    evtMap = zeros(size(dAct));
    for ii=1:numel(pixLst1)
        evt0 = zeros(p.sz(1),p.sz(2));
        evt0(pixLst1{ii}) = ii;
        evtMap0 = repmat(evt0,1,1,size(dAct,3));
        evtMap0 = (dAct>0).*evtMap0;
        evtMap = max(evtMap,evtMap0);        
    end   
        
end









