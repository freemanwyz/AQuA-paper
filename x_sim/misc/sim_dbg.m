% run simulation
pIn = 'D:\OneDrive\projects\glia_kira\se_aqua\simDat\';
pOut = 'D:\OneDrive\projects\glia_kira\se_aqua\sim\';

f0 = 'ex-roi_area-avg-min-100_smo-st_201810091742';
% f0 = 'ex-roi_area-big-min-100_prop-min-500-gap-100_smo-st_201810091747';
% f0 = 'ex-evt_area-big-min-100_smo-st_201810091744';
% f0 = 'ex-evt_area-big-min-100_prop-min-500-gap-100_smo-st_201810091749';

% simulation setup
xx = sim1.prep_sim(pIn,pOut,f0);
xx = xx{1};


%%
addpath(genpath('../AQuA-stable/'));
f0a = [xx.f0,'_tune_gtwsmo'];
xVec = 1;
iouxxAqua = zeros(numel(xx.nStdVec),numel(xVec));
iouxxAqua2D = zeros(numel(xx.nStdVec),numel(xVec));
resx = cell(numel(xx.nStdVec),numel(xVec));
kk=1; ii=4; %#ok<NASGU>
for kk=1:numel(xVec)
    parfor ii=1:numel(xx.nStdVec)
        fprintf('Aqua Std %d ==================\n',xx.nStdVec(ii));
        %rng(88)
        datSimNy = xx.datSim + xx.dAvg*xx.bgRt + randn(xx.sz)*xx.nStdVec(ii)+0.2;
        
        opts = util.parseParam(3,0,'parameters1.csv');
        opts.regMaskGap = 0;
        opts.usePG = 0;
        opts.cRise = 1.5;  % 1.5
        opts.cDelay = 1.5;  % 1.5
        opts.cOver = 0;
        opts.minShow1 = 0.2;
        
        opts.smoXY = xx.smoVec(ii);  % default
        opts.minSize = 16;
        
        opts.thrARScl = 3;
        opts.thrTWScl = 4;  % !!
        opts.thrExtZ = 1.5;
        opts.zThr = 5;
        opts.gtwSmo = 2;
        opts.gtwGapSeedRatio = 16;
        res0 = aqua_top(datSimNy,opts);
        if ~isempty(res0)
            res0.pixLst = vox2pix(res0.evt,xx.sz);
            
            resx{ii,kk} = res0;
            %zzshow(regionMapWithData(xx.evtLst,zeros(size(xx.datSim))),'evt,gt')
            %zzshow(regionMapWithData(res0.evt,zeros(size(xx.datSim))),'evt,all')
            [iouVoxD2G,iouPixD2G] = sim1.IoU(res0.evt,res0.pixLst,xx.evtLst,xx.pixLst,xx.sz);
            [iouVoxG2D,iouPixG2D] = sim1.IoU(xx.evtLst,xx.pixLst,res0.evt,res0.pixLst,xx.sz);
            iouxxAqua(ii,kk) = (nanmean(iouVoxD2G)+nanmean(iouVoxG2D))/2;
            iouxxAqua2D(ii,kk) = (nanmean(iouPixD2G)+nanmean(iouPixG2D))/2;
            %csvwrite(['./tmp/aqua_',f0a,'_vox.csv'],iouxxAqua);
            %csvwrite(['./tmp/aqua_',f0a,'_pix.csv'],iouxxAqua2D);
        end        
    end
    csvwrite(['./tmp/aqua_',f0a,'_vox.csv'],iouxxAqua);
    csvwrite(['./tmp/aqua_',f0a,'_pix.csv'],iouxxAqua2D);
end


%% methods
xx.saveMe = 1;
xx.nRep = 3;
sim1.mthd_aqua(xx,0);  % stable version
sim1.mthd_aqua(xx,1);  % develop version
sim1.mthd_cascade(xx);
sim1.mthd_calman(xx);
sim1.mthd_suite2p(xx);
sim1.mthd_geci(xx);





