function mthd_cascade(xxLst)
    
    % tmp = load('./mthds/cascade/svmmodel_ex_vivo_sim.mat');
    % md = tmp.svmModelLst;
    
    xx = xxLst{1};
    
    addpath('../cascade/');
    nRep = numel(xxLst);
    
    p = [];
    p.foffset = 0; % how many initial frames to exclude in analysis
    p.norm_signal = 'std'; % ('std','bkg','sub') % different way to normalize intenisty
    p.spf = 1 ; % frame rate at acquisition
    
    % event detection
    p.min_peak_dist_ed = 3;  % 2
    p.min_peak_length = 2;  % 1
    p.hb=2*median(xx.evtRad); % 21. high bound size for in-x,y dim
    p.zlb=1; % low bound size for in-z(t) dim
    p.zhb=21; % 21. high bound size for in-z(t) dim
    
    % background trending correction
    p.int_correct= 0; % if 1, correct bkg, if 0, no correction.
    
    % processing    
    resx = cell(0,xx.nRep);
    iouxxCas = zeros(numel(xx.nStdVec),xx.nRep);
    iouxxCas2D = zeros(numel(xx.nStdVec),xx.nRep);
    kk=1; ii=1; %#ok<NASGU>
    
    for kk=1:nRep
        xx = xxLst{kk};
        xx.HW = size(xx.dAvg,1)*size(xx.dAvg,2);
        for ii=1:numel(xx.nStdVec)
            fprintf('Cascade std %d ==================\n',xx.nStdVec(ii));
            datSimNy = xx.datSim*2 + xx.dAvg*xx.bgRt + randn(xx.sz)*xx.nStdVec(ii) + 0.2;
            
            zThrPk = min(xx.sigxU/xx.nStdVec(ii),10);  % !! 10
            p.lb=xx.nStdVec(ii)*3; % low bound size for in-x,y dim
            %p.peak_int_ed = 10;
            p.min_int_ed = min(2,zThrPk*0.5);
            p.peak_int_ed = zThrPk; % minimum peak intesnity value for being considered as signal
            %p.min_int_ed = zThrPk*0.2; % minimum intenisty value for start-end of a event
            
            res0 = Cal_anl_main2sa_forreview_x(datSimNy,p);
            
            % clean res0 according to ground truth
            % avoid SVM training
            idxSel = false(numel(res0.evt),1);
            for jj=1:numel(idxSel)
                vox0 = res0.evt{jj};
                if sum(xx.datSim(vox0)>0)>0
                    idxSel(jj) = true;
                end
            end            
            res0.evt = res0.evt(idxSel);
            res0.z = res0.z(idxSel);            
            
            % peak detector from Cascade
            res0.pixLst = vox2pix(res0.evt,xx.sz);
            [iouVoxD2G,iouPixD2G] = sim1.IoU(res0.evt,res0.pixLst,xx.evtLst,xx.pixLst,xx.sz);
            [iouVoxG2D,iouPixG2D] = sim1.IoU(xx.evtLst,xx.pixLst,res0.evt,res0.pixLst,xx.sz);
            iouxxCas(ii,kk) = (nanmean(iouVoxD2G)+nanmean(iouVoxG2D))/2;
            iouxxCas2D(ii,kk) = (nanmean(iouPixD2G)+nanmean(iouPixG2D))/2;
            
            res0a = [];
            res0a.evt = res0.evt;
            res0a.z = res0.z;    
            resx{ii,kk} = res0a;
            
            csvwrite(['./tmp/',xx.f1,'_','cascade','_',xx.f0,'_vox.csv'],iouxxCas);
            close all
            
            %     % classfication with SVM
            %     for jj=2:4
            %         md0 = md{ii,jj-1};
            %         lb0 = md0.predict(res0.testdata);
            %         fprintf('%d\n',sum(lb0));
            %         res0a = res0;
            %         res0a.svm1_pk_class = lb0;
            %         resx{ii,jj} = res0a;
            %     end
            
            %im0r = regionMapWithData(res0.roi,xx.dAvg*0);
            %fim0 = ['./tmp/',xx.f1,'_','cascade','_',xx.f0,'-',num2str(ii),'.tif'];
            %imwrite(im0r,fim0)
            
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
                fim0 = ['./tmp/',xx.f1,'_','cascade','_',xx.f0,'-',num2str(ii),'.mat'];
                roi0 = res0.roi;
                save(fim0,'m0','m0x','roi0');
            end
        end
    end
    
    if xx.saveMe>0
        iouVol = {iouxxCas,iouxxCas2D}; nStdVec = xx.nStdVec; f0 = xx.f0;
        fOut = [xx.pOut,xx.f1,'_','cascade','_',xx.f0,'.mat'];
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


