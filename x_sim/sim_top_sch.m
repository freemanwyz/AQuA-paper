% run simulation
pIn = 'D:\OneDrive\projects\glia_kira\se_aqua\simDat\';
pOut = 'D:\OneDrive\projects\glia_kira\se_aqua\sim\';

f0 = {'ex-roi_area-avg-min-100_smo-st_201810091742',...
    'ex-roi_area-big-min-100_prop-min-500-gap-100_smo-st_201810091747',...
    'ex-evt_area-big-min-100_smo-st_201810091744',...
    'ex-evt_area-big-min-100_prop-min-500-gap-100_smo-st_201810091749'
    };

% methods
mthdX = 2;
for ii=1:numel(f0)
    % simulation setup
    xx = sim1.prep_sim(pIn,pOut,f0{ii});
    xx.saveMe = 1;
    xx.nRep = 3;
    
    % methods
    switch mthdX
        case 0
            sim1.mthd_aqua(xx,0);  % stable version
            sim1.mthd_suite2p(xx);
        case 1
            sim1.mthd_aqua(xx,1);  % develop version
            sim1.mthd_geci(xx);
        case 2
            %sim1.mthd_cascade(xx);
            sim1.mthd_calman(xx);            
    end
end












