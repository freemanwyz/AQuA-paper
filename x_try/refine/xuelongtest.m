p0 = 'D:\OneDrive\projects\others\aqua_experiment\aqua_20181019_gitlab_bak_refine_region';
addpath(genpath(p0));

f0 = 'D:\OneDrive\projects\tmp\xuelong\Test_AQuA_with_curve_with_noise_10dB.tif';
dat = readTiffSeq(f0);
dat = double(dat)/255;

trg = 140:160;
hrg = 311:406;
wrg = 308:388;

dat0 = dat(hrg,wrg,trg);
zzshow(dat0)

[rMap0,zMap0] = stat.getCorrMapAvg8(dat0);

zzshow(rMap0)

vMap0 = ones(size(zMap0));
opts = util.parseParam(1,0);
osTb = opts.osTb;

[htMap00,~,zOutMap] = burst.htrg2(zMap0,[],[],osTb,1,2,4,4);

figure;imagesc(htMap00);


% dat = your_simulation_data;
% 
% trg = 140:160;
% hrg = 311:406;
% wrg = 308:388;
% 
% dat0 = dat(hrg,wrg,trg);
% zzshow(dat0)  % crop an event
% 
% [~,zMap0] = getCorrMapAvg8(dat0);  % z score map
% figure;imagesc(zMap0);colorbar
% 
% x = load(normTopMeanDist);  % look-up table
% [htMap00,~,zOutMap] = htrg2(zMap0,[],[],x.tbTopNorm,1,2,4,4);
% figure;imagesc(htMap00);









