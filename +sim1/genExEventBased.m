function [datSim,evtLst,evtLstCore,seSim] = genExEventBased(p)
    % generate super events and events

    dOut = zeros(p.sz(1),p.sz(2),ceil(p.nSe/p.seDensity*p.dsRate),'single');
    eOut = zeros(size(dOut),'int32');
    
    seSim = cell(0);
    evtCnt = 0;
    seCnt = 1;
    
    % sampling from real data
    % large events first    
    seSz = zeros(numel(p.se),1);
    for ii=1:numel(p.se)  % event size in 2D
        pix0 = p.sePix{ii};
        if ~isempty(pix0)
            seSz(ii) = sum(pix0(:)>0);
        end
    end
    [seSzSt,seIdx] = sort(seSz,'descend');  % large ones first
    seIdx = seIdx(seSzSt>p.minArea);
    if numel(seIdx)<p.nSe
        idxVec = randsample(seIdx,ceil(p.nSe),'true');  % if not enough
        [~,idx0] = sort(seSz(idxVec),'descend');
        idxVec = idxVec(idx0);
    else
        idxVec = seIdx(1:p.nSe);
    end    
        
    % generate events and add to movie
    for nn=1:numel(idxVec)
        fprintf('S.evt: %d\n',nn)        
        idx = idxVec(nn);
        
        % generate an event or a super event
        [p1,seedIdx,initTime,sucRt] = sim1.initEvt(p,idx);
        [evtMap,regMap,dlyMap] = sim1.genSe(seedIdx,sucRt,initTime,p1);
        if p.noProp==1 || seSz(idx)<p.minPropSz
            regMap = 1*(regMap>0);
            x0 = sum(reshape(evtMap,[],size(evtMap,3)),1);
            t0 = find(x0>0,1);
            t1 = find(x0>0,1,'last');
            evtMap = evtMap*0;
            for tt=t0:t1
                evtMap(:,:,tt) = regMap;
            end
        end
        
        xx = regMap(regMap>0);
        if numel(unique(xx))==0
            fprintf('Failed to generate\n')
            continue
        end
        
        % trim events to pixel map (optional)
        evtMap = evtMap.*p1.pixMap;
        regMap = regMap.*p1.pixMap;
        dlyMap(p1.pixMap==0) = nan;
        
        % relative intensity for pixels
        mskIntensity = p.sePg{idx,2};
        switch p.unifBri
            case 0
                datSeVal = (evtMap>0).*mskIntensity*p.seBri(idx);
            case 1
                datSeVal = (evtMap>0)*p.seBri(idx)*0.5;
            case 2
                datSeVal = (evtMap>0)*0.2;
        end
        datSeVal(datSeVal>0) = max(datSeVal(datSeVal>0),p.valMin);
                
        % find earliest valid frame on dilated pixel map
        rgh1 = p.seRg(idx,1):p.seRg(idx,2);
        rgw1 = p.seRg(idx,3):p.seRg(idx,4);
        rgh2 = max(min(rgh1)-p.gapxy,1):min(max(rgh1)+p.gapxy,p.sz(1));
        rgw2 = max(min(rgw1)-p.gapxy,1):min(max(rgw1)+p.gapxy,p.sz(2));
        
        regMap1 = zeros(numel(rgh2),numel(rgw2));
        regMap1(rgh1-min(rgh2)+1,rgw1-min(rgw2)+1) = regMap>0;  % put to large volume        
        act0 = dOut(rgh2,rgw2,:);
        msk0 = imdilate(regMap1,strel('square',2*p.gapxy+1));
        act0x = act0.*msk0;
        act0x = sum(reshape(act0x,[],size(dOut,3)))>0;  % already used frames
        
        tSlotMin = size(datSeVal,3)+2*numel(p.filter3D)+6*p.dsRate;  % frame number for this SE
        
        xx = find(act0x>0);
        t0 = [];
        if isempty(xx)  % random find the frame to put
            t0 = randi(size(dOut,3)-tSlotMin);
        else  % find frame with enough space
            xx1 = [1,xx,size(dOut,3)];
            xx1Dif = xx1(2:end) - xx1(1:end-1);
            x00 = find(xx1Dif>tSlotMin);
            
            if ~isempty(x00)
                idx1 = x00(randi(numel(x00)));  % randomly choose one slot
                a = xx1(idx1)+numel(p.filter3D)+3*p.dsRate;
                b = xx1(idx1+1)-size(datSeVal,3)-numel(p.filter3D)-3*p.dsRate;
                if a<b
                    t0 = randi([a,b]);  % randomly choose one frame
                end
            end
        end
        
        % add SE to movie
        if ~isempty(t0)
            tx = size(datSeVal,3);
            rgt = t0:t0+tx-1;
            
            dOut(rgh1,rgw1,rgt) = dOut(rgh1,rgw1,rgt) + single(datSeVal);
            evtMap(evtMap>0) = evtMap(evtMap>0)+evtCnt;
            evtCnt = max(evtMap(:));
            eOut(rgh1,rgw1,rgt) = max(eOut(rgh1,rgw1,rgt),int32(evtMap));
            
            xx = [];
            xx.rgh = rgh1; xx.rgw = rgw1; xx.rgt = rgt;
            xx.onset = dlyMap;
            seSim{seCnt} = xx;
            seCnt = seCnt + 1;            
        else
            fprintf('Failed to find place\n')
        end
        
        if seCnt>=p.nSe
            break
        end
    end
    
    % post-processing
    [datSim,evtLst,evtLstCore] = sim1.postProcSim(dOut,eOut,p);
    
end





