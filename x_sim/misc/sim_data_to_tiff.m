% Output simulation data sets

fTop = getWorkPath();
pIn = [fTop,'simDat/event_20181023/'];
pOut = [fTop,'sim/event_try/'];

f0 = {
    {'nonroi-locChg','loc-snr10',10,'loc5-snr',3},...
    {'nonroi-szChg','sz-snr10',10,'sz5-snr',3},...
    {'prop-grow-speedChg','speed-snr10',10,'speed5-snr',3},...
    {'prop-move-speedChg','speed-snr10',10,'speed5-snr',3},...
    {'prop-mixed-speedChg','speed-snr10',10,'speed5-snr',3}
    };

% snrVec = [0,2.5,5,7.5,10,15,20];
% smoVec = flip([0.1,0.5,0.6,0.7,0.8,0.9,1]);
    
% var
for ii=1:numel(f0)
    %snrx = f0{ii}{3};
    %[~,ix] = min(abs(snrx-snrVec));
    xx = sim1.prep_sim(pIn,pOut,f0{ii}{1},[],[],[],1,1);
    
end
    



