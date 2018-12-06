function [evtMap,regMap1,dlyMap1] = genSeCopyReal(sIdx,sucRt,initTime,p)
    % genSeCopy generate events in a super event to copy real data
    % First generate rising time map, then generate events from that map
    % Propagation speed is controlled by adjusting rising time map
    % to mimic real data
    %
    % Inputs:
    % suRt: a scaling factor applied on sucRtBase
    % initTime: start time for each seed
    %
    % -- Fields in p:
    % dtTot: total duration for real data
    % dtProp: propagation time (time to reach max area) for real data
    % cRiseMin: minimum rising time distance on boundary
    % speedUpProp: propagate faster and faster
    % sz: size of this SE
    % fg: foreground map limits the propagation
    % sucRtAvg: average success rate
    % sucRtBase: 2D map of base success rate
    %
    % Output:
    % evtMap: index movie of event voxels
    % regMap1: event 2D map in this SE
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
    
    % adjust propagation speed    
    maxRiseTime = nanmax(dlyMap1(:));
    dlyMap2 = dlyMap1/maxRiseTime*p.dtProp;
    stopMap = (~isnan(dlyMap2)).*(p.dtTot + nanmean(dlyMap2(:)));
    
    % signals
    dAct = zeros(p.sz(1),p.sz(2),p.sz(3)*p.dsRate);
    %dAct = zeros(p.sz(1),p.sz(2),ceil(max(stopMap(:)))+1);
    for hh=1:p.sz(1)
        for ww=1:p.sz(2)
            if ~isnan(dlyMap2(hh,ww))
                t0 = round(dlyMap2(hh,ww))+1;
                t1 = min(round(stopMap(hh,ww))+1,size(dAct,3));
                dAct(hh,ww,t0:t1) = 1;
            end
        end
    end
    
    % events
    evtMap = zeros(size(dAct));
    for ii=1:numel(pixLst1)
        evt0 = zeros(p.sz(1),p.sz(2));
        evt0(pixLst1{ii}) = ii;
        evtMap0 = repmat(evt0,1,1,size(dAct,3));
        evtMap0 = (dAct>0).*evtMap0;
        evtMap = max(evtMap,evtMap0);        
    end
        
end









