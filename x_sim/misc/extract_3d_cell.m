p0 = getWorkPath('try');
f0 = [p0,'simDat/cell3d/voletrra_3d/aai8185s1.mp4'];
    
v = VideoReader(f0);
v.CurrentTime = 8;
vid = cell(0);
ii = 1;
while v.CurrentTime<16
    vid{ii} = readFrame(v);
    ii = ii + 1;
end

%%
T = numel(vid);
rgh = 150:330;
rgw = 430:764;
vidx = zeros(numel(rgh),numel(rgw),T);
for ii=1:T
    x = vid{ii};
    x = x(rgh,rgw,:);
    msk = imdilate(x(:,:,1)>100,strel('square',5));  % remove annotations
    x = double(x(:,:,2))/255;
    x(msk) = 0;    
    msk1 = imdilate(x>0.05,strel('square',5));  % remove artifacts
    x = x.*msk1;
    vidx(:,:,ii) = x;
end

%%
vidx1 = vidx(:,:,1:8:end);
writeTiffSeq('cell3d.tif',vidx1,8);
writeTiffSeq('cell3dfull.tif',vidx,8);

% save('cell3d.mat','vidx','vidx1');

%%
alphaMap = max(linspace(0,1,256)',0.1);
% colmap = gray(256);
colmap = jet(256);
figure;volshow(vidx,'Renderer','MaximumIntensityProjection',...
    'AlphaMap',alphaMap,'ColorMap',colmap,'ScaleFactors',[1,1,1]);












