%% We compare AQuA with global thresholding on ex vivo data
addpath(genpath('../AQuA-stable/'));

p0 = [getWorkPath(),'/dat/'];
f0 = 'FilteredNRMCCyto16m_slice2_Baseline3_L2 3-009cycle1channel1'; ps = 2;

opts = util.parseParam(ps,0,'parameters1.csv');
[datOrg,opts] = burst.prep1(p0,[f0,'.tif'],[],opts);  % read data
[H,W,T] = size(datOrg);


%%
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
ovThrLow = regionMapWithData(lst1,datOrg,0.5); zzshow(ovThrLow);


%% AQuA
% p2 = [getWorkPath(),'/dat_detect/'];
% tmp = load([p2,f0,'_aqua.mat']);
% evtLst2 = tmp.res.evt;

opts.thrARScl = 1.5;
opts.spSz = 25;
% opts.thrSvSig = 2;
% opts.thrExtZ = 0.75;

[dat,dF,arLst,lmLoc,opts,dL] = burst.actTop(datOrg,opts);

[svLst,~,riseX] = burst.spTop(dat,dF,lmLoc,[],opts);
[riseLst,datR,evtLst,seLst] = burst.evtTop(dat,dF,svLst,riseX,opts);

ov2a = regionMapWithData(arLst,datOrg,0.5); zzshow(ov2a);
ov2b = regionMapWithData(svLst,datOrg,0.5); zzshow(ov2b);
ov2c = regionMapWithData(evtLst,datOrg,0.5); zzshow(ov2c);

res = [];
res.opts = opts;
res.evt = evtLst;
res.seLst = seLst;
res.svLst = svLst;
res.riseX = riseX;
res.lmLoc = lmLoc;
save('x.mat','res');



















