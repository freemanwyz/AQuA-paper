function mthd_suite2p(xx)
    
    xx.sz = size(xx.datSim);
    xx.HW = xx.sz(1)*xx.sz(2);
    
    % file is put to RootStorage/xx/xx/file_name.tif
    % folderPrj = tempdir;
    db.diameter = mean(xx.evtRad);
    db.ShowCellMap  = 0;
    resx = cell(0,xx.nRep);
    iouxxS2p = zeros(numel(xx.nStdVec),xx.nRep);
    iouxxS2p2D = zeros(numel(xx.nStdVec),xx.nRep);
    kk=1; ii=1; %#ok<NASGU>
    
    for kk=1:xx.nRep
        for ii=1:numel(xx.nStdVec)
            fprintf('Suite2P Std %d ==================\n',xx.nStdVec(ii));
            datSimNy = xx.datSim + xx.dAvg*xx.bgRt + randn(xx.sz)*xx.nStdVec(ii) + 0.2;
            res0 = suite2p_wyz(datSimNy,db);
            zThrPk = min(xx.sigxU/xx.nStdVec(ii),10);
            [res0.evt,res0.z] = sim1.roi2evt(res0.dff,res0.roiLst,xx.HW,zThrPk,xx.zThrRt);
            
            res0.pixLst = vox2pix(res0.evt,xx.sz);
            resx{ii,kk} = res0;
            [iouVoxD2G,iouPixD2G] = sim1.IoU(res0.evt,res0.pixLst,xx.evtLst,xx.pixLst,xx.sz);
            [iouVoxG2D,iouPixG2D] = sim1.IoU(xx.evtLst,xx.pixLst,res0.evt,res0.pixLst,xx.sz);
            iouxxS2p(ii,kk) = (nanmean(iouVoxD2G)+nanmean(iouVoxG2D))/2;
            iouxxS2p2D(ii,kk) = (nanmean(iouPixD2G)+nanmean(iouPixG2D))/2;
            csvwrite(['./tmp/suite2p_',xx.f0,'_vox.csv'],iouxxS2p);
            csvwrite(['./tmp/suite2p_',xx.f0,'_pix.csv'],iouxxS2p2D);
            close all
        end
    end
    
    if xx.saveMe>0
        iouVol = iouxxS2p; nStdVec = xx.nStdVec; f0 = xx.f0; %#ok<NASGU>
        save([xx.pOut,'res_suite2p_',xx.f0,'_',xx.t0,'.mat'],'resx','nStdVec','iouVol','f0','-v7.3');
    end
    
end

