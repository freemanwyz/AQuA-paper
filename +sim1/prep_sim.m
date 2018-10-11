function xx = prep_sim(pIn,pOut,f0)       
    
    %xType = 'exvivo';
    global dbg
    
    xx = load([pIn,f0,'.mat']);
    
    % pad data for GECI-quant grouping, also need enough zeros for baseline
    datSim = xx.datSim;
    sz = size(datSim);
    d = mod(sz(3),10);
    datSim = cat(3,datSim,zeros(sz(1),sz(2),60-d,'uint16'));
    datSim = double(datSim)/65535;
    sz(3) = size(datSim,3);
    
    % radius for neurons    
    evtRad = nan(numel(xx.evtLst),1);    
    for nn=1:numel(xx.evtLst)
        evt0 = xx.evtLst{nn};
        [ih,iw,~] = ind2sub(sz,evt0);
        dh = max(ih)-min(ih);
        dw = max(iw)-min(iw);
        r = max(dh,dw)/2+1;
        evtRad(nn) = r*1.4;
    end
    
    % SNR
    pixLst = vox2pix(xx.evtLst,sz);
    evtSz = cellfun(@numel,pixLst);
    szMin = min(evtSz);    
    sigx = double(mean(datSim(datSim>0)));
    snrx = [0,2.5,5,7.5,10,15,20];

    % user setup
    xx.nRep = 1;
    xx.bgRt = 0;  % 0.5
    xx.zThrRt = 0.2;
    xx.saveMe = 0;
    xx.sigxU = 0.2*sqrt(szMin)*0.9;  % weakest signal, peak intensity times sqrt(size)
    xx.aqua_ver = 0;
    
    % auto setup
    xx.evtSz = evtSz;
    xx.szMin = szMin;
    xx.evtRad = evtRad;
    xx.sigx = sigx;
    xx.snrx = snrx;
    xx.pixLst = pixLst;
    xx.pOut = pOut;
    xx.f0 = f0;    
    xx.nStdVec = sigx./(10.^(snrx/20));
    xx.smoVec = flip([0.1,0.5,0.6,0.7,0.8,0.9,1]);
    xx.dAvg = double(xx.dAvg);
    xx.HW = sz(1)*sz(2);
    xx.t0 = datestr(datetime(),'yyyymmddHHMMSS');
    xx.datSim = datSim;
    xx.sz = sz;
    
    dbg.evtLst = xx.evtLst;
        
end



