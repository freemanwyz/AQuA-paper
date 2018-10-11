p0 = 'D:\OneDrive\projects\glia_kira\se_aqua\dat\';
f0 = '2826451(4)_1_2_4x_reg_200um_dualwv-001_nr'; preset = 1;
% f0 = 'FilteredNRMCCyto16m_slice3_Baseline3_L2 3-015cycle1channel1'; preset = 3;

opts = util.parseParam(preset,[],'parameters1.csv');
opts.thrARScl = 2;
opts.cRise = 1;
opts.cDelay = 1;

[datOrg,opts] = burst.prep1(p0,[f0,'.tif'],[],opts);

[dat,dF,arLst,lmLoc,opts,~] = burst.actTop(datOrg,opts);
% zzshow(regionMapWithData(arLst,dat*0));

[svLst,~,riseX] = burst.spTop(dat,dF,lmLoc,[],opts);
% zzshow(regionMapWithData(svLst,dat*0));

[riseLst,datR,evtLst,seLst] = burst.evtTop(datOrg,[],svLst,riseX,opts);
% zzshow(regionMapWithData(evtLst,dat*0));

[ftsLst,dffMat,dMat] = fea.getFeaturesTop(datOrg,evtLst,opts);

res = [];
res.opts = opts;
res.se = seLst;
res.evt = evtLst;
res.fts = ftsLst;
res.dffMat = dffMat;
res.dMat = dMat;

% ------> start here after loading res
% load('D:\OneDrive\projects\glia_kira\dbg\2826451(4)_1_2_4x_reg_200um_dualwv-001_nr_burst_test');
% [datOrg,~] = burst.prep1(res.opts.filePath,[res.opts.fileName,'.tif'],[],res.opts);
sz = res.opts.sz;
zSel = res.fts.curve.dffMaxZ>10;
evt = res.evt(zSel);
sz2D = cellfun(@numel,res.fts.loc.x2D(zSel));
sz3D = cellfun(@numel,res.fts.loc.x3D(zSel));
dff = res.fts.curve.dffMax(zSel);
dur = res.fts.curve.width55(zSel)/res.opts.frameRate;
r19 = res.fts.curve.rise19(zSel)/res.opts.frameRate;
f91 = res.fts.curve.fall91(zSel)/res.opts.frameRate;

%% analysis
evtMap = lst2map(evt,sz);
evtCnt = zeros(sz(3),1);
evtSz = zeros(sz(3),1);
for tt=1:sz(3)
    tmp = evtMap(:,:,tt);
    tmp = tmp(tmp>0);
    evtSz(tt) = numel(tmp);
    tmp = unique(tmp);
    evtCnt(tt) = numel(tmp);
end
figure;plot(evtSz);title('Size');
figure;plot(evtCnt);title('Count');

burst_t0 = [ 1,37,243,385,605,733,856,984, 1136,1434];
burst_t1 = [27,70,268,417,623,762,882,1025,1178,1472];
inter_rg = ones(1,sz(3));
figure;plot(evtSz);title('Size');hold on
for ii=1:numel(burst_t0)
    t0 = burst_t0(ii);
    t1 = burst_t1(ii);
    plot(t0:t1,evtSz(t0:t1),'r');hold on
    inter_rg(t0+1:t1-1) = 0;
end

% remove events in peaks
burst_pk = [19,51,253,395,615,746,868,1001,1148,1452];
evt_not_pk = true(numel(evt),1);
for ii=1:numel(burst_pk)
    tmp = evtMap(:,:,burst_pk(ii));
    tmp = tmp(tmp>0);
    tmp = unique(tmp);
    evt_not_pk(tmp) = false;
end

evtNotPeak = evt(evt_not_pk);
evtMap1 = lst2map(evtNotPeak,sz);

evtCnt1 = zeros(sz(3),1);
evtSz1 = zeros(sz(3),1);
for tt=1:sz(3)
    tmp = evtMap1(:,:,tt);
    tmp = tmp(tmp>0);
    evtSz1(tt) = numel(tmp);
    tmp = unique(tmp);
    evtCnt1(tt) = numel(tmp);
end
figure;plot(evtSz1);title('Size');
figure;plot(evtCnt1);title('Count');


%% sub groups and features
burst_pk_sel = [8,10];
pre_rg = zeros(1,sz(3));
post_rg = zeros(1,sz(3));
for ii=1:numel(burst_pk_sel)
    ix = burst_pk_sel(ii);
    t0 = burst_t0(ix);
    t1 = burst_t1(ix);
    tp = burst_pk(ix);
    pre_rg(t0:tp) = 1;
    post_rg(tp:t1) = 1;
end

grp_inter = [];
grp_pre = [];
grp_post = [];
evt_label = zeros(numel(evt),1);
for ii=1:numel(evt)
    if evt_not_pk(ii)==0
        continue
    end
    evt0 = evt{ii};
    [~,~,it0] = ind2sub(sz,evt0);
    t0 = min(it0);
    t1 = max(it0);
    if sum(pre_rg(t0:t1))>0
        evt_label(ii) = 1;
    elseif sum(post_rg(t0:t1))>0
        evt_label(ii) = 2;
    elseif sum(inter_rg(t0:t1))>0
        evt_label(ii) = 3;
    else
    end
end

for ii=1:3
    x = find(evt_label==ii);
    X = [sz2D(x)',sz3D(x)',dur(x)',dff(x)',r19(x)',f91(x)'];
    figure;plotmatrix(X);  
end

figure;
for ii=1:3  
    x = find(evt_label==ii);
    mean(dur(x))
    scatter(sz2D(x),dur(x));
    hold on
%     xlabel('Size');ylabel('Duration');
end

sum(evt_label==1)/sum(pre_rg)
sum(evt_label==2)/sum(post_rg)
sum(evt_label==3)/sum(inter_rg)


%% sub group on inter-bursts
evtNumPre = zeros(numel(burst_t0)-1,1);
evtNumPost = evtNumPre;
evtPre = [];
evtPost = [];

for ii=1:numel(burst_t0)-1
    fprintf('%d\n',ii)
    gap_beg = burst_t1(ii);
    gap_end = burst_t0(ii+1);
    gapxx = round((gap_end-gap_beg)/2);
    gapxx = min(gapxx,50);
    
    dPos = evtMap( :,:,gap_beg:(gap_beg+gapxx) );
    dPre = evtMap( :,:,(gap_end-gapxx):gap_end );
    ePos = dPos(dPos>0);
    if ~isempty(ePos)
        ePos = unique(ePos);
        evtPost = union(evtPost,ePos);
        evtNumPost(ii) = numel(ePos);    
    end
    ePre = dPre(dPre>0);
    if ~isempty(ePre)
        ePre = unique(ePre);
        evtPre = union(evtPre,ePre);
        evtNumPre(ii) = numel(ePre);    
    end
end






















