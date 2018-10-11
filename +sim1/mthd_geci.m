function mthd_geci(xx)
    
    xx.sz = size(xx.datSim);
    
    thrxx = 1000;  % pixels count for large and small domains
    resx = cell(0,xx.nRep);
    iouxxGq = zeros(numel(xx.nStdVec),xx.nRep);
    iouxxGq2D = zeros(numel(xx.nStdVec),xx.nRep);
    kk=1; ii=1; %#ok<NASGU>
    
    for kk=1:xx.nRep
        for ii=1:numel(xx.nStdVec)
            fprintf('GECI Std %d ==================\n',xx.nStdVec(ii));
            datSimNy = xx.datSim + xx.dAvg*xx.bgRt + randn(xx.sz)*xx.nStdVec(ii) + 0.2;
            res0 = geci_pipe(datSimNy,thrxx);  % run GECI-quant
            
            zThrPk = min(xx.sigxU/xx.nStdVec(ii),10);
            [res0.evt,res0.z] = sim1.roi2evt(res0.dff,res0.roiLst,xx.HW,zThrPk,xx.zThrRt);
            res0.pixLst = vox2pix(res0.evt,xx.sz);
            resx{ii,kk} = res0;
            [iouVoxD2G,iouPixD2G] = sim1.IoU(res0.evt,res0.pixLst,xx.evtLst,xx.pixLst,xx.sz);
            [iouVoxG2D,iouPixG2D] = sim1.IoU(xx.evtLst,xx.pixLst,res0.evt,res0.pixLst,xx.sz);
            iouxxGq(ii,kk) = (nanmean(iouVoxD2G)+nanmean(iouVoxG2D))/2;
            iouxxGq2D(ii,kk) = (nanmean(iouPixD2G)+nanmean(iouPixG2D))/2;
            csvwrite(['./tmp/geci_',xx.f0,'_vox.csv'],iouxxGq);
            csvwrite(['./tmp/geci_',xx.f0,'_pix.csv'],iouxxGq2D);
            close all
        end
    end
    
    if xx.saveMe>0
        iouVol = iouxxGq; nStdVec = xx.nStdVec; f0 = xx.f0; %#ok<NASGU>
        save([xx.pOut,'res_geci_',xx.f0,'_',xx.t0,'.mat'],'resx','nStdVec','f0','iouVol','-v7.3');
    end
    
end