function mthd_aquaDbg(xx,vSel)
    
    if ~exist('vSel','var')
        vSel = 0;
    end
    if vSel==0
        fp = '../../repo/aqua_20180705/';
        mthdName = 'aqua-stable';
    else
        fp = '../../repo/aqua/';
        mthdName = 'aqua-dev';
    end
    addpath(genpath(fp));

    resx = cell(numel(xx.nStdVec),xx.nRep);
    iouxxAqua = zeros(numel(xx.nStdVec),xx.nRep);
    iouxxAqua2D = zeros(numel(xx.nStdVec),xx.nRep);
    opts = util.parseParam(3,0,'parameters1.csv');
    opts.regMaskGap = 0;
    opts.usePG = 0;
    opts.cRise = 1.5;  % 1.5
    opts.cDelay = 1.5;  % 1.5
    opts.cOver = 0;
    opts.minShow1 = 0.2;  % 0.2
    opts.useRawNoiseLevel = 0;
        
    %opts.smoXY = 0.1+max(xx.nStdVec(ii)-0.01,0)*5;  % default
    %opts.minSize = round(8+opts.smoXY*8);
    opts.minSize = 16;
    
    opts.thrARScl = 3;
    opts.thrTWScl = 4;  % !!
    opts.thrExtZ = 1.5;
    opts.zThr = 5;
    opts.gtwSmo = 2;
    opts.gtwGapSeedRatio = 16;    
    
    kk=1; ii=1; %#ok<NASGU>
    for ii=1:numel(xx.nStdVec)
        fprintf('Aqua Std %d ==================\n',xx.nStdVec(ii));
        parfor kk=1:xx.nRep            
            datSimNy = xx.datSim + xx.dAvg*xx.bgRt + randn(xx.sz)*xx.nStdVec(ii)+0.2;            
            
            opts1 = opts;
            opts1.smoXY = xx.smoVec(ii);
            res0 = aqua_top(datSimNy,opts1);
            if ~isempty(res0)                
                res0.pixLst = vox2pix(res0.evt,xx.sz);                
                [iouVoxD2G,iouPixD2G] = sim1.IoU(res0.evt,res0.pixLst,xx.evtLst,xx.pixLst,xx.sz);
                [iouVoxG2D,iouPixG2D] = sim1.IoU(xx.evtLst,xx.pixLst,res0.evt,res0.pixLst,xx.sz);
                iouxxAqua(ii,kk) = (nanmean(iouVoxD2G)+nanmean(iouVoxG2D))/2;
                iouxxAqua2D(ii,kk) = (nanmean(iouPixD2G)+nanmean(iouPixG2D))/2;
                
                res0a = [];
                res0a.evt = res0.evt;
                res0a.z = res0.z;
                res0a.fts = res0.fts;
                res0a.opts = res0.opts;
                resx{ii,kk} = res0a;
            end
        end
        %csvwrite(['./tmp/',mthdName,'_',xx.f0,'_vox.csv'],iouxxAqua);
        %csvwrite(['./tmp/',mthdName,'_',xx.f0,'_pix.csv'],iouxxAqua2D);
    end
    
    if xx.saveMe>0
        %iouVol = iouxxAqua; nStdVec = xx.nStdVec; f0 = xx.f0; %#ok<NASGU>
        %fOut = [xx.pOut,xx.f1,'_',mthdName,'_',xx.f0,'.mat'];
        %save(fOut,'resx','nStdVec','iouVol','f0','-v7.3');
    end
    
    rmpath(genpath(fp));
    
end


