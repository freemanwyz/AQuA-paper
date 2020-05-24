function [datSim,evtLst,evtLstCore,seSim,dAvg,p0] = genExTop(pDat,f0,res)
    
    dat = readTiffSeq([pDat,f0,'.tif']);
    gapx = res.opts.regMaskGap;
    dat = dat(gapx+1:end-gapx,gapx+1:end-gapx,:);
    dat = dat/max(dat(:));
    dat = sqrt(dat);
    p = sim1.extractSe(dat,res.seLst);
    p = sim1.simParamEx(p);
    
    % generate events
    p0 = p;
    p0.nSe = 2000;
    p0.seDensity = 3;
    p0.ignoreFilterSpa = 0;
    p0.ignoreFilterTemp = 0;
    [datSim,evtSim,seSim] = sim1.genEx(p0);
    
    % expands events
    evtSimExt = evtSim;
    dh = [0,-1,1,0,0,0];
    dw = [-1,0,0,1,0,0];
    dt = [0,0,0,0,-1,1];
    [H,W,T] = size(datSim);
    for nn=1:100
        lst0 = find(evtSimExt==-1);
        if isempty(lst0)
            break
        end
        for ii=1:numel(lst0)
            if mod(ii,10000)==0
                fprintf('%d\n',round(100*ii/numel(lst0)))
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
    
    dAvg = mean(dat,3);
    evtLstCore = label2idx(evtSim);
    evtLst = label2idx(evtSimExt);
    
end


    