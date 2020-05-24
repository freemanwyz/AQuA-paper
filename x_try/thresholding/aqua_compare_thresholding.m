%% We compare AQuA with global thresholding on ex vivo data
addpath(genpath('../AQuA-stable/'));

p0 = [getWorkPath(),'/dat/'];
f0 = 'FilteredNRMCCyto16m_slice2_Baseline3_L2 3-009cycle1channel1'; ps = 2;

opts = util.parseParam(ps,0,'parameters1.csv');
[datOrg,opts] = burst.prep1(p0,[f0,'.tif'],[],opts);  % read data
[H,W,T] = size(datOrg);


%% thresholding
datSmo = imgaussfilt(datOrg,0.5);
datVec = reshape(datSmo,[],T);
datVec1 = movmean(datVec,20,2);
[base1,ix] = min(datVec1,[],2);

% noise estimation
dF1 = datSmo - reshape(base1,H,W);
stdVec = zeros(size(datVec,1),1);
for ii=1:size(datVec,1)
    x0 = datVec(ii,:);
    t0 = max(ix(ii)-10,1);
    t1 = min(ix(ii)+10,T);
    stdVec(ii) = std(x0(t0:t1));
end
std1 = mean(stdVec);

% low threshold
dAct1 = dF1>3*std1;
dAct1 = bwareaopen(dAct1,16);
dL1 = bwlabeln(dAct1);
lst1 = label2idx(dL1);
% ovThrLow = regionMapWithData(lst1,datOrg,0.5); zzshow(ovThrLow);

% high threshold
dAct1a = dF1>10*std1;
dAct1a = bwareaopen(dAct1a,16);
dL1a = bwlabeln(dAct1a);
lst1a = label2idx(dL1a);
% ovThrHigh = regionMapWithData(lst1a,datOrg,0.5); zzshow(ovThrHigh);

% view in 3D, low
pixBigEvt = lst1{dL1(276,230,192)};
% ovBig = regionMapWithData({pixBigEvt},datOrg,0.5); zzshow(ovBig);

% view in 3D, high
dL1ax = zeros(size(datOrg));
for ii=1:numel(lst1a)
    dL1ax(lst1a{ii}) = ii;
end
idxInBig1a = unique(dL1ax(pixBigEvt));
idxInBig1a = idxInBig1a(idxInBig1a>0);
evtLst1ainBig = lst1a(idxInBig1a);
% ovThrHighInBig = regionMapWithData(evtLst1ainBig,datOrg,0.5); zzshow(ovThrHighInBig);


%% AQuA higher thr
p2 = [getWorkPath(),'/dat_detect/'];
tmp = load([p2,f0,'_aqua_lowthr.mat']);
evtLst2 = tmp.res.evt;
% ov2x = regionMapWithData(tmp.res.evt,datOrg,0.5); zzshow(ov2x);

% plot events
dL2 = zeros(size(datOrg));
for ii=1:numel(evtLst2)
    dL2(evtLst2{ii}) = ii;
end
idxInBig = unique(dL2(pixBigEvt));
idxInBig = idxInBig(idxInBig>0);
evtLst2inBig = evtLst2(idxInBig);

% ovAQuAInBig = regionMapWithData(evtLst2inBig,datOrg,0.5); zzshow(ovAQuAInBig);

% AQuA lower thr
% opts.thrARScl = 1.5;
% [dat,dF,arLst,lmLoc,opts,dL] = burst.actTop(datOrg,opts);
% [svLst,~,riseX] = burst.spTop(dat,dF,lmLoc,[],opts);
% [riseLst,datR,evtLst,seLst] = burst.evtTop(dat,dF,svLst,riseX,opts);
% 
% ov2a = regionMapWithData(arLst,datOrg,0.5); zzshow(ov2a);
% ov2a = regionMapWithData(svLst,datOrg,0.5); zzshow(ov2a);


%% draw figures
tVec = [80,120,160,200,240,280];

p1 = 'D:\OneDrive\projects\glia_kira\se_aqua\simDat\thresholding\';

% 3D
ovBig = regionMapWithData({pixBigEvt},datOrg*0,0.5);
writeTiffSeq_2d3d([p1,'_3DEvtLowThr.tif'],ovBig,8,1);

ovThrHighInBig = regionMapWithData(evtLst1ainBig,datOrg*0,0.5);
writeTiffSeq_2d3d([p1,'_3DEvtHighThr.tif'],ovThrHighInBig,8,1);

ovAQuAInBig = regionMapWithData(evtLst2inBig,datOrg*0,0.5);
writeTiffSeq_2d3d([p1,'_3DEvtAQuA.tif'],ovAQuAInBig,8,1);

% datOrg, delta F, low thr, high thr, AQuA
ovBig = regionMapWithData({pixBigEvt},datOrg,0.5);
ovThrHighInBig = regionMapWithData(evtLst1ainBig,datOrg,0.5);
ovAQuAInBig = regionMapWithData(evtLst2inBig,datOrg,0.5);
for ii=1:numel(tVec)
    fprintf('%d\n',ii)
    t0 = tVec(ii);
    writeTiffSeq([p1,'datOrg_',num2str(t0),'.tif'],datOrg(:,:,t0),8,1);
    
    x00 = uint8(dF1(:,:,t0)*255*2);
    RGB3 = ind2rgb(x00, jet(255));
    imwrite(RGB3,[p1,'dF_',num2str(t0),'.tif']);
    %writeTiffSeq([p1,'dF_',num2str(t0),'.tif'],dF1(:,:,t0)*20,8,1);
        
    imwrite(ovBig(:,:,:,t0),[p1,'thrLow_',num2str(t0),'.tif']);    
    imwrite(ovThrHighInBig(:,:,:,t0),[p1,'thrHigh_',num2str(t0),'.tif']);     
    imwrite(ovAQuAInBig(:,:,:,t0),[p1,'AQuA_',num2str(t0),'.tif']);
end



















