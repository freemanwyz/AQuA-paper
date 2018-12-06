function xxLst = prep_sim(pIn,pOut,f0,simIdx,snrx,smox,expSel,nRepUsed)
    % stdVec is about the variable, like propagation speed
    % nStdVec is about SNR
    % each time load one experiment to reduce memory needed
    
    %xType = 'exvivo';
    %global dbg
    
    xxAll = matfile([pIn,f0,num2str(simIdx),'.mat']);
    p0 = xxAll.p0;
    
    % each file can contain multiple movies
    datLst = xxAll.datLst(expSel,:);
    evtLst = xxAll.evtLst(expSel,:);
    nRep = min(nRepUsed,numel(datLst));
    
    if ~exist('snrx','var') || isempty(snrx)
        snrx = [0,2.5,5,7.5,10,15,20];
        smox = flip([0.1,0.5,0.6,0.7,0.8,0.9,1]);
    end
    
    xxLst = cell(numel(expSel),nRep);
    for jj=1:nRep
        datSim = datLst{jj};
        evtSim = evtLst{jj};
        xx = [];
        
        sz = size(datSim);
        d = mod(sz(3),3);
        
        % pad data for GECI-quant grouping, also need enough zeros for baseline
        datSim = cat(3,datSim,zeros(sz(1),sz(2),60-d,'uint16'));
        datSim = double(datSim)/65535;
        sz(3) = size(datSim,3);
        
        % radius for neurons
        evtRad = nan(numel(evtSim),1);
        for nn=1:numel(evtSim)
            evt0 = evtSim{nn};
            [ih,iw,~] = ind2sub(sz,evt0);
            dh = max(ih)-min(ih);
            dw = max(iw)-min(iw);
            r = max(dh,dw)/2+1;
            evtRad(nn) = r*1.4;
        end
        
        % SNR
        pixLst = vox2pix(evtSim,sz);
        evtSz = cellfun(@numel,pixLst);
        szMin = min(evtSz(evtSz>0));
        sigx = double(mean(datSim(datSim>0)));
        
        % user setup
        xx.nRep = 1;
        xx.bgRt = 1;  % 0.5
        xx.zThrRt = 0.2;
        xx.saveMe = 0;
        
        % weakest signal, peak intensity times sqrt(size)
        xx.sigxU = max(datSim(:))*sqrt(szMin)*0.9;
        xx.aqua_ver = 0;
        
        % auto setup
        xx.evtSz = evtSz;
        xx.szMin = szMin;
        xx.evtRad = evtRad;
        xx.sigx = sigx;
        xx.snrx = snrx;
        xx.evtLst = evtSim;
        xx.pixLst = pixLst;
        xx.pOut = pOut;
        xx.f0 = [f0,'_exp-',num2str(expSel)];
        xx.nStdVec = sigx./(10.^(snrx/20));
        xx.smoVec = smox;
        xx.dAvg = double(p0.dAvg);
        xx.HW = sz(1)*sz(2);
        xx.t0 = [];
        xx.datSim = datSim;
        xx.sz = sz;
        
        xxLst{1,jj} = xx;
    end
    
    %dbg.evtLst = evtLst;
    
end



