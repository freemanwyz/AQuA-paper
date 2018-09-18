% analyze the simulation results

f0 = 'ex_domain_avgsize_fixed_noprop_nosmo_samedf_20180912_222204';
pIn = 'D:\OneDrive\projects\glia_kira\se_aqua\simDat\';
pOut = 'D:\OneDrive\projects\glia_kira\se_aqua\sim\';
tb = readtable('./x_sim/resLst.csv','Delimiter',',');

% get files
f00 = dir([pOut,'res_*']);
for ii=1:numel(f00)
    if isempty(strfind(f00(ii).name,f0))
        continue
    end
    if ~isempty(strfind(f00(ii).name,'aqua'))
        tb.res{1} = f00(ii).name;
    end
    if ~isempty(strfind(f00(ii).name,'geci'))
        tb.res{2} = f00(ii).name;
    end
    if ~isempty(strfind(f00(ii).name,'cascade'))
        tb.res{3} = f00(ii).name;
    end
    if ~isempty(strfind(f00(ii).name,'calman'))
        tb.res{4} = f00(ii).name;
    end
    if ~isempty(strfind(f00(ii).name,'suite2p'))
        tb.res{5} = f00(ii).name;
    end
end

% information of ground truth
xx = load([pIn,f0,'.mat']);
datSim = xx.datSim;
xx.datSim = cat(3,datSim,zeros(size(datSim,1),size(datSim,2),100,'uint16'));
rOrg = load([pOut,tb.res{1}]);
rOrg.xx = xx;

gt = sim1.anaGt(rOrg,0.01);

% find non-detectable parts




%% Intersection of union
ioux = cell(0);
for ii=1:size(tb,1)
    disp(tb.mthd{ii})
    try
    rIn = load([pOut,tb.res{ii}]);
    ioux{ii} = sim1.anaIoU(rIn.resx,gt,tb.thr(ii),tb.mthd{ii});
    catch
    end
end

for nn=1:6
    figure;title(num2str(nn))
    for ii=1:numel(ioux)
        x = ioux{ii};
        switch nn
            case 1
                x00 = x(:,1);  % gt-pix
            case 2
                x00 = x(:,2);  % gt-vox
            case 3
                x00 = x(:,3);  % dt-pix
            case 4
                x00 = x(:,4);  % dt-vox
            case 5
                x00 = (x(:,1)+x(:,3))/2;  % pix
            case 6
                x00 = (x(:,2)+x(:,4))/2;  % vox
        end        
        plot(gt.snr,x00,'-*','LineWidth',2);hold on;
    end
    legend(tb.mthd); title(num2str(nn));
    set(gca,'FontSize',18); ylim([0,1]);
end


%% Intersection of union, weighted
iouxwt = cell(0);
for ii=1:size(tb,1)
    disp(tb.mthd{ii})
    rIn = load([pOut,tb.res{ii}]);
    iouxwt{ii} = sim1.anaIoUWeighted(rIn,gt,tb.thr(ii),tb.mthd{ii});
end

for nn=1:3
    figure;title(num2str(nn))
    for ii=1:numel(iouxwt)
        x = iouxwt{ii};
        switch nn
            case 1
                x00 = x(:,1);  % gt-vox
            case 2
                x00 = x(:,2);  % gt-vox
            case 3
                x00 = (x(:,1)+x(:,2))/2;  % vox
        end        
        plot(gt.snr,x00,'-*','LineWidth',2);hold on;
    end
    legend(tb.mthd);
    set(gca,'FontSize',18)
    ylim([0,1]);
end


%% precision, recall and F1 score
fxx = cell(0,3);
for ii=1:size(tb,1)
    disp(tb.mthd{ii})
    rIn = load([pOut,tb.res{ii}]);
    [a,b,c] = sim1.anaF1(rIn.resx,gt,tb.thr(ii),tb.mthd{ii});  
    fxx{ii,1} = a;  % precision
    fxx{ii,2} = b;  % recall
    fxx{ii,3} = c;  % f1
end

kk = 6;
for nn=1:3
    figure
    for ii=1:size(fxx,1)
        x = fxx{ii,nn};
        plot(gt.snr,x(:,kk),'-*','LineWidth',2);hold on;
    end
    legend(tb.mthd);
    set(gca,'FontSize',18)
    ylim([0,1]);
end









