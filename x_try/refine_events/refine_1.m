%% Low cost HTRG as refinement for regions
tmp = load('normTopMeanDist'); osTb = tmp.tbTopNorm;

p0 = 'D:\OneDrive\projects\glia_kira\se_aqua\dat\invivo_1x_reg_200\';
f0 = '2826451(4)_1_2_4x_reg_200um_dualwv-001_nr'; preset = 0;

opts = util.parseParam(preset,[],'parameters1.csv');
opts.osTb = osTb;

[datOrg,opts] = burst.prep1(p0,[f0,'.tif'],[],opts);  % read data
[dat,dF,arLst,lmLoc,opts,dL] = burst.actTop(datOrg,opts);


%% try
% regions
regLst = cell(numel(arLst),1);
for ii=1:numel(arLst)
    vox0 = arLst{ii};
    [ih,iw,~] = ind2sub(size(dat),vox0);
    ihw = sub2ind([size(dat,1),size(dat,2)],ih,iw);
    regLst{ii} = unique(ihw);
end
regLen = cellfun(@numel,regLst);

% all events
[evts,tVec] = refineEvts(dat,arLst,3,osTb);
zzshow(regionMapWithData(evts,zeros(size(dat))))

figure;scatter(regLen,tVec)
set(gca,'xscale','log','yscale','log','FontSize',15);
xlabel('Size'); ylabel('Seconds');

% one event
evtMap = lst2map(arLst,size(dat));
datMA = movmean(datOrg,30,3);
datMin = min(datMA,[],3);
dFOrg = dat - datMin;

nn = 51;
vox0 = arLst{nn};
[~,~,it0] = ind2sub(size(dat),vox0);
d0 = dFOrg(:,:,min(it0)-10:max(it0)+10);
e0 = evtMap(:,:,min(it0)-10:max(it0)+10);

[vox1,htMap0,fiu0] = refineRegion(d0,e0,nn,sqrt(opts.varEst),3,osTb,1);


%% synthetic data
tmp = load('normTopMeanDist'); osTb = tmp.tbTopNorm;
tmp = load('D:\OneDrive\projects\glia_kira\dbg\refine_low_noise_nospasmo.mat');
dat = tmp.datSimNy;
xx = tmp.xx;
res = tmp.res0;
evtLst = res.evt;
res0.evt = refineEvts(dat,evtLst,3,osTb);









