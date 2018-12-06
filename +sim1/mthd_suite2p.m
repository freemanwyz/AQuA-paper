function mthd_suite2p(xxLst)
    
    xx = xxLst{1};
    nRep = numel(xxLst);
    
    % file is put to RootStorage/xx/xx/file_name.tif
    % folderPrj = tempdir;
    %db.diameter = min(quantile(xx.evtRad,0.25),50);
    db.diameter = min(nanmedian(xx.evtRad),50);
    %db.diameter = nanmax(xx.evtRad);
    db.fig = 0;
    resx = cell(0,xx.nRep);
    iouxxS2p = zeros(numel(xx.nStdVec),xx.nRep);
    iouxxS2p2D = zeros(numel(xx.nStdVec),xx.nRep);
    kk=1; ii=1; %#ok<NASGU>
    
    for kk=1:nRep
        xx = xxLst{kk};
        xx.sz = size(xx.datSim);
        xx.HW = xx.sz(1)*xx.sz(2);
        for ii=1:numel(xx.nStdVec)
            fprintf('Suite2P Std %d ==================\n',xx.nStdVec(ii));
            datSimNy = xx.datSim + xx.dAvg*xx.bgRt + randn(xx.sz)*xx.nStdVec(ii) + 0.2;
            res0 = suite2p_wyz(datSimNy,db);
            zThrPk = min(xx.sigxU/xx.nStdVec(ii),10);
            [res0.evt,res0.z] = sim1.roi2evt(res0.dff,res0.roiLst,xx.HW,zThrPk,xx.zThrRt);
            
            res0.pixLst = vox2pix(res0.evt,xx.sz);
            [iouVoxD2G,iouPixD2G] = sim1.IoU(res0.evt,res0.pixLst,xx.evtLst,xx.pixLst,xx.sz);
            [iouVoxG2D,iouPixG2D] = sim1.IoU(xx.evtLst,xx.pixLst,res0.evt,res0.pixLst,xx.sz);
            iouxxS2p(ii,kk) = (nanmean(iouVoxD2G)+nanmean(iouVoxG2D))/2;
            iouxxS2p2D(ii,kk) = (nanmean(iouPixD2G)+nanmean(iouPixG2D))/2;
            
            res0a = [];
            res0a.evt = res0.evt;
            res0a.z = res0.z;       
            resx{ii,kk} = res0a;
            
            csvwrite(['./tmp/',xx.f1,'_','suite2p','_',xx.f0,'_vox.csv'],iouxxS2p);
            %csvwrite(['./tmp/suite2p_',xx.f0,'_pix.csv'],iouxxS2p2D);
            close all
        end
    end
    
    if xx.saveMe>0
        iouVol = {iouxxS2p,iouxxS2p2D}; nStdVec = xx.nStdVec; f0 = xx.f0;
        fOut = [xx.pOut,xx.f1,'_','suite2p','_',xx.f0,'.mat'];
        if exist(fOut,'file')
            tmp = load(fOut);
            iouVol{1} = [iouVol{1},tmp.iouVol{1}];
            iouVol{2} = [iouVol{2},tmp.iouVol{2}];
        end
        save(fOut,'nStdVec','iouVol','f0','-v7.3');
        if xx.saveMe>1
           save(fOut,'resx','nStdVec','iouVol','f0','-v7.3');
        end
    end
    
end

