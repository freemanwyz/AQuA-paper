% in vivo data with different methods

folderPrj = 'D:\neuro_WORK\glia_kira\projects\';
[~,fDat] = runCfg();

mthdLst = {'aqua','suite2p','calman','cascade','geciquant','fasp'};
resFileLst = cell(0);
for ii=1:numel(mthdLst)
    m0 = mthdLst{ii};
    resFileLst{ii} = [folderPrj,m0,filesep,fDat,'_',m0,'.mat'];
end

% aqua = [fprj,'aqua\2826451(4)_1_2_4x_reg_200um_dualwv-001_nr_auqa.mat'];
% suite2p = [fprj,'suite2p\2826451(4)_1_2_4x_reg_200um_dualwv-001_nr_suite2p.mat'];
% calman = [fprj,'calman\2826451(4)_1_2_4x_reg_200um_dualwv-001_nr_calman.mat'];
% cascade = [fprj,'cascade\2826451(4)_1_2_4x_reg_200um_dualwv-001_nr_cascade.mat'];
% geciquant = [fprj,'geciquant\2826451(4)_1_2_4x_reg_200um_dualwv-001_nr_geciquant.mat'];
% fasp = [fprj,'fasp\2826451(4)_1_2_4x_reg_200um_dualwv-001_nr_fasp.mat'];
% mthdLst = {aqua,suite2p,calman,cascade,geciquant,fasp};

% gather results
nMthd = numel(mthdLst);
actTimeLst = cell(nMthd,1);
bdLst = cell(nMthd,1);
pixLst = cell(nMthd,1);
ovLst = cell(nMthd,1);

for nn=1:nMthd
    tmp = load(resFileLst{nn}); res = tmp.res;
    if nn==1
        [nEvt,T,~] = size(res.dffMat);
        xFg = false(nEvt,T);
        for ii=1:size(xFg,1)
            t0 = res.fts.curve.tBegin(ii);
            t1 = res.fts.curve.tEnd(ii);
            xFg(ii,t0:t1) = true;
        end
        bdLst{nn} = res.fts.bds;
        pixLst{nn} = res.fts.loc.x2D;
        ov = res.ov('Events');
        ovLst{nn} = ov;
    else
        %if nn~=4
            x = res.dff;
            F0 = median(x,2);
            s0 = sqrt(nanmedian((x(:,1:end-1)-x(:,2:end)).^2,2)/0.9);  % estimate noise
            xFg = (x-F0)./s0>5;
        %else
        %    xFg = res.dffSpk>0;
        %end        
        bdLst{nn} = res.bdLst;
        pixLst{nn} = res.roiLst;
    end    
    actTimeLst{nn} = xFg;
end

%% save
fOut = ['D:\neuro_WORK\glia_kira\projects\x_paper\',fDat,'.mat'];
save(fOut,'bdLst','actTimeLst','ovLst','pixLst','mthdLst');









