% how to refine refernece curves?
addpath(genpath('../AQuA/'));
smoBase = 1;
maxStp = 10;
H = 100;
W = 100;
T = 20;
dF = zeros(H,W,T);

for tt=1:8
    w0 = 19+(tt-1)*8;
    w1 = w0+7;
    t0 = 5+tt;
    t1 = 15;
    dF(19:82,w0:w1,t0:t1) = 1;
end

s00 = 0.1;
dF = dF*0.2;
dat = dF + randn(size(dF))*s00;


%% GTW graph
validMap = sum(dF,3)>0;
spSeedVec = find(validMap>0);
nSp = numel(spSeedVec);
spStd = zeros(nSp,1)+s00;
spLst = num2cell(spSeedVec);

% graph
gapSeed = 0;
[ref,tst,refBase,s,t,idxGood] = gtw.sp2graph(dat,validMap,spLst,[],gapSeed);

% gtw
spLst = spLst(idxGood);
spSeedVec = spSeedVec(idxGood);
s2 = spStd(idxGood).^2;
s2(s2==0) = median(s2);

[ ss,ee,gInfo ] = gtw.buildGTWGraph( ref, tst, s, t, smoBase, maxStp, s2);
[~, labels1] = aoIBFS.graphCutMex(ss,ee);
path0 = gtw.label2path4Aosokin( labels1, ee, ss, gInfo );


%% warped curves
pathCell = cell(H,W);
vMap1 = zeros(H,W);
vMap1(spSeedVec) = 1:numel(spSeedVec);
for ii=1:numel(spLst)
    [ih0,iw0] = ind2sub([H,W],spSeedVec(ii));
    pathCell{ih0,iw0} = path0{ii};
end

datWarp = gtw.warpRef2Tst(pathCell,refBase/max(refBase(:)),vMap1,[H,W,numel(refBase)]);
dVec = reshape(datWarp,[],numel(refBase));
cx = dVec(spSeedVec,:);












