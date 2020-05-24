function [dat,datSel,p] = pltPrep3D()
    
    % data
    folderTop = getWorkPath();
    folderAnno = [folderTop,'x_paper/labels/'];
    fDat = 'FilteredNRMCCyto16m_slice2_TTX3_L2 3-012cycle1channel1';
    
    rgh1 = 12:190;
    rgw1 = 11:67;
    
    % propagation with two events
    [datSel1,msk1,dat1] = readEvtAnno(folderAnno,fDat,'prop1_less',rgh1,rgw1,'upDown');
    
    % propagation with one events
    [datSel2,msk2,dat2] = readEvtAnno(folderAnno,fDat,'prop2_less',rgh1,rgw1,'upDown');
    
    % combine two events
    msk2(msk2>0) = msk2(msk2>0)+max(msk1(:));
    msk = cat(3,msk1,msk2);
    datSel = cat(3,datSel1,datSel2);
    dat = cat(3,dat1,dat2);
    
    [p.L1,p.L1rgb,p.sLoc1] = msk2sv(msk1,datSel1);
    [p.L2,p.L2rgb,p.sLoc2] = msk2sv(msk2,datSel2);
    
    p.neibLst1 = label2neibSlow(p.L1);
    p.neibLst2 = label2neibSlow(p.L2);
    p.neibLst12 = label2neibBetween(p.L1,p.L2,0.25);
    p.T0 = size(msk1,3);
    p.msk = msk;
    p.mskSel = msk;
    p.msk1 = msk1;
    p.msk2 = msk2;
    p.dat1 = dat1;
    p.dat2 = dat2;
    p.bdLst = [];
    p.actFrame = [];
    p.colxPixReg = lines;
    p.colEvt = [0 0 1;1 0 0;1 0.5 0];
    
    % curve: one curve, one color, from colxPixReg. peak: peak color from colEvt
    p.curveCol = 'curve';
    
end


