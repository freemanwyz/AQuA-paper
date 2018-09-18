function [evtMap,regMap1,dlyMap1] = genSe(sIdx,sucRt,initTime,duraTime,p)
    % genSe generate events in a super event (SE)
    %
    % Inputs:
    % suRt: a scaling factor applied on sucRtBase
    % initTime: start time for each seed
    % duraTime: duration for each seed
    %
    % -- Fields in p: 
    % cRiseMin: minimum rising time distance on boundary
    % speedUpProp: propagate faster and faster
    % sz: size of this SE
    % fg: foreground map limits the propagation
    % sucRtAvg: average success rate
    % sucRtBase: 2D map of base success rate
    % maxTime: max extra time after propagation is done. This can clip duraTime
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
    duraTime1 = zeros(nEvt1,1);
    sucRt1 = zeros(nEvt1,1);
    regMap1 = zeros(p.sz(1),p.sz(2));
    for ii=1:nEvt1
        b0 = bins{ii};
        t0 = initTime(b0);
        [~,ix0] = min(t0);
        b0Sel = b0(ix0);
        sIdx1(ii) = sIdx(b0Sel);
        initTime1(ii) = min(initTime(b0));
        duraTime1(ii) = max(duraTime(b0));
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
    Tsim = nanmax(dlyMap1(:));
    dAct = zeros(p.sz(1),p.sz(2),Tsim+p.maxTime);
    for tt=1:Tsim+p.maxTime
        dAct(:,:,tt) = 1*(dlyMap1<=tt);
    end
    
    % end time determined by duration map
    dAct = reshape(dAct,[],size(dAct,3));
    for nn=1:numel(pixLst1)
        td0 = duraTime1(nn);
        pix0 = pixLst1{nn};
        for ii=1:numel(pix0)
            x = dAct(pix0(ii),:);
            t0 = find(x,1);
            x(t0+td0-1:end) = 0;
            dAct(pix0(ii),:) = x;
        end
    end
    dAct = reshape(dAct,[p.sz(1),p.sz(2),size(dAct,2)]);
    
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









