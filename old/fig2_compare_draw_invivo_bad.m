% in vivo data with different methods
load('greenFireBlue.mat')
[folderDat,fDat] = runCfg();

folderRes = 'D:\neuro_WORK\glia_kira\projects\x_paper\';
outName = 'fig2';
fRes = [folderRes,fDat,'.mat'];
resAll = load(fRes);

fdat = [folderDat,fDat,'.tif'];
dat = io.readTiffSeq(fdat);
dat = dat./max(dat(:));
[H,W,T] = size(dat);

F0 = min(movmean(dat,50,3),[],3);

ftypes = {'png','svg','fig'};
for ii=1:numel(ftypes)
    ft0 = ftypes{ii};
    pOut = [folderRes,outName,filesep,ft0,filesep,fDat];
    if ~exist(pOut,'file')
        mkdir(pOut);
    end
end

%% draw some frames
visFig = 'on';
% ftypes = [];
ftypes = {'png'};
sz = [250 250];
% sz = [H,W]/3;

trg = 1450;
% trg = 1440:5:1460;
hrg = 101:300;
wrg = 31:230;
% hrg = [1,H];
% wrg = [1,W];

% sz = [numel(hrg),numel(wrg)];

xMap = zeros(H,W);
xMap(hrg,wrg) = 1;

rng(8)
colLow = [0 0 1];
colHigh = [1 1 0];

fxx = cell(0);

for ee=1:numel(trg)
    tt = trg(ee);
    fprintf('Frame %d ===== \n',tt)
    d0Org = dat(:,:,tt);
    d0 = dat(:,:,tt)-F0;
    
    % raw data
    ftNow = [];
    %ftNow.raw = xshowSingle(d0Org,'Raw',visFig); xlim(wrg); ylim(hrg);
    ftNow.df = xshowSingle(d0,'dF',sz,visFig); xlim([wrg(1),wrg(end)]); ylim([hrg(1),hrg(end)]);
    colormap(ftNow.df,greenFireBlue/255);
    %colormap(ftNow.df,'parula')
    caxis([0,1])
    
    % methods
    %for nn=1
    for nn=1:numel(resAll.mthdLst)
        bd = resAll.bdLst{nn};
        act = resAll.actTimeLst{nn};
        act0 = act(:,tt);
        pix = resAll.pixLst{nn};
        
        % regions
        if nn==1
            ov = resAll.ovLst{1};
            ov0 = ov.frame{tt};
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
            oMap = zeros(H,W);
            for jj=1:numel(bd)
                pix00 = pix{jj};
                if sum(xMap(pix00))>0 && act0(jj)>0
                    oMap(pix00) = 1;
                end
            end
            d0x = cat(3,d0+oMap/2,d0,d0);
            %d0x = d0;
        end
        f1 = xshowSingle(d0x,resAll.mthdLst{nn},sz,visFig);
        xlim([wrg(1),wrg(end)]); ylim([hrg(1),hrg(end)]);
        
        % boundaries
        for jj=1:numel(bd)
            pix00 = pix{jj};
            if sum(xMap(pix00))>0
                bd0 = bd{jj};
                if nn==1
                    if act0(jj)>0
                        for kk=1:numel(bd0)
                            xy = bd0{kk};
                            patch('XData',xy(:,2),'YData',xy(:,1),'FaceColor','none','EdgeColor',colLow*0.5);
                        end
                    end
                else
                    for kk=1:numel(bd0)
                        xy = bd0{kk};
                        if act0(jj)>0
                            patch('XData',xy(:,2),'YData',xy(:,1),'FaceColor','none','EdgeColor',colLow*0.5);
                        else
                            patch('XData',xy(:,2),'YData',xy(:,1),'FaceColor','none','EdgeColor',colLow*0.5);
                        end
                    end
                end
            end
        end
        ftNow.(resAll.mthdLst{nn}) = f1;
    end
    
    % save figures
    fn = fieldnames(ftNow);
    for nn=1:numel(ftypes)
        ft0 = ftypes{nn};
        for ii=1:numel(fn)
            f0 = [folderRes,outName,filesep,ft0,filesep,fDat,filesep,'Frame_',num2str(tt),'_',fn{ii},'.',ft0];
            x0 = ftNow.(fn{ii});
            switch ft0
                case 'png'
                    print(x0,'-dpng',f0,'-r800');
                case 'svg'
                    print(x0,'-painters','-dsvg',f0,'-r800');
                case 'fig'
                    savefig(x0,f0);
            end
        end
    end
    fxx{ee} = ftNow;
end

%% combine figures
gaph = 5;
gapw = 5;
h = sz(1);
w = sz(2);
nFrame = numel(fxx);
nMthd = numel(fieldnames(ftNow));

if 1
    figxx = figure;
    hFig = nFrame*h+(nFrame-1)*gaph;
    wFig = nMthd*w+(nMthd-1)*gapw;
    figxx.Position = [0 0 wFig hFig];
    
    mthdAll = [{'df'},resAll.mthdLst];
    
    for ii=1:nFrame
        ftNow = fxx{ii};
        fprintf('%d\n',ii)
        for jj=1:nMthd
            dh00 = (nFrame-ii)*h+(nFrame-ii)*gaph;
            dw00 = (jj-1)*w+(jj-1)*gapw;
            x00 = ftNow.(mthdAll{jj});
            ax00 = findobj(x00,'type','axes');
            bx00 = copyobj(ax00,figxx);
            bx00.Units = 'pixels';
            bx00.Position = [dw00,dh00,w,h];
        end
    end
    
    f0 = [folderRes,filesep,outName,filesep,fDat,'.png'];
    print(figxx,'-dpng',f0,'-r800');
    
    %f0 = [folderRes,filesep,outName,filesep,fDat,'1.svg'];
    %print(figxx,'-dsvg',f0,'-r800');
    % print(fxx,'-painters','-dsvg',f0,'-r800');
    % print(fxx,'-painters','-dpdf',f0,'-r800','-bestfit');
end

% export, per method
if 0
    fn = resAll.mthdLst;
    hFig = h;
    wFig = nFrame*w+(nFrame-1)*gapw;
    
    for nn=1:numel(fn)
        fprintf('%d\n',nn)
        figxx = figure;
        figxx.Position = [0 0 wFig hFig];
        for ii=1:nFrame
            x00 = fxx{ii}.(fn{nn});
            dh00 = 0;
            dw00 = (ii-1)*w+(ii-1)*gapw;
            ax00 = findobj(x00,'type','axes');
            bx00 = copyobj(ax00,figxx);
            bx00.Units = 'pixels';
            bx00.Position = [dw00,dh00,w,h];
        end
        % f0 = [folderRes,outName,filesep,fDat,'.png'];
        % print(figxx,'-dpng',f0,'-r800');
        f0 = [folderRes,filesep,outName,filesep,fDat,'_',fn{nn},'.svg'];
        print(figxx,'-dsvg',f0,'-r800');
    end
end















