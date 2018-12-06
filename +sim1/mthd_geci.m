function mthd_geci(xxLst,thrSomaSz)
    
    xx = xxLst{1};
    nRep = numel(xxLst);
    
    %thrxx = 1e8;  % pixels count for large and small domains, 1000
    resx = cell(0,xx.nRep);
    iouxxGq = zeros(numel(xx.nStdVec),xx.nRep);
    iouxxGq2D = zeros(numel(xx.nStdVec),xx.nRep);
    kk=1; ii=1; %#ok<NASGU>
    
    for kk=1:nRep
        xx = xxLst{kk};
        xx.sz = size(xx.datSim);
        for ii=1:numel(xx.nStdVec)
            fprintf('GECI Std %d ==================\n',xx.nStdVec(ii));
            datSimNy = xx.datSim + xx.dAvg*xx.bgRt + randn(xx.sz)*xx.nStdVec(ii);
            
            % find best thresholds
            % must be calculated with fixed point, especially for 8 bits            
            dat8 = uint8(double(datSimNy)*255);
            
            % for domain and soma
            gtSpa = double(lst2map(xx.pixLst,size(xx.dAvg))>0);
            dt = uint8(max(dat8,[],3));
            hh = ones(3)/9;
            dt = uint8(imfilter(dt,hh));
            cxx = nan(256,1);
            for tt=0:255
                dt0 = double(bwareaopen(dt>tt,4));
                rho0 = corrcoef(gtSpa(:),dt0(:));
                cxx(tt+1) = rho0(1,2);
            end
            [~,idx00] = nanmax(cxx);
            thrInt = idx00-1;
            
            % for further segmentation of soma
            gt = lst2map(xx.evtLst,size(dat8));
            dtStd = zeros(size(dat8,1),size(dat8,2),size(dat8,3)/3);
            gtDs = dtStd;
            sigDs = dtStd;
            for tt=1:size(dtStd,3)
                t0 = (tt-1)*3+1;
                t1 = tt*3;
                dtStd(:,:,tt) = std(double(dat8(:,:,t0:t1)),0,3).*(gtSpa>0);
                gtDs(:,:,tt) = double(sum(gt(:,:,t0:t1),3)>0);
                sigDs(:,:,tt) = std(double(xx.datSim(:,:,t0:t1)),0,3);
            end
            sig00 = mean(sigDs(gtDs>0));  % values from signals
            
            if 0
                cxx = nan(256,1);
                l0 = numel(gtDs(:));
                l1 = round(l0/4);
                gtxx = gtDs(1:l1);
                dtxx = dtStd(1:l1);
                parfor tt=0:255
                    fprintf('%d\n',tt)
                    rho0 = corrcoef(gtxx,double(dtxx>tt));
                    cxx(tt+1) = rho0(1,2);
                end
                [~,idx00] = nanmax(cxx);
                thrSeg = idx00-1;
            end
            thrSeg = round(255*xx.nStdVec(ii));
            %thrSeg = round(255*min(xx.nStdVec(ii),sig00));

            % run GECI-quant
            res0 = geci_pipe(datSimNy,thrSomaSz,thrInt,thrSeg);
            
            zThrPk = min(xx.sigxU/xx.nStdVec(ii),10);
            [res0.evt,res0.z] = sim1.roi2evt(res0.dff,res0.roiLst,xx.HW,zThrPk,xx.zThrRt);
            res0.pixLst = vox2pix(res0.evt,xx.sz);
            [iouVoxD2G,iouPixD2G] = sim1.IoU(res0.evt,res0.pixLst,xx.evtLst,xx.pixLst,xx.sz);
            [iouVoxG2D,iouPixG2D] = sim1.IoU(xx.evtLst,xx.pixLst,res0.evt,res0.pixLst,xx.sz);
            iouxxGq(ii,kk) = (nanmean(iouVoxD2G)+nanmean(iouVoxG2D))/2;
            iouxxGq2D(ii,kk) = (nanmean(iouPixD2G)+nanmean(iouPixG2D))/2;
            
            res0a = [];
            res0a.evt = res0.evt;
            res0a.z = res0.z;          
            resx{ii,kk} = res0a;
            
            csvwrite(['./tmp/',xx.f1,'_','geci','_',xx.f0,'_vox.csv'],iouxxGq);
            %csvwrite(['./tmp/geci_',xx.f0,'_pix.csv'],iouxxGq2D);
            close all
        end
    end
    
    if xx.saveMe>0
        iouVol = {iouxxGq,iouxxGq2D}; nStdVec = xx.nStdVec; f0 = xx.f0;
        fOut = [xx.pOut,xx.f1,'_','geci','_',xx.f0,'.mat'];
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



