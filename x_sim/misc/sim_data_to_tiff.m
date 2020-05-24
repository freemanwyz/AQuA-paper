% Output simulation data sets

fTop = getWorkPath();
pIn = [fTop,'simDat/event_20181023/'];
pOut = [fTop,'sim/event_try/'];

fTmp = 'C:\Users\eric\Desktop\';

f0 = {
    {'nonroi-locChg','loc-snr10',10,'loc5-snr',3},...
    {'nonroi-szChg','sz-snr10',10,'sz5-snr',3},...
    {'prop-grow-speedChg','speed-snr10',10,'speed5-snr',3},...
    {'prop-move-speedChg','speed-snr10',10,'speed5-snr',3},...
    {'prop-mixed-speedChg','speed-snr10',10,'speed5-snr',3}
    };
    
% var
for ii=1:numel(f0)
    expSel = 5;
    sName = f0{ii}{1};
    xxVec = sim1.prep_sim(pIn,pOut,sName,[],[],[],expSel,1);
    xx = xxVec{1};
    datSimNy0 = xx.datSim + xx.dAvg*xx.bgRt + randn(xx.sz)*xx.nStdVec(5)+0.2;
    fOut = [fTmp,sName,'-nonROI.tif'];
    disp(fOut);
    writeTiffSeq(fOut,datSimNy0,8);
end
    
for ii=1:numel(f0)
    expSel = 1;
    sName = f0{ii}{1};
    xxVec = sim1.prep_sim(pIn,pOut,sName,[],[],[],expSel,1);
    xx = xxVec{1};
    datSimNy0 = xx.datSim + xx.dAvg*xx.bgRt + randn(xx.sz)*xx.nStdVec(5)+0.2;
    fOut = [fTmp,sName,'-ROI.tif'];
    disp(fOut);
    writeTiffSeq(fOut,datSimNy0,8);    
end


