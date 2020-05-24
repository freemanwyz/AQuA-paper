mthdLst = {'gt','aqua','suite2p','caiman','cascade','geci'};
mthdLst1 = reshape(mthdLst,2,3);

fTop0 = getWorkPath();
fTop = [fTop0,'/sim/event_paper_maps/'];
fLst = dir(fTop);
fName = {fLst.name};

% xx = randn(100);
% figure;imagesc(xx,[0,10]);colorbar;axis off
% print(['tmp/','res_2d_colorbar.svg'],'-dsvg','-r800');


%%
% pure ROI (location change 0)
fltx = {'loc-snr10','1-1.mat'};
[resLst,xMax,bdLst] = gather2D(fTop,fName,mthdLst1,fltx);
draw2D(resLst,xMax*0.8,bdLst,'./tmp/pureroi');
% set(gcf,'Position',[100 100 1200 900])
% print(['tmp/','res_2d_roi.svg'],'-dsvg','-r800');

% size change, 5
fltx = {'sz-snr10','5-1.mat'};
[resLst,xMax,bdLst] = gather2D(fTop,fName,mthdLst1,fltx);
draw2D(resLst,xMax*0.6,bdLst,'./tmp/size');
% set(gcf,'Position',[100 100 1200 900])
% print(['tmp/','res_2d_size.svg'],'-dsvg','-r800');

% location change, 1
fltx = {'loc-snr10','5-1.mat'};
[resLst,xMax,bdLst] = gather2D(fTop,fName,mthdLst1,fltx);
draw2D(resLst,xMax*0.6,bdLst,'./tmp/loc');
% set(gcf,'Position',[100 100 1200 900])
% print(['tmp/','res_2d_loc.svg'],'-dsvg','-r800');

% mixed propagation, 10
fltx = {'speed-snr10','mixed','5-1.mat'};
[resLst,xMax,bdLst] = gather2D(fTop,fName,mthdLst1,fltx);
draw2D(resLst,xMax*0.6,bdLst,'./tmp/mixed');
% set(gcf,'Position',[100 100 1200 900])
% print(['tmp/','res_2d_prop_mixed.svg'],'-dsvg','-r800');

% SNR 0 vs 20, size change 3
fltx = {'sz5-snr','3-1.mat'};
[resLst1,xMax1,bdLst1] = gather2D(fTop,fName,mthdLst,fltx);
fltx = {'sz5-snr','3-3.mat'};
[resLst1a,xMax1a,bdLst1a] = gather2D(fTop,fName,mthdLst,fltx);
fltx = {'sz5-snr','3-5.mat'};
[resLst1b,xMax1b,bdLst1b] = gather2D(fTop,fName,mthdLst,fltx);
fltx = {'sz5-snr','3-7.mat'};
[resLst2,xMax2,bdLst2] = gather2D(fTop,fName,mthdLst,fltx);
resLst = [resLst1;resLst1a;resLst1b;resLst2];
bdLst = [bdLst1;bdLst1a;bdLst1b;bdLst2];
xMax = max([xMax1,xMax2,xMax1a,xMax1b]);
draw2D(resLst,xMax*0.6,bdLst,'./tmp/snr');
% set(gcf,'Position',[100 100 1500 1000])
% print(['tmp/','res_2d_snr.svg'],'-dsvg','-r800');






