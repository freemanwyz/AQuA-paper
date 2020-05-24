%% load 3D astrocyte morphology
p0 = getWorkPath('try');
f0 = [p0,'simDat/cell3d/voletrra_3d/cell3d.mat'];
s = load(f0);
dat = s.vidx1;

% clean the morphology
template = dat(1:2:end,1:2:end,:);
templateMsk = template>0;
templateMsk = imerode(templateMsk,strel('square',3));
for dd=1:size(templateMsk,3)
    xx = templateMsk(:,:,dd);
    templateMsk(:,:,dd) = bwareaopen(xx,25);
end


%% growing type propagation
rng(888);

[H,W,D] = size(template);
T = 150;

eventsMovie = zeros(H,W,D,T,'uint8');
labelMovie = zeros(H,W,D,T,'uint16');
allowMap = true(size(eventsMovie));

% add larger events
nEvtsLarge = 20;
[labelMovie,eventsMovie,allowMap] = sim1.addEvents3D(...
    labelMovie,eventsMovie,allowMap,nEvtsLarge,template,templateMsk,0,1);

% add smaller events
kNow = max(labelMovie(:))+1;
nEvtsSmall = 50;
[labelMovie,eventsMovie,allowMap] = sim1.addEvents3D(...
    labelMovie,eventsMovie,allowMap,nEvtsSmall,template,templateMsk,1,kNow);


%% export for Vaa3D
nameOut = 'test_';
datOut = uint8(template*255*0.5)+eventsMovie*0.2;

% pOut = [p0,'simDat/cell3d/evt/'];
% writeTiff5D(datOut,labelMovie,pOut,nameOut);

pOut = [p0,'simDat/cell3d/evt_3D_20/'];
writeTiff5D(datOut,[],pOut,nameOut);

evtLst = label2idx(labelMovie);
mOut = [p0,'simDat/cell3d/evt_3D_20.mat'];
sz = size(eventsMovie);
save(mOut,'evtLst','sz');











