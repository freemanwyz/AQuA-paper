%% robust active region detection

addpath(genpath('../AQuA/'))

% pIn = 'D:\OneDrive\projects\glia_kira\se_aqua\simDat\';
% f0 = 'roi_dbg_tmpsmo_freqlow_201809281638';
pIn = 'D:\OneDrive\projects\glia_kira\se_aqua\dat\';
f0 = '2826451(4)_1_2_4x_reg_200um_dualwv-001_nr';

opts = util.parseParam(3,0,'parameters1.csv');

if 1
    datIn = io.readTiffSeq([pIn,f0,'.tif']);
    datIn = datIn/max(datIn(:));
    opts.htrgSolver = 2;
end

if 0
    xx = load([pIn,f0,'.mat']);
    datSim = xx.datSim;
    sz = size(datSim);
    d = mod(sz(3),10);
    datSim = cat(3,datSim,zeros(sz(1),sz(2),60-d,'uint16'));
    sz(3) = size(datSim,3);
    datSim = double(datSim)/65535;
    sigx = double(mean(datSim(datSim>0)));
    snrx = 0;
    nStdVec = sigx./(10.^(snrx/20));
    datIn = datSim+randn(sz)*nStdVec+0.2;
    
    opts.regMaskGap = 0;
    opts.usePG = 0;
    opts.smoXY = 1;
    opts.smoZ = 1;
    opts.htrgSolver = 2;
end

% parameters
opts.minSize = 4;
opts.thrARScl = 2;
[datOrg,opts] = burst.prep1a(datIn,opts);


%% active region
% noise for raw data
xx = (datOrg(:,:,2:end)-datOrg(:,:,1:end-1)).^2;
stdMapRaw = sqrt(median(xx,3)/0.9133);
stdMapGauRaw = double(imgaussfilt(stdMapRaw));
stdEstRaw = double(nanmedian(stdMapGauRaw(:)));

% smooth the data
dat = datOrg;
for tt=1:size(dat,3)
    dat(:,:,tt) = imgaussfilt(dat(:,:,tt),opts.smoXY);
end

if opts.smoZ>0
    dat = reshape(dat,[],opts.sz(3));
    gk = fspecial('gaussian',[1,11],opts.smoXY);
    dat1 = zeros(size(dat));
    parfor ii=1:size(dat,1)
        x = dat(ii,:);
        x = [ones(1,5)*x(1),x,ones(1,5)*x(end)];
        x1 = conv(x,gk);
        dat1(ii,:) = x1(11:end-10);
    end
    dat1 = reshape(dat1,opts.sz);
    dat = dat1;
end

% noise for smoothed data
xx = (dat(:,:,5:end)-dat(:,:,1:end-4)).^2;
stdMap = sqrt(median(xx,3)/0.9133);
stdMapGau = double(imgaussfilt(stdMap));
stdEst = double(nanmedian(stdMapGau(:)));

% delta F
dF = getDfAda(dat,opts.cut,opts.movAvgWin,stdEst);

% active regions
dAct = false(size(dF));
for tt=1:opts.sz(3)
    tmp = dF(:,:,tt);
    tmp = bwareaopen(tmp>opts.thrARScl*stdEst,opts.minSize,4);     
    dAct(:,:,tt) = tmp;
end
% arLst = bwconncomp(dActVox);
% arLst = arLst.PixelIdxList;

dFRaw = getDfAda(datOrg,opts.cut,opts.movAvgWin,stdEstRaw);

%% test each region
dActF = false(opts.sz);
dActS = zeros(opts.sz);

cc = bwconncomp(dAct);
for ii=1:cc.NumObjects
    idx = cc.PixelIdxList{ii};
    x0 = dFRaw(idx);
    s = mean(x0(:))/(stdEstRaw/sqrt(numel(x0)));
    if s>10
        dActF(idx) = true;
    end
    dActS(idx) = s;
end

cc = bwconncomp(dActF);
[evts,zs] = burst.refineEvts(dFRaw,cc.PixelIdxList,opts,stdEstRaw);

idxSel = ~cellfun(@isempty,evts);
evts = evts(idxSel);
zs = zs(idxSel);
dActF1 = lst2map(evts,opts.sz);
zzshow(regionMapWithData(dActF1));

dActS1 = zeros(size(dActS));
for ii=1:numel(evts)
    dActS1(evts{ii}) = zs(ii);
end


























