% simulation for simple patterns
opts = util.parseParam(4,0,'./cfg/parameters_sim.csv');

% generate data
lblMap = sim.genMovSquareSizeDuration();
evtLst = label2idx(lblMap);
opts.sz = size(lblMap);
dat = 0.5*(lblMap>0) + randn(opts.sz)*0.05;

% regions and landmarks
regLst = []; regLst{1} = 1:opts.sz(1)*opts.sz(2);
lmkLst = []; lmkLst{1} = 1;

% detection
fts = sim.detectionBatchPipeline(dat,opts,regLst,lmkLst);



