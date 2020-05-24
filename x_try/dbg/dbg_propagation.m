%% too short or too long
% f0 = 'D:\OneDrive\projects\glia_kira\dbg\propagation_aqua_longupdn.mat';
% f0 = 'D:\OneDrive\projects\glia_kira\dbg\propagation_aqua_dly0.mat';
f0 = 'D:\OneDrive\projects\glia_kira\dbg\propagation_aqua_dly10.mat';
load(f0)

fp = '../AQuA-stable/';
addpath(genpath(fp));

%%
yy = xxLst{1};

% inject local maximum
if 0
    xGrid = zeros(size(yy.dAvg));
    xGridBg = xGrid==0;
    xGrid(1:2:end,1:2:end) = 1;
    xGrid = xGrid.*(yy.datSim>0);
    cc = bwconncomp(xGrid);
    xGrid1 = zeros(size(yy.datSim));
    for ii=1:cc.NumObjects
        cc0 = cc.PixelIdxList{ii};
        xGrid1(cc0(round(numel(cc0)/2))) = 1;
    end
    datSim = yy.datSim+xGrid1*0.4;
else
    datSim = yy.datSim;
end

datSimNy = datSim + yy.dAvg*yy.bgRt + randn(yy.sz)*0.0493 + 0.2;

global evtGt evtLst datSim0
evtGt = lst2map(yy.evtLst,size(datSimNy));
evtLst = yy.evtLst;
datSim0 = datSimNy;

opts1 = opts;
opts1.smoXY = 0.6;
% opts1.smoXY = 0.1;
opts1.cDelay = 3;
opts1.spSz = 1;  % 16,25
% opts1.reSampleCurve = 1;
opts1.gtwSmo = 0.5;
% opts1.maxStp = 21;  % 21 if upsample curves
opts1.gtwGapSeedMin = 2;
opts1.gtwGapSeedRatio = 1000;

res0 = aqua_top(datSimNy,opts1);

res0.pixLst = vox2pix(res0.evt,yy.sz);
[iouVoxD2G,iouPixD2G] = sim1.IoU(res0.evt,res0.pixLst,yy.evtLst,yy.pixLst,yy.sz);
[iouVoxG2D,iouPixG2D] = sim1.IoU(yy.evtLst,yy.pixLst,res0.evt,res0.pixLst,yy.sz);
iouVox00 = (nanmean(iouVoxD2G)+nanmean(iouVoxG2D))/2;
iouPix00 = (nanmean(iouPixD2G)+nanmean(iouPixG2D))/2;

%%
evtMapDt = lst2map(res0.evt,size(datSimNy));
evtMapGt = lst2map(yy.evtLst,size(datSimNy));
sum(evtMapDt(:)>0)
sum(evtMapGt(:)>0)

pixMapDt = sum(evtMapDt,3)>0;
pixMapGt = sum(evtMapGt,3)>0;
sum(pixMapDt(:))
sum(pixMapGt(:))

%%
xfn = evtMapDt==0 & evtMapGt>0;
xfp = evtMapDt>0 & evtMapGt==0;
[H,W,T] = size(yy.datSim);
xOut = zeros(H,W,3,T);
xOut(:,:,1,:) = yy.datSim+xfn;
xOut(:,:,2,:) = yy.datSim;
xOut(:,:,3,:) = yy.datSim+xfp;
zzshow(xOut)

%% dtw
r00 = ref(1:50:end,:); r00 = r00./max(r00,[],2);
t00 = tst(1:50:end,:); t00 = t00./max(t00,[],2);
c00 = cx(1:50:end,:); c00 = c00./max(c00,[],2);
figure;plot(r00');title('ref');ylim([0,1]);xlim([1,30])
figure;plot(t00');title('test');ylim([0,1]);xlim([1,30])
figure;plot(c00');title('ref-warp');ylim([0,1]);xlim([1,30])

%%
close all
idx00 = randi(size(ref,1));
r00 = ref(idx00,:); r00 = r00./max(r00,[],2);
t00 = tst(idx00,:); t00 = t00./max(t00,[],2);
c00 = cx(idx00,:); c00 = c00./max(c00,[],2);
figure;plot(r00');title('ref');hold on
plot(t00');title('test');hold on
plot(c00');title('ref-warp');ylim([0,1]);xlim([1,30])

figure;dtw(r00,t00);
% [~,ixRef,iyTst] = dtw(vecRef,vecTst);
% figure;plot(ixRef,iyTst)


%% propagation check
ixVec = [9,52];

for ix=ixVec
    evt00 = res.fts.loc.x3D{ix};
    tmp = zeros(res.opts.sz,'uint8');
    tmp(evt00) = 1;
    [~,~,it00] = ind2sub(res.opts.sz,evt00);
    t0 = min(it00);
    t1 = max(it00);
    
    fprintf('%d\n',t0);
    
    r00 = tmp(:,:,t0:t1).*res.datRAll(:,:,t0:t1);
    
    zzshow(r00)
end

xx = res.fts.propagation.areaFrame{33};

%%
nEvt = size(dffMatE,1);
figure;
for ii=1:nEvt
    x = dffMatE(ii,:,1);
    y = dffMatE(ii,:,2);
    plot(x(:));hold on;plot(y(:));hold off
    keyboard
end