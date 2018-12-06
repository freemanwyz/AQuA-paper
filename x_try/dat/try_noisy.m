%% setup
addpath(genpath('../../repo/aqua/'));
p0 = 'C:\Users\eric\OneDrive\projects\glia_kira\dbg\181113error\';
% f0 = '181107_s3_003_noError.tif';
f0 = '181107_s3_004_Error.tif';

opts = util.parseParam(1,0,'parameters1.csv');

[datOrg,opts] = burst.prep1(p0,f0,[],opts);  % read data

%%
% dat = imgaussfilt3(datOrg,[1,1,2]);
datM = medfilt3(datOrg,[5,5,5]);
dat1 = datM/max(datM(:))+randn(size(datM))*1e-2;

io.writeTiffSeq(f0,dat1,8);
