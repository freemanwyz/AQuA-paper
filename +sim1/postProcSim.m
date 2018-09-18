function [datSim,evtLst,evtLstCore] = postProcSim(dOut,eOut,p)
    
    valMin = p.valMin;
    dOut(dOut<valMin) = 0;
    
    % smooth simulated data
    datAct2 = dOut;
    if p.ignoreFilterSpa==0
        fprintf('Spatial filtering\n')
        for tt=1:size(datAct2,3)  % Gaussian smoothing to blur the boundary
            if mod(tt,1000)==0; fprintf('%d\n',tt); end
            tmp = datAct2(:,:,tt);
            tmp1 = imgaussfilt(tmp,p.smoXY);
            tmp1(tmp1<valMin) = 0;  % avoid too weak signals
            datAct2(:,:,tt) = tmp1;
        end
        xNew = datAct2>0 & dOut==0;
        eOut(xNew) = -1;
        %eOut(datAct2<valMin) = 0;  % avoid too weak signals
        %datAct2(datAct2<valMin) = 0;
    end
    
    if p.ignoreFilterTemp==0
        fprintf('Temporal filtering\n')
        datAct3 = imfilter(datAct2,p.filter3D);  % mimic calcium dynamics
        datAct3(datAct3<valMin) = 0;   % avoid too weak signals     
        xNew = datAct3>0 & datAct2==0;
        eOut(xNew) = -1;
        %eOut(datAct3<valMin) = 0;  % avoid too weak signals        
    else
        datAct3 = datAct2;
    end
    
    % downsample the movie and event map
    datSim = datAct3(:,:,1:p.xRate:end);  
    evtSim = eOut(:,:,1:p.xRate:end);
    
    % extend event map
    evtSimExt = evtSim;
    dh = [0,-1,1,0,0,0];
    dw = [-1,0,0,1,0,0];
    dt = [0,0,0,0,-1,1];
    [H,W,T] = size(datSim);
    for nn=1:100
        lst0 = find(evtSimExt==-1);
        lst0 = lst0(randperm(numel(lst0)));  % avoid strange patterns
        
        if isempty(lst0)
            break
        end
        for ii=1:numel(lst0)
            if mod(ii,10000)==0
                fprintf('%d\n',100*ii/numel(lst0))
            end
            vox0 = lst0(ii);
            [ih0,iw0,it0] = ind2sub([H,W,T],vox0);
            ih1 = min(max(ih0+dh,1),H);
            iw1 = min(max(iw0+dw,1),W);
            it1 = min(max(it0+dt,1),T);
            vox1 = sub2ind([H,W,T],ih1,iw1,it1);
            x = evtSimExt(vox1);
            x = x(x>0);
            if ~isempty(x)
                evtSimExt(vox0) = x(1);
            end
        end
    end
        
    evtLstCore = label2idx(evtSim);
    evtLst = label2idx(evtSimExt);    
    
end


