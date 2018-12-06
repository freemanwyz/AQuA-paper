function gt = anaGt(xx)
    % anaSNR get ground truth voxels, pixels and signals
    %
    % Do not removing weak signals here
    % Do not consider anything related to noise
    %
    
    datSim = xx.datSim;
    if isa(datSim,'uint16')
        datSim = double(datSim)/65535;
    end
    
    % prepare simulation ground truth and results
    evtGt = xx.evtLst;  
    
    gt = [];
    gt.sigMean = mean(datSim(datSim>0));
    gt.evt = evtGt;
    gt.pix = vox2pix(evtGt,size(datSim));
    gt.sz = size(datSim);
    
end




