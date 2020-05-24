% frames in a folder to a single TIFF stack
p0 = 'D:\brain\glia_kira\raw\GCaMP_May17\Lck_Gcamp with Aldh1l1-tdtomato\';
pOut = 'D:\OneDrive\projects\glia_kira\raw\GCaMP_May17\Lck_Gcamp with Aldh1l1-tdtomato\';

pLst = dir(p0);
for ee=1:numel(pLst)
    p1x = pLst(ee);
    p1 = p1x.name;
    if strcmp(p1,'.') || strcmp(p1,'..') || p1x.isdir==0
        continue
    end
    %p1 = '1_2_4x_reg_200um_dualwv-001';
    fprintf('%s -------- \n',p1)
    
    for ii=1:10        
        fLst = dir([p0,p1,filesep,'*Cycle0000',num2str(ii),'*ch1*']);        
        if isempty(fLst)
            continue
        end
        
        dat0 = imread([fLst(1).folder,filesep,fLst(1).name]);
        [H,W] = size(dat0);
        T = numel(fLst);
        
        fprintf('Cycle %d -------- \n',ii)
        dat = zeros(H,W,T,class(dat0));
        for k=1:numel(fLst)
            if mod(k,100)==0
                fprintf('%d\n',k)
            end
            fName = [fLst(k).folder,filesep,fLst(k).name];
            dat(:,:,k) = imread(fName);
        end        
        fOut = [pOut,p1,'_',num2str(ii),'.tif'];
        io.writeTiffSeq(fOut,dat,0);        
    end    
end