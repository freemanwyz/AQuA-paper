function mthd_calman(xxLst)
    
    dlSave = './mthds/calman/';  % save CNN model
    fCalmAn = '../../repo/CalmAn/';
    addpath(fCalmAn)
    addpath(genpath([fCalmAn,'utilities']));
    addpath(genpath([fCalmAn,'deconvolution']));
    
    showMe = 0;
    xx = xxLst{1};
    nRep = numel(xxLst);
    
    fr = 1;
    tSub = 1;
    [options,K,patches,tau,pAr] = setExVivo(xx.sz,fr,tSub);
    resx = cell(0,xx.nRep);
    
    iouxxCal = zeros(numel(xx.nStdVec),numel(xx.nRep));
    iouxxCal2D = zeros(numel(xx.nStdVec),numel(xx.nRep));
    kk = 1; ii = 7; %#ok<NASGU>
    
    stdVec = xx.nStdVec;
    %stdVec = max(stdVec,0.06);  % !! oversegment with low noise

    for kk=1:nRep
        xx = xxLst{kk};
        for ii=1:numel(xx.nStdVec)
            fprintf('Calman Std %d ==================\n',stdVec(ii));
            datSimNy0 = xx.datSim + xx.dAvg*xx.bgRt + randn(xx.sz)*stdVec(ii)+0.2;
            %datSimNy = xx.datSim + xx.dAvg*xx.bgRt + randn(xx.sz)*xx.nStdVec(ii)+0.2;
            %res0 = calman_top(datSimNy,tSub);
            res0 = calman_top(datSimNy0,tSub,options,K,patches,tau,pAr,dlSave,showMe);
            
            zThrPk = min(xx.sigxU/stdVec(ii),10);
            [res0.evt,res0.z] = sim1.roi2evt(res0.dff,res0.roiLst,xx.HW,zThrPk,xx.zThrRt);            
            res0.pixLst = vox2pix(res0.evt,xx.sz);
            %zzshow(regionMapWithData(xx.evtLst,zeros(size(xx.datSim))),'evt,gt')
            %zzshow(regionMapWithData(res0.evt,zeros(size(xx.datSim))),'evt,all')
            [iouVoxD2G,iouPixD2G] = sim1.IoU(res0.evt,res0.pixLst,xx.evtLst,xx.pixLst,xx.sz);
            [iouVoxG2D,iouPixG2D] = sim1.IoU(xx.evtLst,xx.pixLst,res0.evt,res0.pixLst,xx.sz);
            iouxxCal(ii,kk) = (nanmean(iouVoxD2G)+nanmean(iouVoxG2D))/2;
            iouxxCal2D(ii,kk) = (nanmean(iouPixD2G)+nanmean(iouPixG2D))/2;
            
            if 0  % check ROI overlap
                r0 = res0.roiLst;
                m0 = zeros(size(xx.dAvg));
                for ee=1:numel(r0)
                    m0(r0{ee}) = m0(r0{ee})+1;
                end
                figure;imagesc(m0);colorbar
                zzshow(regionMapWithData(r0,m0*0))
            end
            
            res0a = [];
            res0a.evt = res0.evt;
            res0a.z = res0.z;          
            resx{ii,kk} = res0a;
            
            csvwrite(['./tmp/',xx.f1,'_','calman','_',xx.f0,'_vox.csv'],iouxxCal);
            %csvwrite(['./tmp/calman_',xx.f0,'_pix.csv'],iouxxCal2D);
            close all
            
            %im0 = regionMapWithData(res0.roiLst,xx.dAvg*0);
            %fim0 = ['./tmp/',xx.f1,'_','caiman','_',xx.f0,'-',num2str(ii),'.tif'];
            %imwrite(im0,fim0)
            
            if 1
                r0 = res0.pixLst;
                r0x = res0.evt;
                m0 = zeros(size(xx.dAvg));
                m0x = zeros(size(xx.dAvg));
                for ee=1:numel(r0)
                    m0(r0{ee}) = m0(r0{ee})+1;
                    vox0 = r0x{ee};
                    [ih0,iw0,~] = ind2sub(xx.sz,vox0);
                    ihw0 = unique(sub2ind(size(xx.dAvg),ih0,iw0));
                    m0x(ihw0) = m0x(ihw0)+1;
                end
                fim0 = ['./tmp/',xx.f1,'_','caiman','_',xx.f0,'-',num2str(ii),'.mat'];
                roi0 = res0.roiLst;
                save(fim0,'m0','m0x','roi0');
            end
        end
    end
    
    if xx.saveMe>0
        iouVol = {iouxxCal,iouxxCal2D}; nStdVec = xx.nStdVec; f0 = xx.f0; %#ok<NASGU>
        fOut = [xx.pOut,xx.f1,'_','calman','_',xx.f0,'.mat'];
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


