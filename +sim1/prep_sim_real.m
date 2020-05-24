function xxLst = prep_sim_real(pIn,pOut,param,expSel,noiseStd)
    % stdVec is about the variable, like propagation speed
    % nStdVec is about SNR
    % each time load one experiment to reduce memory needed
    
    xxAll = matfile([pIn,param{1},'.mat']);
    p0 = xxAll.p0;
    
    if noiseStd>0
        nStdVec = noiseStd;
    else
        nStdVec = p0.nStdVec;
    end
    
    % each file can contain multiple movies
    datLst = xxAll.datLst(expSel,:);
    evtLst = xxAll.evtLst(expSel,:);
    nRep = numel(datLst);
    
    xxLst = cell(numel(expSel),nRep);
    for jj=1:nRep
        datSim = datLst{jj};
        evtSim = evtLst{jj};
        xx = [];
        
        sz = size(datSim);
        d = mod(sz(3),10);
        
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
        pixSim = vox2pix(evtSim,sz);
        evtSz = cellfun(@numel,pixSim);
        szMin = min(evtSz);
        sigx = double(mean(datSim(datSim>0)));
        
        % user setup
        xx.bgRt = 1;
        xx.zThrRt = 0.2;
        xx.saveMe = 1;
        
        % weakest signal, peak intensity times sqrt(size)
        xx.sigxU = nStdVec*sqrt(szMin)*0.9;
        
        % auto setup   
        xx.nRep = nRep;
        xx.evtSz = evtSz;
        xx.szMin = szMin;
        xx.evtRad = evtRad;
        xx.evtLst = evtSim;
        xx.pixLst = pixSim;  
        xx.dAvg = double(p0.dAvg);
        xx.HW = sz(1)*sz(2);
        xx.datSim = datSim;
        xx.sz = sz;        
        
        xx.pOut = pOut;
        xx.f1 = param{2};
        xx.f0 = [param{1},'_exp-',num2str(expSel)];      
        
        xx.nStdVec = nStdVec;
        xx.snrx = 20*log10(sigx/nStdVec);        
        xx.aquaPreset = param{3};
        xx.smoVec = param{4};
        
        xxLst{1,jj} = xx;
    end
    
end



