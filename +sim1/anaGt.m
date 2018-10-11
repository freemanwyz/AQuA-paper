function gt = anaGt(rIn,thrMin)
    % anaSNR get SNR information from ground truth
    
    datSim = rIn.xx.datSim;
    if isa(datSim,'uint16')
        datSim = double(datSim)/65535;
    end
    [H,W,~] = size(datSim);
    
    % prepare simulation ground truth and results
    rGt = rIn.xx;  % ground truth
    noiseStd = rIn.nStdVec;
    evtGt = rGt.evtLst;  
    
    gtMap = zeros(size(datSim));
    for ii=1:numel(evtGt)
        gtMap(evtGt{ii}) = ii;
    end
    gtMap(datSim<thrMin) = 0;  % remove too weak voxels from events
    evtGt = label2idx(gtMap);
    
    % pixel maps
    sigGt = zeros(numel(evtGt),1);
    sigGt1 = zeros(numel(evtGt),1);    
    evtGtPix = cell(numel(evtGt),1);
    for ii=1:numel(evtGt)
        vox0 = evtGt{ii};        
        [ih,iw,~] = ind2sub(size(datSim),vox0);
        ihw = sub2ind([H,W],ih,iw);
        ihw = unique(ihw);
        evtGtPix{ii} = ihw;
        sigGt(ii) = mean(datSim(vox0));
        xs = sort(datSim(vox0),'descend');
        xs = xs(xs>thrMin); sigGt1(ii) = mean(xs);
        %sigGt1(ii) = mean(xs(1:ceil(numel(xs)/2)));
    end
    %snrGt = 20*log10(sigGt./noiseStd);
    %snrGt1 = 20*log10(sigGt1./noiseStd);        

    sigMean = mean(datSim(datSim>0));
    %sigMean = mean(sigGt1);  % this gives higher signal intensity
    snrMov = 20*log10(sigMean./noiseStd);
    
    gt = [];
    gt.snr = snrMov;
    gt.sig = sigGt1;
    gt.evt = evtGt;
    gt.pix = evtGtPix;
    gt.noise = noiseStd;
    gt.sz = size(datSim);
    
end




