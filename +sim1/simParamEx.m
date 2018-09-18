function p=simParamEx(p)
    % Simulation data generation parameters for ex vivo data

    p.nSe = numel(p.se);  % desired number of super events
    p.seDensity = p.nSe/p.sz(3);  % average number of new se per frame (after down-sampling)
    p.evtArea = 500;  % number of pixel each evnet in an SE need. For small SE, only one event
    p.dsRate = 5;  % data sampling rate
    p.xRate = p.dsRate;  % down-sample rate
    p.minPropSz = 200;  % minimum size to allow propagation
    p.valMin = 0.05;  % minimum intensity to show
    
    % domain related
    p.useDomain = 0;  % generate data based on domains
    p.fixed = 0;  % same propagation pattern in each event in a domain
    p.domainType = 'random';  % domain size distribution
    p.nDomain = 100;  % domain numbers. Larger ones generated first
    p.noProp = 0;  % avoid propagation
    p.unifBri = 0;  % same brightness for all pixels
    
    % seed location and propagation (events)
    p.seedMinDist = 30;  % minimum distance between seeds in one super event
    p.cRise = 2;  % temporal distance between seeds after downsample
    p.cRiseMin = p.dsRate*p.cRise;  % temporal distance between seeds before downsample
    p.seedRtAdd = 0.5;  % minimum success rate
    p.seedRtMul = 1;  % success rate scale
    p.sucRtAvg = (0.5*(1-p.seedRtAdd)+p.seedRtAdd)*p.seedRtMul;  % average success rate
    p.speedUpProp = 0;  % propagate faster and faster
    
    % temporal filter (post processing)
    p.tfUp = p.dsRate;  % onset part filter
    p.tfDn = 2*p.dsRate;  % offset part filter
    p.filter3D = sim1.getDecayFilter(p.tfUp,p.tfDn);  % filter in time direction
    p.ignoreFilterSpa = 0;
    p.ignoreFilterTemp = 0;
    p.smoXY = 0.5;
    
end
    
    