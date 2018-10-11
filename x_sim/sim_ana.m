% analyze the simulation results
sess0 = 'exvivo_20181010';

% f0 = 'ex-roi_area-avg-min-100_smo-st_201810091742';
% f0 = 'ex-roi_area-big-min-100_prop-min-500-gap-100_smo-st_201810091747';
% f0 = 'ex-evt_area-big-min-100_smo-st_201810091744';
f0 = 'ex-evt_area-big-min-100_prop-min-500-gap-100_smo-st_201810091749';

pIn = 'D:\OneDrive\projects\glia_kira\se_aqua\simDat\';
pOutx = 'D:\OneDrive\projects\glia_kira\se_aqua\sim\';
tb = readtable('./x_sim/resLst.csv','Delimiter',',');

% get files
pOut = [pOutx,filesep,sess0,filesep];
f00 = dir([pOut,'res_*']);
namex = {'aqua','geci','cascade','calman','suite2p'};
for ii=1:numel(f00)
    if isempty(strfind(f00(ii).name,f0))
        continue
    end
    for jj=1:numel(namex)
        if ~isempty(strfind(f00(ii).name,namex{jj}))
            tb.res{jj} = f00(ii).name;
        end
    end
end

% information of ground truth
xx = load([pIn,f0,'.mat']);
datSim = xx.datSim;
xx.datSim = cat(3,datSim,zeros(size(datSim,1),size(datSim,2),100,'uint16'));
rOrg = load([pOut,tb.res{1}]);
rOrg.xx = xx;
gt = sim1.anaGt(rOrg,0.01);


%% Intersection of union
ioux = cell(0);
for ii=1:size(tb,1)
    disp(tb.mthd{ii})
    try
        rIn = load([pOut,tb.res{ii}]);
        r = rIn.resx;
        iou0 = nan(size(r,1),size(r,2),4);
        for jj=1:size(r,2)
            iou0(:,jj,:) = sim1.anaIoU(r(:,jj),gt,tb.thr(ii),tb.mthd{ii});
        end
        ioux{ii} = iou0;
    catch
    end
end

if numel(gt.snr)==9
    rgsnr = 3:9;  % start from 0 dB
end
if numel(gt.snr)==7
    rgsnr = 1:7;
end

%% plot
tt = {'IoU','IoU area'};
% mks = ['o','d','*','x','s'];
for nn=1:2
    h0 = figure;
    title(num2str(nn))
    for ii=1:numel(ioux)
        x = ioux{ii};
        if isempty(x)
            continue
        end
        switch nn
            case 1
                x00 = squeeze((x(:,:,2)+x(:,:,4))/2);  % vox
                m0 = mean(x00,2);
                e0 = std(x00,0,2)*2;  % 95% CI
            case 2
                x00 = squeeze((x(:,:,1)+x(:,:,3))/2);  % vox
                m0 = mean(x00,2);
                e0 = std(x00,0,2)*2;
        end
        errorbar(gt.snr(rgsnr),m0(rgsnr),e0(rgsnr),'LineWidth',2);
        %plot(gt.snr,x00,'-*','LineWidth',2);
        hold on;
    end
    set(gca,'FontSize',18);
    ylim([0,1]); xlim([-2.5,22.5])
    xlabel('SNR (dB)');
    ylabel('IoU');
    legend(tb.mthd); title(tt{nn});
    if nn==1
        %print(h0,['tmp/',f0,'_',tt{nn},'_sim.svg'],'-dsvg','-r800');
        %print(h0,['tmp/',f0,'_',tt{nn},'_sim.png'],'-dpng','-r300');
        %close(h0);
    end
end









