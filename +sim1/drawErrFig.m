function drawErrFig(tb1,mthdNameLst,xLbl,fOutName,varDir,addLegend)
    % resTb is a table for results
    %
    % tb1: a N by 4 table, method, variable, mean, CI
    % mthdNameLst: cell array of methods used to determine plot order
    
    if ~exist('mthdNameLst','var') || isempty(mthdNameLst)
        mthdNameLst = unique(tb1.mthd);
    end
    if ~exist('varDir','var') || isempty(varDir)
        varDir = 'ascend';
    end
    
    h0 = figure('Name',fOutName);
    varxx = sort(unique(tb1{:,2}),varDir);
    
    for ii=1:numel(mthdNameLst)
        mthd0 = mthdNameLst{ii};
        idx = strcmp(tb1.mthd,mthd0);
        var0 = tb1{idx,2};
        m0 = tb1{idx,3};
        e0 = tb1{idx,4};
        [~,ix] = sort(var0,varDir);
        m1 = m0(ix);
        e1 = e0(ix);
        var1x = sort(var0,'ascend');
        errorbar(var1x,m1,e1,'LineWidth',2);
        hold on;
    end
    
    set(gca,'FontSize',18);
    ylim([0,1]);
    gapxx = 0.1*(max(varxx)-min(varxx));
    xlim([min(varxx)-gapxx,max(varxx)+gapxx])
    
    if exist('xLbl','var') && ~isempty(xLbl)
        xlabel(xLbl);
    else
        xlabel('SNR (dB)');
    end
    
    ylabel('IoU');
    if exist('addLegend','var') && addLegend>0
        legend(mthdNameLst,'Location', 'eastoutside');
    end
    
    set(gca, 'FontName', 'Arial')
    
    if exist('fOutName','var') && ~isempty(fOutName)
        print(h0,['tmp/',fOutName,'.png'],'-dpng','-r300');
        print(h0,['tmp/',fOutName,'.svg'],'-dsvg','-r800');
        close(h0);
    end
    
end


