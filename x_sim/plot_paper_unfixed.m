% plot simulation results
% except features

sessTop = 'event_20181023';
mthdNameLst = {'aqua-stable','geci','cascade','calman','suite2p'};
simResFolder = getWorkPath('outcome');
% dtTb = readtable([simResFolder,'/',sessTop,'_summary_paper.csv']);
dtTb = readtable([simResFolder,'/',sessTop,'_summary_2se.csv']);


%% fixed size change -- variable SNR
f0 = 'nonroi-szChg';
t0 = 'sz5-snr';
xLbl = 'SNR (dB)';
fOutName = 'size fix -- SNR var';

tb0 = dtTb(strcmp(dtTb.file,f0) & strcmp(dtTb.test,t0),:);
tb1 = tb0(:,{'mthd','snr','voxIou','voxIouCi'});
% sim1.drawErrFig(tb1,mthdNameLst,xLbl,'legend',[],1);
sim1.drawErrFig(tb1,mthdNameLst,xLbl,[fOutName,' -vox']);
% sim1.drawErrFig(tb1,mthdNameLst,xLbl,[fOutName,' -pix']);


%% variable size change -- fixed SNR
f0 = 'nonroi-szChg';
t0 = 'sz-snr10';
xLbl = 'Size change odds';
fOutName = 'size var -- SNR fix';

tb0 = dtTb(strcmp(dtTb.file,f0) & strcmp(dtTb.test,t0),:);
tb1 = tb0(:,{'mthd','param','voxIou','voxIouCi'});
sim1.drawErrFig(tb1,mthdNameLst,xLbl,[fOutName,' -vox']);
% sim1.drawErrFig(tb1,mthdNameLst,xLbl,[fOutName,' -pix']);


%% fixed location -- variable SNR
f0 = 'nonroi-locChg';
t0 = 'loc5-snr';
xLbl = 'SNR (dB)';
fOutName = 'location fix -- SNR var';

tb0 = dtTb(strcmp(dtTb.file,f0) & strcmp(dtTb.test,t0),:);
tb1 = tb0(:,{'mthd','snr','voxIou','voxIouCi'});
sim1.drawErrFig(tb1,mthdNameLst,xLbl,[fOutName,' -vox']);
% sim1.drawErrFig(tb1,mthdNameLst,xLbl,[fOutName,' -pix']);


%% variable location -- fixed SNR
f0 = 'nonroi-locChg';
t0 = 'loc-snr10';
xLbl = 'Location change ratio';
fOutName = 'location var -- SNR fix';

tb0 = dtTb(strcmp(dtTb.file,f0) & strcmp(dtTb.test,t0),:);
tb1 = tb0(:,{'mthd','param','voxIou','voxIouCi'});
sim1.drawErrFig(tb1,mthdNameLst,xLbl,[fOutName,' -vox']);
% sim1.drawErrFig(tb1,mthdNameLst,xLbl,[fOutName,' -pix']);











