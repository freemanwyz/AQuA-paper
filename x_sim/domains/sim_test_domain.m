% run simulation for domain size and cicularity
pIn = 'D:\OneDrive\projects\glia_kira\se_aqua\simDat\event_20181023\';
pOut = 'D:\OneDrive\projects\glia_kira\se_aqua\sim\event_20181023\';

f0 = {
    {'nonroi-domainSz','domain-sz',10}
    };

mthdNames = {'aqua-stable','cascade','calman','suite2p','geci'};
% m = 1
nRepUsed = 2;

snrVec = [0,2.5,5,7.5,10,15,20];
smoVec = flip([0.1,0.5,0.6,0.7,0.8,0.9,1]);


% var
for ii=1:numel(f0)
    % simulation setup
    snrx = f0{ii}{3};
    [~,ix] = min(abs(snrx-snrVec));    
    xxAll = matfile([pIn,f0{ii}{1},'.mat']);
    nExp = size(xxAll.evtLst,1);
    
    for jj=1:nExp
        xx = sim1.prep_sim(pIn,pOut,f0{ii}{1},snrx,smoVec(ix),jj,nRepUsed);
        for kk=1:numel(xx)
            xx{kk}.f1 = f0{ii}{2};
            xx{kk}.saveMe = 1;
        end
        
        % methods        
        switch m
            case 1
                sim1.mthd_aqua(xx,0);  % stable version
            case 2
                sim1.mthd_cascade(xx);
            case 3
                sim1.mthd_calman(xx);
            case 4
                sim1.mthd_suite2p(xx);
            case 5
                sim1.mthd_geci(xx);
        end
    end
end








