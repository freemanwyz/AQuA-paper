function [datSimNew,evtLst,evtLstCore] = postProcSimCopyReal(dOut,eOut,p)
    % spatial and temporally extend signals and adjust the event map
    % Do not make events larger or longer, just similar to real data
    %
    % spatial smoothing is performed first, and we remove signal lower than
    % p.valMin. After temporal smoothing, we keep the 20% to 20% signal, 
    % even the signal is lower than p.valMin
    %
    % For events that do not propagate, this makes the ground truth do not
    % change shape along time
    %

    % smooth simulated data
    datAct2 = dOut;
    if p.ignoreFilterSpa==0
        fprintf('Spatial filtering\n')
        for tt=1:size(datAct2,3)  % Gaussian smoothing to blur the boundary
            if mod(tt,1000)==0; fprintf('%d\n',tt); end
            tmp = datAct2(:,:,tt);
            tmp1 = imgaussfilt(tmp,p.smoXY);
            datAct2(:,:,tt) = tmp1;
        end
    end
    
    if p.ignoreFilterTemp==0
        fprintf('Temporal filtering\n')
        datAct3 = imfilter(datAct2,p.filter3D);  % mimic calcium dynamics       
    else
        datAct3 = datAct2;
    end
    
    % only keep signals in original events
    datAct3 = datAct3.*(dOut>0);
    
    % downsample the movie and event map
    datSim = datAct3(:,:,1:p.xRate:end);  
    evtSim = eOut(:,:,1:p.xRate:end);
    evtLstCore = label2idx(evtSim);
    
    % clean signals lower than 20% of peak
    evtLst = label2idx(evtSim);
    if p.ignoreFilterTemp==0
        evtMapNew = zeros(size(evtSim),'uint32');
        datSimNew = zeros(size(datSim),'single');        
        for ii=1:numel(evtLst)
            evt0 = evtLst{ii};
            if isempty(evt0)
                continue
            end
            [ih,iw,it] = ind2sub(size(datSim),evt0);
            rgh = min(ih):max(ih);
            rgw = min(iw):max(iw);
            rgt = min(it):max(it);
            evtMap0 = evtSim(rgh,rgw,rgt);
            evtMap0(evtMap0>0 & evtMap0~=ii) = 0;
            dat0 = datSim(rgh,rgw,rgt);
            dat0(evtMap0==0) = 0;
            dat0Max = max(dat0,[],3);  % peak value
            dat0Dif = dat0 - dat0Max*0.25;  % find those < 25% peak
            dat0(dat0Dif<0) = 0;
            evtMap0(dat0==0) = 0;
            evtMapNew(rgh,rgw,rgt) = max(evtMapNew(rgh,rgw,rgt),evtMap0);
            datSimNew(rgh,rgw,rgt) = max(datSimNew(rgh,rgw,rgt),dat0);
        end
    else
        evtMapNew = evtSim;
        datSimNew = datSim;
    end
    evtLst = label2idx(evtMapNew);
    
end


