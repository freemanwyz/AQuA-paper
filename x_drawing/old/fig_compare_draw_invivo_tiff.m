% in vivo data with different methods
tmp = load('greenFireBlue.mat');
greenFireBlue = tmp.greenFireBlue;
[folderDat,fDat] = runCfg();

folderRes = 'D:\neuro_WORK\glia_kira\projects\x_paper\';
outName = 'fig2';
fRes = [folderRes,fDat,'.mat'];
resAll = load(fRes);

fdat = [folderDat,fDat,'.tif'];
dat = io.readTiffSeq(fdat);
dat = dat./max(dat(:));
[H,W,~] = size(dat);

F0 = min(movmean(dat,50,3),[],3);

ftypes = {'tiff'};
for ii=1:numel(ftypes)
    ft0 = ftypes{ii};
    pOut = [folderRes,outName,filesep,ft0,filesep,fDat,'_small'];
    if ~exist(pOut,'file')
        mkdir(pOut);
    end
end

%% draw some frames
% trg = 1450;
% trg = 1440:5:1460;
% rgh = 101:300;
% rgw = 31:230;

trg = 462:3:471;
dhw = 30;
rgh = 242:242+dhw;
rgw = 377:377+dhw;

scl = 2;

xMap = zeros(H,W);
xMap(rgh,rgw) = 1;

fxx = cell(0);

for ee=1:numel(trg)
    tt = trg(ee);
    fprintf('Frame %d ===== \n',tt)
    d0 = dat(:,:,tt)-F0;
    
    % raw data
    ftNow = [];
    d0Int8 = round(d0*255)+1;
    d0Int8(d0Int8>256) = 256;
    d0Int8(d0Int8<1) = 1;
    x = greenFireBlue(:,1); d0r = x(d0Int8);
    x = greenFireBlue(:,2); d0g = x(d0Int8);
    x = greenFireBlue(:,3); d0b = x(d0Int8);
    d0rgb = cat(3,d0r,d0g,d0b);
    d0rgbSel = d0rgb(rgh,rgw,:);    
    ftNow.df = d0rgbSel/255*scl;
    
    % methods
    for nn=1:numel(resAll.mthdLst)
        bd = resAll.bdLst{nn};
        act = resAll.actTimeLst{nn};
        act0 = act(:,tt);
        pix = resAll.pixLst{nn};
        
        % regions
        if nn==1
            ov = resAll.ovLst{1};
            ov0 = ov.frame{tt};
            if ~isempty(ov0)
                colx = ov.col;
                oMapR = zeros(H,W);
                oMapG = zeros(H,W);
                oMapB = zeros(H,W);
                for jj=1:numel(ov0.idx)
                    c0 = colx(ov0.idx(jj),:);
                    oMapR(ov0.pix{jj}) = ov0.val{jj}*c0(1);
                    oMapG(ov0.pix{jj}) = ov0.val{jj}*c0(2);
                    oMapB(ov0.pix{jj}) = ov0.val{jj}*c0(3);
                end
                oMap = cat(3,oMapR,oMapG,oMapB);
                d0x = oMap/2+d0;
            else
                d0x = cat(3,d0,d0,d0);
            end
        else
            oMap = zeros(H,W);
            for jj=1:numel(bd)
                pix00 = pix{jj};
                if sum(xMap(pix00))>0 && act0(jj)>0
                    oMap(pix00) = 1;
                end
            end
            d0x = cat(3,d0+oMap/2,d0,d0);
        end
        
        % boundaries
        bdMap00 = zeros(H,W);
        for jj=1:numel(bd)
            pix00 = pix{jj};
            if sum(xMap(pix00))>0
                bd0 = bd{jj};
                if nn==1
                    if act0(jj)>0
                        for kk=1:numel(bd0)
                            %xy = bd0{kk};
                            %xyi = sub2ind([H,W],xy(:,1),xy(:,2));
                            %bdMap00(xyi) = 1;
                        end
                    end
                else
                    for kk=1:numel(bd0)
                        xy = bd0{kk};
                        xyi = sub2ind([H,W],xy(:,1),xy(:,2));
                        bdMap00(xyi) = 1;
                    end
                end
            end
        end
        bdMap00a = cat(3,bdMap00,bdMap00,bdMap00);
        d0x(bdMap00a>0) = 0;
        d0x(:,:,3) = d0x(:,:,3)+bdMap00*0.5;
        d0xSel = d0x(rgh,rgw,:);
        
        ftNow.(resAll.mthdLst{nn}) = d0xSel;
    end
    
    % save figures
    fn = fieldnames(ftNow);
    for nn=1:numel(ftypes)
        ft0 = ftypes{nn};
        for ii=1:numel(fn)
            f0 = [pOut,filesep,fn{ii},'_frame_',num2str(tt),'.',ft0];
            x0 = ftNow.(fn{ii});
            %zzshow(x0);
            x0rs = imresize(double(x0),[150,150],'nearest');
            imwrite(x0rs,f0);
            %imwrite(double(x0),f0);
        end
    end
    fxx{ee} = ftNow;
end
















