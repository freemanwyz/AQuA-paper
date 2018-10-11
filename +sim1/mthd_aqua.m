function mthd_aqua(xx,vSel)
    
    if ~exist('vSel','var')
        vSel = 0;
    end
    if vSel==0
        fp = '../../repo/aqua_20180705/';
        f0a = [xx.f0,'_stable'];
    else
        fp = '../../repo/aqua/';
        f0a = [xx.f0,'_dev'];
    end
    addpath(genpath(fp));

    resx = cell(0,xx.nRep);
    iouxxAqua = zeros(numel(xx.nStdVec),3);
    iouxxAqua2D = zeros(numel(xx.nStdVec),3);
    kk=1; ii=1; %#ok<NASGU>
    opts0 = util.parseParam(3,0,'parameters1.csv');
    for kk=1:xx.nRep
        parfor ii=1:numel(xx.nStdVec)
            fprintf('Aqua Std %d ==================\n',xx.nStdVec(ii));
            datSimNy = xx.datSim + xx.dAvg*xx.bgRt + randn(xx.sz)*xx.nStdVec(ii)+0.2;            
            
            opts = opts0;
            opts.regMaskGap = 0;
            opts.usePG = 0;
            opts.cRise = 1.5;  % 1.5
            opts.cDelay = 1.5;  % 1.5
            opts.cOver = 0;
            opts.minShow1 = 0.2;  % 0.2
            
            opts.smoXY = xx.smoVec(ii);
            %opts.smoXY = 0.1+max(xx.nStdVec(ii)-0.01,0)*5;  % default
            %opts.minSize = round(8+opts.smoXY*8);
            opts.minSize = 16;
            
            opts.thrARScl = 3;
            opts.thrTWScl = 4;  % !!
            opts.thrExtZ = 1.5;
            opts.zThr = 5;
            opts.gtwSmo = 2;
            opts.gtwGapSeedRatio = 16;
            res0 = aqua_top(datSimNy,opts);
            if isempty(res0)
                continue
            end
            res0.pixLst = vox2pix(res0.evt,xx.sz);
            
            resx{ii,kk} = res0; %#ok<PFOUS>
            %zzshow(regionMapWithData(xx.evtLst,zeros(size(xx.datSim))),'evt,gt')
            %zzshow(regionMapWithData(res0.evt,zeros(size(xx.datSim))),'evt,all')
            [iouVoxD2G,iouPixD2G] = sim1.IoU(res0.evt,res0.pixLst,xx.evtLst,xx.pixLst,xx.sz);
            [iouVoxG2D,iouPixG2D] = sim1.IoU(xx.evtLst,xx.pixLst,res0.evt,res0.pixLst,xx.sz);
            iouxxAqua(ii,kk) = (nanmean(iouVoxD2G)+nanmean(iouVoxG2D))/2;
            iouxxAqua2D(ii,kk) = (nanmean(iouPixD2G)+nanmean(iouPixG2D))/2;
        end
        csvwrite(['./tmp/aqua_',f0a,'_vox.csv'],iouxxAqua);
        csvwrite(['./tmp/aqua_',f0a,'_pix.csv'],iouxxAqua2D);
    end
    
    if xx.saveMe>0
        iouVol = iouxxAqua; nStdVec = xx.nStdVec; f0 = xx.f0; %#ok<NASGU>
        save([xx.pOut,'res_aqua_',f0a,'_',xx.t0,'.mat'],'resx','nStdVec','iouVol','f0','-v7.3');
    end
    
    rmpath(genpath(fp));
    
end


