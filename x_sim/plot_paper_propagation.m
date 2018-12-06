% plot simulation results
% except features

sessTop = 'event_20181023';
mthdNameLst = {'aqua-stable','geci','cascade','calman','suite2p'};
simResFolder = getWorkPath('outcome');
dtTb = readtable([simResFolder,filesep,sessTop,'_summary_paper.csv']);


%% grow type propagation -- fixed speed -- variable SNR
f0 = 'prop-grow-speedChg';
t0 = 'speed5-snr';
xLbl = 'SNR (dB)';
fOutName = 'grow type propagation -- fixed speed -- variable SNR';

tb0 = dtTb(strcmp(dtTb.file,f0) & strcmp(dtTb.test,t0),:);
tb1 = tb0(:,{'mthd','snr','voxIou','voxIouCi'});
sim1.drawErrFig(tb1,mthdNameLst,xLbl,[fOutName,' -vox']);
% sim1.drawErrFig(tb1,mthdNameLst,xLbl,[fOutName,' -pix']);


%% grow type propagation -- variable speed -- fixed SNR
f0 = 'prop-grow-speedChg';
t0 = 'speed-snr10';
xLbl = 'Number of propagation frames';
fOutName = 'grow type propagation -- variable speed -- fixed SNR';

tb0 = dtTb(strcmp(dtTb.file,f0) & strcmp(dtTb.test,t0),:);
tb1 = tb0(:,{'mthd','param','voxIou','voxIouCi'});
sim1.drawErrFig(tb1,mthdNameLst,xLbl,[fOutName,' -vox']);
% sim1.drawErrFig(tb1,mthdNameLst,xLbl,[fOutName,' -pix']);


%% move type propagation -- fixed speed -- variable SNR
f0 = 'prop-move-speedChg';
t0 = 'speed5-snr';
xLbl = 'SNR (dB)';
fOutName = 'move type propagation -- fixed speed -- variable SNR';

tb0 = dtTb(strcmp(dtTb.file,f0) & strcmp(dtTb.test,t0),:);
tb1 = tb0(:,{'mthd','snr','voxIou','voxIouCi'});
sim1.drawErrFig(tb1,mthdNameLst,xLbl,[fOutName,' -vox']);
% sim1.drawErrFig(tb1,mthdNameLst,xLbl,[fOutName,' -pix']);


%% move type propagation -- variable speed -- fixed SNR
f0 = 'prop-move-speedChg';
t0 = 'speed-snr10';
xLbl = 'Number of propagation frames';
fOutName = 'move type propagation -- variable speed -- fixed SNR';

tb0 = dtTb(strcmp(dtTb.file,f0) & strcmp(dtTb.test,t0),:);
tb1 = tb0(:,{'mthd','param','voxIou','voxIouCi'});
sim1.drawErrFig(tb1,mthdNameLst,xLbl,[fOutName,' -vox']);
% sim1.drawErrFig(tb1,mthdNameLst,xLbl,[fOutName,' -pix']);


%% mixed type propagation -- fixed speed -- variable SNR
f0 = 'prop-mixed-speedChg';
t0 = 'speed5-snr';
xLbl = 'SNR (dB)';
fOutName = 'mixed type propagation -- fixed speed -- variable SNR';

tb0 = dtTb(strcmp(dtTb.file,f0) & strcmp(dtTb.test,t0),:);
tb1 = tb0(:,{'mthd','snr','voxIou','voxIouCi'});
sim1.drawErrFig(tb1,mthdNameLst,xLbl,[fOutName,' -vox']);
% sim1.drawErrFig(tb1,mthdNameLst,xLbl,[fOutName,' -pix']);


%% mixed type propagation -- variable speed -- fixed SNR
f0 = 'prop-mixed-speedChg';
t0 = 'speed-snr10';
xLbl = 'Number of propagation frames';
fOutName = 'mixed type propagation -- variable speed -- fixed SNR';

tb0 = dtTb(strcmp(dtTb.file,f0) & strcmp(dtTb.test,t0),:);
tb1 = tb0(:,{'mthd','param','voxIou','voxIouCi'});
sim1.drawErrFig(tb1,mthdNameLst,xLbl,[fOutName,' -vox']);
% sim1.drawErrFig(tb1,mthdNameLst,xLbl,[fOutName,' -pix']);









