% Micro prism X-Z data
%

p1 = 'D:\OneDrive\projects\glia_kira\se_aqua\x_paper\res_xz\';

p0 = 'D:\OneDrive\projects\glia_kira\raw\xz_20180822\';
preset = 1;

% f0 = 'stk_0003_1x_5depths_50to265umFMP_10min-001_swBurst'; tPeak=308; t0=304; t1=311; spf = 0.7435;
f0 = '1x_5ps_ch3_onlyburst'; tPeak=52; t0=42; t1=58; spf = 0.6795;

opts = util.parseParam(preset,[],'parameters1.csv');
opts.regMaskGap = 10;
opts.thrARScl = 3;
opts.gtwSmo = 2;

% for 1x_5ps_ch3_onlyburst only
if strcmp(f0,'1x_5ps_ch3_onlyburst')
    opts.thrTWScl = 4;
    opts.thrExtZ = 2;
    opts.minSize = 16;
    opts.cOver = 1;
end

[datOrg,opts] = burst.prep1(p0,[f0,'.tif'],[],opts);
xm = reshape(datOrg,[],opts.sz(3));
figure;plot(mean(xm,1))


%%
try
    load([p1,f0,'_burst.mat']);
catch
    [dat,dF,arLst,lmLoc,opts,~] = burst.actTop(datOrg,opts);
    % zzshow(regionMapWithData(arLst,dat*0));
    [svLst,~,riseX] = burst.spTop(dat,dF,lmLoc,[],opts);
    % zzshow(regionMapWithData(svLst,dat*0));
    [riseLst,datR,evtLst,seLst,seRiseLst] = burst.evtTop(datOrg,[],svLst,riseX,opts);
    % zzshow(regionMapWithData(evtLst,dat*0));    
end


%% on-set time map
evtMap = lst2map(evtLst,opts.sz);
evtMap0 = evtMap(:,:,tPeak);
evtSel = unique(evtMap0(evtMap0>0));

x0 = inf(opts.sz(1:2));
for ii=1:numel(evtSel)
    if sum(evtMap0(:)==evtSel(ii))>200
        r0 = riseLst{ii};
        x0(r0.rgh,r0.rgw) = min(x0(r0.rgh,r0.rgw),r0.dlyMap);
    end
end
x0(isinf(x0)) = nan;
x0(x0>t1) = t1;
x0(x0<t0) = t0;
x0 = (x0-min(x0(:)))*spf;
figure;imagesc(x0,'AlphaData',~isnan(x0));colorbar

% further smoothing (optional)
kn0 = fspecial('gaussian',5,2);
x0s = nan(size(x0));
for ii=4:size(x0,1)-3
    for jj=4:size(x0,2)-3
        if ~isnan(x0(ii,jj))
            x = x0(ii-2:ii+2,jj-2:jj+2);
            x0s(ii,jj) = nansum(x(:).*kn0(:));
        end
    end
end

% add color map
h0 = figure;
imagesc(x0s,'AlphaData',~isnan(x0s));colorbar
m0 = jet(1024); m0 = m0(end:-1:1,:);
colormap(m0)

h1 = figure;
imagesc(x0s,'AlphaData',~isnan(x0s));colorbar
m0 = cool(1024); m0 = m0(end:-1:1,:);
colormap(m0)

%%
print(h0,[f0,'_burst_jet.svg'],'-dsvg','-r800');
print(h1,[f0,'_burst_cool.svg'],'-dsvg','-r800');
print(h0,[f0,'_burst_jet.png'],'-dpng','-r300');
print(h1,[f0,'_burst_cool.png'],'-dpng','-r300');




% save([f0,'_burst.mat'],'seRiseLst','x0','x0s','m0','opts','evtLst','riseLst','svLst','riseX')










