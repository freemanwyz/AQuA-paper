% run simulation for non-ROI and propagation type events
pIn = 'D:\OneDrive\projects\glia_kira\se_aqua\simDat\real_20181030\';
pOut = 'D:\OneDrive\projects\glia_kira\se_aqua\sim\real_20181030\';

% file name, test name, presets, smoothness
f0 = {
    {'exvivo','real',3,0.5},...
    {'invivo','real',1,0.5}
    };

mthdNames = {'aqua-stable','cascade','calman','suite2p','geci'};
mthdX = 1;


%% simulation
for ii=1:numel(f0)
    % simulation setup
    xxAll = matfile([pIn,f0{ii}{1},'.mat']);
    nExp = size(xxAll.evtLst,1);
    
    for jj=1:nExp
        xxLst = sim1.prep_sim_real(pIn,pOut,f0{ii},jj,0.001);
        
        % methods        
        switch mthdX
            case 1
                sim1.mthd_aqua_real(xxLst);
            case 2
                sim1.mthd_cascade(xxLst);
            case 3
                sim1.mthd_calman(xxLst);
            case 4
                sim1.mthd_suite2p(xxLst);
            case 5
                sim1.mthd_geci(xxLst);
        end
    end
end








