function [resx,iouVox] = mthd_aqua_real(xxLst)

    fp = '../../repo/aqua_20180705/';
    mthdName = 'aqua-stable';
    addpath(genpath(fp));
    
    nRep = numel(xxLst);

    xx = xxLst{1};
    resx = cell(numel(xx.nStdVec),xx.nRep);
    iouVox = zeros(numel(xx.nStdVec),xx.nRep);
    iouPix = zeros(numel(xx.nStdVec),xx.nRep);
    opts = parseParam(xx.aquaPreset,0,'parameters1.csv');
    
    opts.regMaskGap = 0;
    opts.usePG = 0;
    opts.cRise = 1.5;  % 1.5
    opts.cDelay = 1.5;  % 1.5
    opts.cOver = 0;
    opts.minShow1 = 0.2;  % 0.2
    opts.useRawNoiseLevel = 0;
    opts.minSize = 8;
    
    %opts.thrARScl = 3;
    opts.thrTWScl = 4;  % !!
    %opts.thrExtZ = 1.5;
    opts.zThr = 5;
    %opts.gtwSmo = 2;
    %opts.gtwGapSeedRatio = 16;    
    
    kk=1; ii=1; %#ok<NASGU>
    for ii=1:numel(xx.nStdVec)
        fprintf('Aqua Std %d ==================\n',xx.nStdVec(ii));
        for kk=1:nRep
            yy = xxLst{kk};
            datSimNy = yy.datSim + yy.dAvg*yy.bgRt + randn(yy.sz)*yy.nStdVec(ii)+0.2;            
            
            opts1 = opts;
            opts1.smoXY = yy.smoVec(ii);
            res0 = aqua_top(datSimNy,opts1);
            if ~isempty(res0)                
                res0.pixLst = vox2pix(res0.evt,yy.sz);                
                [iouVoxD2G,iouPixD2G] = sim1.IoU(res0.evt,res0.pixLst,yy.evtLst,yy.pixLst,yy.sz);
                [iouVoxG2D,iouPixG2D] = sim1.IoU(yy.evtLst,yy.pixLst,res0.evt,res0.pixLst,yy.sz);
                iouVox(ii,kk) = (nanmean(iouVoxD2G)+nanmean(iouVoxG2D))/2;
                iouPix(ii,kk) = (nanmean(iouPixD2G)+nanmean(iouPixG2D))/2;
                
                res0a = [];
                res0a.evt = res0.evt;
                res0a.z = res0.z;
                res0a.fts = res0.fts;
                res0a.opts = res0.opts;
                resx{ii,kk} = res0a;
            end
        end
        csvwrite(['./tmp/',mthdName,'_',xx.f0,'_vox.csv'],iouVox);
        %csvwrite(['./tmp/',mthdName,'_',xx.f0,'_pix.csv'],iouPix);
    end
    
    if xx.saveMe>0
       iouVol = iouVox; nStdVec = xx.nStdVec; f0 = xx.f0; %#ok<NASGU>
       fOut = [xx.pOut,xx.f1,'_',mthdName,'_',xx.f0,'.mat'];
       save(fOut,'resx','nStdVec','iouVol','f0','-v7.3');
    end
    %zzshow(regionMapWithData(xx.evtLst,zeros(size(xx.datSim))),'evt,gt')
    %zzshow(regionMapWithData(res0.evt,zeros(size(xx.datSim))),'evt,all')
    
    rmpath(genpath(fp));
    
end


