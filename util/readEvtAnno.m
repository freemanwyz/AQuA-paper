function [datSel1,msk1,dat1,tVec1] = readEvtAnno(folderAnno,fDat,nameEvt,rgh1,rgw1,flipType)
    
    tmp = load([folderAnno,fDat,'_',nameEvt,'.mat']);
    msk = tmp.msk0(rgh1,rgw1,:);
    dat1 = tmp.dat0(rgh1,rgw1,:);
    datSel1 = cat(3,tmp.dat0Sel(rgh1,rgw1,:),dat1(:,:,end));
    msk1 = cat(3,msk,msk(:,:,1)*0);
    if strcmp(flipType,'upDown')
        msk1 = msk1(end:-1:1,:,:);
        datSel1 = datSel1(end:-1:1,:,:);
        dat1 = dat1(end:-1:1,:,:);
    end
    tVec1 = tmp.tVec;
    
end