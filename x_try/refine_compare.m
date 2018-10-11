%% compare Matlab and Java implementation
% use simple simulation
if ~exist('HTregionGrowingSuper','class')
    javaclasspath('-v1')
    javaclasspath('..\..\repo\gfptoolbox\tools\FASP\out\production\FASP\')
end

tmp = load('normTopMeanDist'); 
osTb = tmp.tbTopNorm;

H = 256;
W = 256;
T = 32;
d = 64;
dt = 1;
std0 = 0.5;

%% synthetic data
evtMap = zeros(H,W);
evtMap(H/2-d:H/2+d,W/2-d:W/2+d) = 1;

nPix = sum(evtMap(:)>0);

charx = zeros(1,T);
charx(T/2-dt:T/2+dt) = 1;
charx = zscore(charx);

% background
% dat = randn(nPix,T)*std0+charx;
datOut = randn(H*W-nPix,T)*std0;
mov = zeros(H*W,T);
mov(evtMap(:)==0,:) = datOut;

% foreground
pixLst = find(evtMap>0);
for ii=1:numel(pixLst)
    pix0 = pixLst(ii);
    [ih0,iw0] = ind2sub([H,W],pix0);
    scl0 = 1-sqrt((ih0-H/2)^2+(iw0-W/2)^2)/d/2;
    mov(pix0,:) = randn(1,T)*std0+charx*scl0;
end
dat = mov(pixLst,:);
mov = reshape(mov,H,W,T);
zzshow(mov/max(mov(:)));

% correlation and z score map
datZ = zscore(dat,0,2);
datOutZ = zscore(datOut,0,2);

r = mean(datZ.*charx,2);
rOut = mean(datOutZ.*charx,2);

z = getFisherTrans(r,T);
zOut = getFisherTrans(rOut,T);

zMap = zeros(H,W);
zMap(evtMap>0) = z;
zMap(evtMap==0) = zOut;

vMap = ones(H,W);

figure;imagesc(zMap);colorbar

%% compare
tic; res0 = HTregionGrowingSuper(zMap,vMap,2,4,4,0); toc
htMap00 = double(res0.connDmIDmap);
% zzshow(regionMapWithData(htMap00),'java');

tic; [htMap00a,~,~] = htrg2(zMap,[],vMap,osTb,2,4,4,8); toc
% zzshow(regionMapWithData(htMap00a),'matlab');






