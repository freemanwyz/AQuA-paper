function res = suite2p_wyz(dat,db)
    % suite2p_wyz is top level file for Suite2P
    % modified by Yizhi, use data as input
    % intermediate things are written to temp folder
    %
    
    addpath(genpath('..\..\repo\OASIS_matlab\'));
    ops0.toolbox_path = '..\..\repo\Suite2P\';
    addpath(genpath(ops0.toolbox_path)) % add local path to the toolbox
    
    % folder structure, useless
    db.mouse_name = 'xx';
    db.date = 'xx';
    db.expts = [];  % leave empty, or specify subolders as numbers
    %db.diameter = diameter;  % do specify the "diameter" of an average cell
    db.RootStorage = [tempdir,'suite2p',filesep];  % specify full path to tiffs here
    if ~exist(db.RootStorage,'dir')
        mkdir(db.RootStorage);
    end    
    db.expred = [];
    
    folderPrj = tempdir;
    
    % write TIFF file
    fTmp = [db.RootStorage,db.mouse_name,filesep,db.date,filesep];
    if ~exist(fTmp,'dir')
        mkdir(fTmp);
    end
    writeTiffSeq([fTmp,'sim.tif'],dat);
    
    % mex -largeArrayDims SpikeDetection/deconvL0.c (or .cpp) % MAKE SURE YOU COMPILE THIS FIRST FOR DECONVOLUTION
    
    
    % parameters
    % -----------------
    
    ops0.useGPU                 = 0; % if you can use an Nvidia GPU in matlab this accelerates registration approx 3 times. You only need the Nvidia drivers installed (not CUDA).
    ops0.fig                    = 1; % turn off figure generation with 0
    % ops0.diameter               = 12; % most important parameter. Set here, or individually per experiment in make_db file
    
    % ---- root paths for files and temporary storage (ideally an SSD drive. my SSD is C:/)
    %ops0.RootStorage            = ''; % Suite2P assumes a folder structure, check out README file
    ops0.temp_tiff              = [folderPrj,'temp.tif']; % copies each remote tiff locally first, into this file
    ops0.RegFileRoot            = folderPrj;  % location for binary file
    ops0.DeleteBin              = 1; % set to 1 for batch processing on a limited hard drive
    ops0.ResultsSavePath        = folderPrj; % a folder structure is created inside
    ops0.RegFileTiffLocation    = folderPrj; % leave empty to NOT save registered tiffs (slow)
    % if you want to save red channel tiffs, also set ops0.REDbinary = 1
    
    % ---- registration options ------------------------------------- %
    ops0.doRegistration         = 0; % skip (0) if data is already registered
    ops0.showTargetRegistration = 1; % shows the image targets for all planes to be registered
    ops0.PhaseCorrelation       = 1; % set to 0 for non-whitened cross-correlation
    ops0.SubPixel               = Inf; % 2 is alignment by 0.5 pixel, Inf is the exact number from phase correlation
    ops0.NimgFirstRegistration  = 500; % number of images to include in the first registration pass
    ops0.nimgbegend             = 0; % frames to average at beginning and end of blocks
    ops0.dobidi                 = 1; % infer and apply bidirectional phase offset
    
    % ---- cell detection options ------------------------------------------%
    ops0.ShowCellMap            = 1; % during optimization, show a figure of the clusters
    ops0.sig                    = 0.5;  % spatial smoothing length in pixels; encourages localized clusters
    ops0.nSVDforROI             = 1000; % how many SVD components for cell clustering
    ops0.NavgFramesSVD          = 5000; % how many (binned) timepoints to do the SVD based on
    ops0.signalExtraction       = 'surround'; % how to extract ROI and neuropil signals:
    %  'raw' (no cell overlaps), 'regression' (allows cell overlaps),
    %  'surround' (no cell overlaps, surround neuropil model)
    
    % ----- neuropil options (if 'surround' option) ------------------- %
    % all are in measurements of pixels
    ops0.innerNeuropil  = 1; % padding around cell to exclude from neuropil
    ops0.outerNeuropil  = Inf; % radius of neuropil surround
    % if infinity, then neuropil surround radius is a function of cell size
    
    if isinf(ops0.outerNeuropil)
        ops0.minNeuropilPixels = 400; % minimum number of pixels in neuropil surround
        ops0.ratioNeuropil     = 5; % ratio btw neuropil radius and cell radius
        % radius of surround neuropil = ops0.ratioNeuropil * (radius of cell)
    end
    
    % ----- spike deconvolution and neuropil subtraction options ----- %
    ops0.imageRate              = 1; % imaging rate (cumulative over planes!). Approximate, for initialization of deconvolution kernel.
    ops0.sensorTau              = 1; % decay half-life (or timescale). Approximate, for initialization of deconvolution kernel.
    ops0.maxNeurop              = 1; % for the neuropil contamination to be less than this (sometimes good, i.e. for interneurons)
    
    % ----- if you have a RED channel -------------------------------- %
    ops0.AlignToRedChannel      = 0; % compute registration offsets using red channel
    ops0.REDbinary              = 0; % make a binary file of registered red frames
    
    ops0.redMeanImg             = 0;
    ops0.redthres               = 1.5; % the higher the thres the less red cells
    ops0.redmax                 = 1; % the higher the max the more NON-red cells
    
    
    % RUN THE PIPELINE HERE
    % -----------------------------------
    run_suite2p(db, ops0);
    
    % deconvolved data into st, and neuropil subtraction coef in stat
    add_deconvolution(ops0, db);
    
    
    % output
    % --------------
    res = save4Suite2p(ops0,db);
    
end


