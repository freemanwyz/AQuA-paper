% Now you should have 3 files related to the powerpoint. 
% One is the tiff (video), the other two are .mat files where one contains 
% the parameters I used and the other a variable called evts_silvia where
% I saves the 3D location of event 1 and event 2 (as they appear in the ppt)

% p_top = 'D:\OneDrive\projects\glia_kira\tmp\181109_detectionExamples\';
p_top = 'C:\Users\eric\OneDrive\projects\glia_kira\tmp\181109_detectionExamples\';
f_dat = '181113_s1_001_bl.tif';
f_res = '181113_s1_001_bl_evts_silvia';


%%
% 167, 177, 185, a small event on top right

tmp = load([p_top,f_res]);
evt0 = tmp.evts_silvia;

datx = readTiffSeq([p_top,f_dat]);
datx = double(datx)/max(datx(:));
[H,W,T] = size(datx);
datVec = reshape(datx,[],T);

% datMed = datx;
% for ii=1:T
%     datMed(:,:,ii) = medfilt2(datx(:,:,ii));
% end

for ii=1:numel(evt0)
    vox0 = evt0{ii};
    [ih0,iw0,~] = ind2sub(size(datx),vox0);
    pix0 = sub2ind([H,W],ih0,iw0);
    m0 = mean(datVec(pix0,:),1);
    figure;plot(m0)
    
    pixMap = zeros(H,W);
    pixMap(pix0) = 1;
    zzshow(pixMap);
end

%% ROI
xMap0 = stat.getCorrMapAvg8(datx);
xMap0a = bwareaopen(xMap0>0.15,8);
ccx = bwconncomp(xMap0a);
cx = zeros(ccx.NumObjects,T);
for ii=1:ccx.NumObjects
    pix0 = ccx.PixelIdxList{ii};
    cx(ii,:) = mean(datVec(pix0,:),1);
end
figure;plot(cx')


%%
% filter out noisy events by duration after detection (6 frames?)

addpath(genpath('../repo/AQuA/'));
preset = 9;
opts = util.parseParam(preset,0,'parameters1.csv');

% opts.regMaskGap = 0;
[datOrg,opts] = burst.prep1(p_top,f_dat,[],opts);  % read data

% opts.smoXY = 1;
% opts.minSize = 4;
% opts.thrARScl = 1;
[dat,dF,arLst,lmLoc,opts,dL] = burst.actTop(datOrg,opts);  % foreground and seed detection

% opts.thrExtZ = 1;
% opts.thrTWScl = 0.5;
% opts.thrSvSig = 1;
[svLst,~,riseX] = burst.spTop(dat,dF,lmLoc,[],opts);  % super voxel detection

opts.useLongerDuration = 0;
opts.gapExt = 50;
opts.minShow1 = 0.2;
[riseLst,datR,evtLst,seLst] = burst.evtTop(dat,dF,svLst,riseX,opts);  % events
[ftsLst,dffMat] = fea.getFeatureQuick(datOrg,evtLst,opts);

%%

% zzshow(regionMapWithData(arLst,datOrg,0.5))
% zzshow(regionMapWithData(svLst,datOrg*0.5))
% zzshow(regionMapWithData(evtLst,datOrg*0.5))
% zzshow(regionMapWithData(num2cell(lmLoc),datOrg,0.5))






