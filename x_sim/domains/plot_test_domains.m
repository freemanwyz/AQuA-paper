% plot simulation results, domain related

sessTop = {'event_20181023'};
mthdNameLst = {'aqua-stable','geci','cascade','calman','suite2p'};

if ispc
    simResFolder = 'D:\OneDrive\projects\glia_kira\se_aqua\outcome\';
else
    simResFolder = '/Users/yizhi/OneDrive/projects/glia_kira/se_aqua/outcome/';
end

dtTb = cell(0);
for nn=1:numel(sessTop)
    dtTb0 = readtable([simResFolder,filesep,sessTop{nn},'_summary_domain.csv']);
    if nn==1
        dtTb = dtTb0;
    else
        dtTb = [dtTb;dtTb0]; %#ok<AGROW>
    end
end

% variable size change -- fixed SNR
f0 = 'nonroi-domainSz';
t0 = 'domain-sz';
xLbl = 'Domain size change';
fOutName = 'ROI with different size';

tb0 = dtTb(strcmp(dtTb.file,f0) & strcmp(dtTb.test,t0),:);
tb1 = tb0(:,{'mthd','param','voxIou','voxIouCi'});
tb1.param = log10(tb1.param+1);
sim1.drawErrFig(tb1,mthdNameLst,xLbl,[fOutName,' -vox']);









