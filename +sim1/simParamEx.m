function p=simParamEx(p)
    % Simulation data generation parameters for ex vivo data
    % Generate data at a higher sampling rate, then downsample for smooth
    % looking propagation
    %

    % domain: generate data based on domains
    % event: event based
    % roi_dbg: simplest ROI
    p.mthd = 'domain';
    
    % common
    p.nSe = 500;  % desired number of super events
    p.seDensity = 2;  % average number of new se per frame (after down-sampling)
    p.noProp = 0;  % avoid propagation
    p.dsRate = 5;  % data sampling rate
    p.xRate = p.dsRate;  % down-sample rate after simulation
    p.unifBri = 2;  % 2: same brightness for all pixels
    p.valMin = 0.05;  % minimum intensity to show
    
    % domain related
    p.fixed = 0;  % same propagation pattern in each event in a domain
    p.domainType = 'large';  % domain size distribution: large, average, random
    p.nDomain = 30;  % domain numbers. Larger ones generated first
    p.gapxy = 5;  % make domain far away enough spatially
    p.useSpk = 0;  % add sparklings
    p.sparklingSz = [9,25];  % sparkling size range
    p.sparklingDensity = 2;  % average number of sparklings per frame
    p.minArea = 64;
    p.dxSz = 100;
    p.circMax = inf;
    
    % separation, seed location and propagation (events)
    p.minPropSz = 500;  % minimum size to allow propagation
    p.evtArea = 500;  % number of pixel each evnet in an SE need. For small SE, only one event
    p.seedMinDist = 100;  % minimum distance between seeds in one super event
    
    p.propType = 'grow';  % growing or moving type propagation
    p.propTypeScore = 1;  % 1: growing type. 0: moving type.
    p.cRise = 2;  % temporal distance between seeds after downsample
    p.cRiseMin = p.dsRate*p.cRise;  % temporal distance between seeds before downsample
    p.seedRtAdd = 0.5;  % minimum success rate
    p.seedRtMul = 1;  % success rate scale
    p.sucRtAvg = (0.5*(1-p.seedRtAdd)+p.seedRtAdd)*p.seedRtMul;  % average success rate
    p.speedUpProp = 0;  % propagate faster and faster
    
    % temporal filter (post processing)
    p.tfUp = p.dsRate;  % onset part filter
    p.tfDn = 2*p.dsRate;  % offset part filter
    p.filter3D = sim1.getDecayFilter(p.tfUp,p.tfDn,0);  % filter in time direction
    p.ignoreFilterSpa = 0;
    p.ignoreFilterTemp = 0;
    p.smoXY = 1;
    
end
    
    