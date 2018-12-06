% analyze the simulation results
sess0 = 'exvivo_stable-aqua-smooth-st-20181010';

% f0 = 'ex-roi_area-avg-min-100_smo-st_201810091742';
% f0 = 'ex-roi_area-big-min-100_prop-min-500-gap-100_smo-st_201810091747';
% f0 = 'ex-evt_area-big-min-100_smo-st_201810091744';
f0 = 'ex-evt_area-big-min-100_prop-min-500-gap-100_smo-st_201810091749';

pIn = 'D:\OneDrive\projects\glia_kira\se_aqua\simDat\';
pOutx = 'D:\OneDrive\projects\glia_kira\se_aqua\sim_old\';
tb = readtable('./+sim1/mthd_conf.csv','Delimiter',',');

% get files
pOut = [pOutx,filesep,sess0,filesep];
f00 = dir([pOut,'res_*']);
namex = {'aqua_stable','aqua_dev','geci','cascade','calman','suite2p'};
% namex = {'aqua_stable','geci','cascade','calman','suite2p'};
for ii=1:numel(f00)
    if isempty(strfind(f00(ii).name,f0))
        continue
    end
    for jj=1:numel(namex)
        if ~isempty(strfind(f00(ii).name,namex{jj}))
            tb.res{jj} = f00(ii).name;
        end
    end
end

% information of ground truth
xx = load([pIn,f0,'.mat']);
datSim = xx.datSim;
xx.datSim = cat(3,datSim,zeros(size(datSim,1),size(datSim,2),100,'uint16'));
gt = sim1.anaGt(xx);

% Intersection of union
iouVox = cell(0);
iouPix = cell(0);
for ii=1:size(tb,1)
    disp(tb.mthd{ii})
    rIn = load([pOut,tb.res{ii}]);
    r = rIn.resx;
    [iouVox{ii},iouPix{ii}] = sim1.anaIoU(r,gt);
end











