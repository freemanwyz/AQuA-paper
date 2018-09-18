function res0 = geci_pipe(datSimNy,thrSz)
    % geci_pipe is an automatic pipeline for GECI-quant
    % modified from GECI-quant by removing GUI parts
    % call Fiji using system call and parameters for ImageJ macro
    %
    % The only key parameter is the size in pixels, specified by thrSz
    % Auto thresholding works well in practice, we will add manual choice later
    %
    % Note: need to rename ImageJ executable to 'fiji' and add to path
    % Frame number must be divisible by 10, as we groups every 10
    %
    % DO NOT open file in macro; specify it in system call, otherwise we will
    % face problems when setting parameters in 'run' calls
    %
    % TODO: 
    % Expanding signal, but better to be done in Matlab
    % Manual thresholds for somatic and microdomain ROI detection
    %
    % Yizhi Wang, yzwang@vt.edu
    %
    
    % make temporary folder and write movie
    f2 = [tempdir,'geci',filesep];
    if ~exist(f2,'dir')
        mkdir(f2)
    end
    
    io.writeTiffSeq([f2,'sim.tif'],datSimNy);
    
    % pre-process
    % output is deBg.tif
    m0 = [pwd,'/mthds/geciquant/prep.ijm',' ',f2];
    p0 = [f2,'sim.tif'];
    system(['fiji',' ',p0,' ','-macro',' ',m0]);
    
    % domain detection
    % output is domain.zip and soma.zip
    p0 = [f2,'deBg.tif'];
    m0 = [pwd,'/mthds/geciquant/domain.ijm',' ',f2,',',num2str(thrSz)];
    system(['fiji',' ',p0,' ','-macro',' ',m0]);
    unzip([f2,'soma.zip'],[f2,'soma']);
    
    % segmentation for soma
    % output is soma_seg.zip for each soma
    p0 = [f2,'deBg.tif'];
    m0 = [pwd,'/mthds/geciquant/seg.ijm',' ',f2];
    system(['fiji',' ',p0,' ','-macro',' ',m0]);
    
    % gather ROIs
    % in this simulation, first ROI in each zip file is the boundary
    % for somatic or microdomain ROI detection, it is the whole FOV
    % for sub-domain, it is each somatic ROI
    fn = cell(0);
    fn{1} = [f2,'domain.zip'];
    xx = dir([f2,'soma',filesep,'*.zip']);
    fn1 = {xx.name};
    for nn=1:numel(xx)
        fn{1+nn} = [f2,'soma',filesep,fn1{nn}];
    end
    xroi = cell(0);
    for nn=1:numel(fn)
        xroi0 = ReadImageJROI(fn{nn});
        xroi0 = xroi0(2:end);
        xroi = [xroi,xroi0]; %#ok<AGROW>
    end
    
    % extract curve and get ROI list
    [H,W,T] = size(datSimNy);
    datVec = reshape(datSimNy,[],T);
    nRoi = numel(xroi);
    roiLst = cell(nRoi,1);
    bdLst = cell(nRoi,1);
    evtMap = zeros(H,W);
    dMat = zeros(nRoi,T);
    for nn=1:nRoi
        if mod(nn,100)==0
            fprintf('%d\n',nn)
        end
        xx = xroi{nn}.mnCoordinates;
        bw = poly2mask(xx(:,1),xx(:,2),H,W);
        roi0 = find(bw);
        evtMap(roi0) = nn;
        roiLst{nn} = roi0;
        roi0Bd = bwboundaries(bw>0);
        bdLst{nn} = roi0Bd;
        dMat(nn,:) = mean(datVec(roi0,:),1);
    end
    
    % dBg = min(movmean(dMat,20,2),[],2);
    % dff = (dMat - dBg)./dBg;
    
    res0 = [];
    res0.dff = dMat;
    res0.bdLst = bdLst;
    res0.roiLst = roiLst;
    res0.evtMap = evtMap;
        
end


