%% setup
addpath(genpath('../AQuA/'));

preset = 2;
p0 = 'D:\OneDrive\projects\glia_kira\raw\TTXDataSetRegistered_32Bit\';
f0 = 'FilteredNRMCCyto16m_slice2_Baseline3_L2 3-009cycle1channel1.tif';
% f0 = 'FilteredNRMCCyto16m_slice3_Baseline3_L2 3-015cycle1channel1.tif';

opts = util.parseParam(preset,0,'parameters1.csv');

[datOrg,opts] = burst.prep1(p0,f0,[],opts);  % read data

%% detection
[dat,dF,arLst,lmLoc,opts,dL] = burst.actTop(datOrg,opts);  % foreground and seed detection
[svLst,~,riseX] = burst.spTop(dat,dF,lmLoc,[],opts);  % super voxel detection

%% super events as basic unit for simulation
lblMapS = zeros(size(dat),'uint32');
for nn=1:numel(svLst)
    lblMapS(svLst{nn}) = nn;
end
riseMap = zeros(size(dat),'uint16');
riseX0 = nanmedian(riseX,2);
for nn=1:numel(svLst)
    t00 = riseX0(nn);
    if ~isnan(t00)
        riseMap(svLst{nn}) = t00;
    end
end

% super voxels to super events
stp11 = max(round(opts.maxStp/2),2);
if opts.superEventdensityFirst==1
    [neibLst,exldLst] = burst.svNeib(lblMapS,riseMap,stp11,opts.cOver);
    seMap = burst.sv2se(lblMapS,neibLst,exldLst);
else
    xx = double(riseMap); xx(xx==0) = nan;
    seMap = burst.sp2evtStp1(lblMapS,xx,0,stp11,0.2,dat);
end

seLst = label2idx(seMap);

res = [];
res.opts = opts;
res.seLst = seLst;

%%
outFd = 'D:\OneDrive\projects\glia_kira\results\sim_se_ex\';
outFn = [outFd,opts.fileName,'.mat'];
save(outFn,'res');

% ov1 = plt.regionMapWithData(arLst,datOrg,0.5); zzshow(ov1);
% ov1 = plt.regionMapWithData(svLst,datOrg,0.5); zzshow(ov1);
% ov1 = plt.regionMapWithData(seLst,datOrg,0.5); zzshow(ov1);






