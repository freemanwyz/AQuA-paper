%%
fp = '../AQuA-stable/';
addpath(genpath(fp));
fOut = getWorkPath('try');
p0 = [fOut,'\dat\'];
% f0 = '2826451(4)_1_2_4x_reg_200um_dualwv-001_nr'; preset = 1;
f0 = 'FilteredNRMCCyto16m_slice3_Baseline3_L2 3-015cycle1channel1'; preset = 3;
opts = util.parseParam(preset,[],'parameters1.csv');
opts.thrARScl = 2;
[datOrg,opts] = burst.prep1(p0,[f0,'.tif'],[],opts);


%%
xx = zeros(101,101,51);
wt = linspace(0.2,0.8,40);
for i=1:numel(wt)
    xx(20:80,20+i,25:30) = wt(i);
end
% xx(20:80,20:40,25:35) = 0.4;
% xx(20:80,41:60,25:35) = 0.8;
% xx(40:60,40:60,25:35) = 0.1;
% xx(45:55,45:55,29:31) = 0.5;


%% viewer3D
fp = '../../toolbox/plots/viewer3d';
addpath(genpath(fp));
datx = double(datOrg(:,:,1:20));
% viewer3d(datx);

% m0 = viewmtx(0,0);
% m0 = viewmtx(45,45);
m0 = eye(4);
theta = pi/4;
sclxy = 0.5;
sclz = 1;
% m0 = [1 0 0 0; 0 cos(theta) -sin(theta) 0; 0 sin(theta) cos(theta) 0; 0 0 0 1]*m0;
m0 = [cos(theta) 0 sin(theta) 0; 0 1 0 0; -sin(theta) 0 cos(theta) 0; 0 0 0 1]*m0;
% m0 = [cos(theta) -sin(theta) 0 0; sin(theta) cos(theta) 0 0; 0 0 1 0; 0 0 0 1]*m0;
m0 = [sclxy 0 0 0; 0 sclxy 0 0; 0 0 sclz 0; 0 0 0 1]*m0;
% m0 = inv(m0);

ct0 = gray(256);

OPTIONS = [];
OPTIONS.ViewerVector = [1,1,100];
OPTIONS.Mview = m0;
OPTIONS.AlphaTable = max(linspace(0,1,256).^2,0.0);
OPTIONS.RenderType = 'mip';
OPTIONS.ColorTable = ct0;
% zzshow(render(xx,OPTIONS));
hh = render(datx,OPTIONS);
% figure;imagesc(hh)
zzshow(hh)


%% volshow, need R2018b or later
xx = zeros(101,101,51);
xx(40:60,40:60,25:35) = 0.1;
xx(45:55,45:55,29:31) = 0.5;
alphaMap = linspace(0,1,256)'.^2;
figure;volshow(xx,'AlphaMap',alphaMap);
figure;volshow(xx,'Renderer','VolumeRendering','AlphaMap',alphaMap);
figure;volshow(xx,'Renderer','MaximumIntensityProjection');

%%
datx = double(datOrg(:,:,1:100));
alphaMap = linspace(0,1,256)';
% colmap = gray(256);
colmap = jet(256);
figure;volshow(datx,'Renderer','MaximumIntensityProjection',...
    'BackgroundColor',[0.1,0.1,0.1],...
    'AlphaMap',alphaMap,'ColorMap',colmap,'ScaleFactors',[1,1,4]);

hh = volshow(datx,'Renderer','MaximumIntensityProjection',...
    'BackgroundColor',[0.1,0.1,0.1],...
    'AlphaMap',alphaMap,'ColorMap',colmap,'ScaleFactors',[1,1,4]);





