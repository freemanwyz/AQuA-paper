% run simulation for non-ROI and propagation type events
fTop = getWorkPath();
pIn = [fTop,'simDat/event_20181023/'];
pOut = [fTop,'sim/event_try/'];
% pOut = [fTop,'sim/event_20181023/'];

f0 = {
    {'nonroi-locChg','loc-snr10',10,'loc5-snr',3},...
    {'nonroi-szChg','sz-snr10',10,'sz5-snr',3},...
    {'prop-grow-speedChg','speed-snr10',10,'speed5-snr',3},...
    {'prop-move-speedChg','speed-snr10',10,'speed5-snr',3},...
    {'prop-mixed-speedChg','speed-snr10',10,'speed5-snr',3}
    };

mthdNames = {'aqua-stable','cascade','calman','suite2p','geci'};
% m = 1
saveMe = 0;  % 1
nRepUsed = 1;  % 1e8
ignoreVar = 0;
ignoreSnr = 0;

snrVec = [0,2.5,5,7.5,10,15,20];
smoVec = flip([0.1,0.5,0.6,0.7,0.8,0.9,1]);

runsX = {[]};
% runsX = {[],1,2};
% runsX = {2};
for nn=1:numel(runsX)
    simIdx = runsX{nn};
    % simIdx = 2;  % [] for base, number for additional
    
    % var
    if ignoreVar==0
        for ii=1:numel(f0)
            % simulation setup
            snrx = f0{ii}{3};
            [~,ix] = min(abs(snrx-snrVec));
            xxAll = matfile([pIn,f0{ii}{1},num2str(simIdx),'.mat']);
            nExp = size(xxAll.evtLst,1);
            
            % AQuA params for propagation
            opts = [];
            opts.spSz = 25;
            thrxx = 1000;
            if contains(f0{ii}{1},'prop')
                opts.cDelay = 3;
                opts.spSz = 9;  % 16,25
                opts.gtwSmo = 0.5;
                opts.gtwGapSeedMin = 2;
                opts.gtwGapSeedRatio = 1000;
            end
            
            for jj=1:nExp
                xx = sim1.prep_sim(pIn,pOut,f0{ii}{1},simIdx,snrx,smoVec(ix),jj,nRepUsed);
                for kk=1:numel(xx)
                    xx{kk}.f1 = f0{ii}{2};
                    xx{kk}.saveMe = saveMe;
                end
                
                % methods
                mthd0 = mthdNames{m};
                fOut = [xx{1}.pOut,xx{1}.f1,'_',mthd0,'_',xx{1}.f0,'.mat'];
                if exist(fOut,'file')
                    try
                        tmp = load(fOut);
                        fprintf('%s already simulated, adding\n',fOut);
                        %continue
                    catch
                    end
                end
                
                switch m
                    case 1
                        sim1.mthd_aqua(xx,opts);  % stable version
                    case 2
                        sim1.mthd_cascade(xx);
                    case 3
                        sim1.mthd_calman(xx);
                    case 4
                        sim1.mthd_suite2p(xx);
                    case 5
                        sim1.mthd_geci(xx,thrxx);
                end
            end
        end
    end
    
    
    % snr
    if ignoreSnr==0
        for ii=1:numel(f0)
            % simulation setup
            xx = sim1.prep_sim(pIn,pOut,f0{ii}{1},simIdx,[],[],f0{ii}{5},nRepUsed);
            for kk=1:numel(xx)
                xx{kk}.f1 = f0{ii}{4};
                xx{kk}.saveMe = saveMe;
            end
            
            opts = [];
            opts.spSz = 25;
            thrxx = 1000;
            if contains(f0{ii}{1},'prop')
                opts.cDelay = 3;
                opts.spSz = 9;  % 16,25
                opts.gtwSmo = 0.5;
                opts.gtwGapSeedMin = 2;
                opts.gtwGapSeedRatio = 1000;
            end
            
            % methods
            mthd0 = mthdNames{m};
            fOut = [xx{1}.pOut,xx{1}.f1,'_',mthd0,'_',xx{1}.f0,'.mat'];
            if exist(fOut,'file')
                try
                    tmp = load(fOut);
                    fprintf('%s already simulated, adding\n',fOut);
                    %continue
                catch
                end
            end
            
            switch m
                case 1
                    sim1.mthd_aqua(xx,opts);  % stable version
                case 2
                    sim1.mthd_cascade(xx);
                case 3
                    sim1.mthd_calman(xx);
                case 4
                    sim1.mthd_suite2p(xx);
                case 5
                    sim1.mthd_geci(xx,thrxx);
            end
        end
    end
    
end




