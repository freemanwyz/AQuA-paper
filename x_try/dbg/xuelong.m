% seMap
myFile = java.io.FileInputStream('./tmp/SeMap.bin');
myObj = java.io.ObjectInputStream(myFile);
x0 = myObj.readObject();
myFile.close;
myObj.close;

se0 = double(x0);
se0 = permute(se0,[2,1,3]);
zzshow(regionMapWithData(se0));

% df
myFile = java.io.FileInputStream('./tmp/DF.bin');
myObj = java.io.ObjectInputStream(myFile);
x0 = myObj.readObject();
myFile.close;
myObj.close;

df0 = double(x0);
df0 = df0/max(df0(:));
df0 = permute(df0,[2,1,3]);
zzshow(df0);

myFile.close;

%% gtw
addpath(genpath('../../repo/aqua_20180705/'));
pTop = getWorkPath();
opts = util.parseParam(1,0,'parameters1.csv');

gtwSmo = 0.5; % 0.5
maxStp = opts.maxStp; % 11
% maxRiseUnc = opts.cRise;  % 1
maxRiseUnc = 1;
cDelay = opts.cDelay;  % 5

[spLst,cx,dlyMap,distMat] = gtw.spgtw(...
    df0,se0,1,gtwSmo,maxStp,cDelay,25,30,opts);

[~,evtMemC,evtMemCMap] = burst.riseMap2evt(spLst,dlyMap,distMat,maxRiseUnc,cDelay,0);
evtMap = zeros(size(dlyMap));
for ii=1:max(evtMemC(:))
    idx0 = evtMemC==ii;
    spLst0 = spLst(idx0);
    distMat0 = distMat(idx0,idx0);
    dlyMap0 = dlyMap;
    dlyMap0(evtMemCMap~=ii) = Inf;
    evtMap00 = burst.riseMap2evt(spLst0,dlyMap0,distMat0,maxRiseUnc,cDelay,1);
    evtMap00(evtMap00>0) = evtMap00(evtMap00>0) + max(evtMap(:));
    evtMap = max(evtMap,evtMap00);
end

zzshow(regionMapWithData(evtMap))










