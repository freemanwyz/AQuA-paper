function [evtMap,regMap1,dlyMap2] = genSePropDelayTrun(sIdx,sucRt,initTime,p)
    % genSePropDelayTrun generate events in a super event (SE)
    % First generate rising time map, then truncate the map for needed delay
    % Less delay step --> smaller event. Duration kept same
    %
    % ONLY ONE EVENT PER SE
    %
    % Inputs:
    % suRt: a scaling factor applied on sucRtBase
    % initTime: start time for each seed
    %
    % -- Fields in p:
    % propAccel: multiplication on the rising time map
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
    [~,dlyMap1,~] = sim1.growSeed(sIdx,initTime,sucRt,[],p);
    
    % adjust propagation speed
    % durations for growing and moving are the same
    % largest delay is 10
    % the initial area should be large enough
    
    deltaT = 2;
    tMax0 = nanmax(dlyMap1(:));
    sMax0 = nansum(dlyMap1(:));
    for tt=0:tMax0
        if nansum(dlyMap1(:)<=tt)>=sMax0*0.95
            break
        end
    end
    tNow = tt;
    
    for uu=1:10
        dlyMax = 10+deltaT;
        dlyMapSlowest = dlyMap1/tNow*dlyMax*p.dsRate;
        dlyMap2 = dlyMapSlowest;
        dlyMap2(dlyMap2>(p.propAccel+deltaT)*p.dsRate) = nan;
        
        % fill small holes
        regMap1 = ~isnan(dlyMap2);
        xhole = find(imfill(regMap1,'holes')-regMap1);
        regMap1(xhole) = 1;
        pixLst1 = {find(regMap1>0)};
        
        % fill delay time
        [H,W] = size(dlyMap2);
        for ii=1:numel(xhole)
            [ih00,iw00] = ind2sub([H,W],xhole(ii));
            rgh00 = max(ih00-1,1):min(ih00+1,H);
            rgw00 = max(iw00-1,1):min(iw00+1,W);
            x00 = dlyMapSlowest(rgh00,rgw00);
            dlyMap2(ih00,iw00) = max(nanmean(x00(:)),0);
        end
        
        % set first deltaT*p.dsRate frames to 0
        dlyMap2 = dlyMap2 - deltaT*p.dsRate;
        dlyMap2(~isnan(dlyMap2) & dlyMap2<0) = 0;
        
        if sum(dlyMap2(:)<=0.1)>sMax0*0.1
            break
        end
        deltaT = deltaT+0.1;
    end
    %fprintf('Base time: %d\n',deltaT)
    
    if 0  % fix duration and speed
        durationTgtAvg = nanmean(dlyMapSlowest(:))+p.dsRate;
        if p.propTypeScore<0.5  % moving
            stopMap = dlyMap2+durationTgtAvg;
        else  % growing
            stopMap = (~isnan(dlyMap2)).*(durationTgtAvg + nanmean(dlyMap2(:)));
        end
    else  % fix speed only
        if p.propTypeScore<0.5  % moving
            %stopMap = dlyMap2+nanmean(dlyMap2(:))+2*p.dsRate;
            stopMap = dlyMap2+5*p.dsRate;
            %stopMap = dlyMap2+max(nanmean(dlyMap2(:)),2*p.dsRate);
        else  % growing
            stopMap = (~isnan(dlyMap2)).*(nanmax(dlyMap2(:))+2*p.dsRate);
        end
    end
    
%     figure;imagesc(stopMap);
%     keyboard
%     close
    
    % signals
    dAct = zeros(p.sz(1),p.sz(2),ceil(max(stopMap(:)))+1);
    for hh=1:p.sz(1)
        for ww=1:p.sz(2)
            if ~isnan(dlyMap2(hh,ww))
                t0 = round(dlyMap2(hh,ww))+1;
                t1 = round(stopMap(hh,ww))+1;
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









