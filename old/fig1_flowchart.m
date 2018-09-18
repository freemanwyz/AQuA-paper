%% read data and results
load('greenFireBlue.mat')

folderDat = 'D:\neuro_WORK\glia_kira\raw_proc\paper_exvivo\';
fDat = 'FilteredNRMCCyto16m_slice3_Baseline3_L2 3-015cycle1channel1';

folderRes = 'D:\neuro_WORK\glia_kira\projects\x_paper\flowchart\ex_vivo_res\';
fRes = 'FilteredNRMCCyto16m_slice3_Baseline3_L2 3-015cycle1channel1_results';

dat = io.readTiffSeq([folderDat,fDat,'.tif']);
dat = sqrt(dat);
dat = dat/max(dat(:));
tmp = load([folderRes,fRes,'.mat']); res = tmp.res;

[H,W,T] = size(dat);

tVec = [166 172 178 180 184 188 190];
hrg = 141:380;
wrg = 161:400;

ov = res.ov;
% ovName = ov.keys;
% {'Events'                }
% {'None'                  }
% {'Step 1: active voxels' }
% {'Step 2: super voxels'  }
% {'Step 3a: super events' }
% {'Step 3b: events all'   }
% {'Step 4: events cleaned'}
% {'Step 5: events merged' }

outName = 'fig2';
ft0 = 'tiff';
folderOut = 'D:\neuro_WORK\glia_kira\projects\x_paper\';
pOut = [folderOut,outName,filesep,ft0,filesep,fDat];
if ~exist(pOut,'file')
    mkdir(pOut);
end

%% figures in each step
nFrames = numel(tVec);
% sz = [150,150];

% raw
for ii=1:nFrames
    t00 = tVec(ii);
    dat0 = dat(hrg,wrg,tVec(ii))*2;
    
    d0Int8 = round(dat0*255)+1;
    d0Int8(d0Int8>256) = 256;
    d0Int8(d0Int8<1) = 1;
    x = greenFireBlue(:,1); d0r = x(d0Int8);
    x = greenFireBlue(:,2); d0g = x(d0Int8);
    x = greenFireBlue(:,3); d0b = x(d0Int8);
    d0rgb = cat(3,d0r,d0g,d0b)/255;
    
    f0 = [pOut,filesep,'Frame_',num2str(t00),'_raw','.',ft0];
    imwrite(double(d0rgb),f0);
    %figxx = xshowSingle(d0rgb,'',sz);
    %print(figxx,'-dsvg',f0,'-r800');
end

% fg and seeds
ovCur = ov('Step 1: active voxels');
lmLoc = res.lmLoc;
[ih,iw,it] = ind2sub(size(dat),lmLoc);
for ii=1:nFrames
    t00 = tVec(ii);
    dat0 = dat(hrg,wrg,t00)*2;
    
    % foreground
    ov0 = ovCur.frame{t00};
    tmpFg = zeros(H,W);
    for jj=1:numel(ov0.pix)
        tmpFg(ov0.pix{jj}) = 1;
    end
    tmpFg = tmpFg(hrg,wrg);
    
    % seeds
    xSel = it==t00;
    ih0 = ih(xSel);
    iw0 = iw(xSel);
    ihw0 = sub2ind([H,W],ih0,iw0);
    tmpSeed = zeros(H,W);
    tmpSeed(ihw0) = 1;
    tmpSeed = imdilate(tmpSeed,strel('square',3));
    tmpSeed = tmpSeed(hrg,wrg);
    
    % show
    dat0a = dat0;
    dat0a(tmpSeed>0) = 0;
    dat0b = cat(3,dat0a+tmpSeed,dat0a+tmpFg*0.3,dat0a);
    
    f0 = [pOut,filesep,'Frame_',num2str(t00),'_fgSeed','.',ft0];
    imwrite(double(dat0b),f0);    
end

% super voxels
ovCur = ov('Step 2: super voxels');
col0 = ovCur.col;
for ii=1:nFrames
    t00 = tVec(ii);
    dat0 = dat(hrg,wrg,t00)*2;
    
    % foreground
    ov0 = ovCur.frame{t00};
    rMap = zeros(H,W);
    gMap = zeros(H,W);
    bMap = zeros(H,W);
    for jj=1:numel(ov0.pix)
        col00 = col0(ov0.idx(jj),:);
        rMap(ov0.pix{jj}) = ov0.val{jj}*col00(1);
        gMap(ov0.pix{jj}) = ov0.val{jj}*col00(2);
        bMap(ov0.pix{jj}) = ov0.val{jj}*col00(3);
    end
    dat0b = cat(3,rMap,gMap,bMap);
    dat0b = dat0b(hrg,wrg,:);
    dat0b = dat0b/2+dat0;

    f0 = [pOut,filesep,'Frame_',num2str(t00),'_sv','.',ft0];
    imwrite(double(dat0b),f0); 
end

% super events
ovCur = ov('Step 3a: super events');
col0 = ovCur.col;
for ii=1:nFrames
    t00 = tVec(ii);
    dat0 = dat(hrg,wrg,t00)*2;
    
    % foreground
    ov0 = ovCur.frame{t00};
    rMap = zeros(H,W);
    gMap = zeros(H,W);
    bMap = zeros(H,W);
    for jj=1:numel(ov0.pix)
        col00 = col0(ov0.idx(jj),:);
        rMap(ov0.pix{jj}) = ov0.val{jj}*col00(1);
        gMap(ov0.pix{jj}) = ov0.val{jj}*col00(2);
        bMap(ov0.pix{jj}) = ov0.val{jj}*col00(3);
    end
    dat0b = cat(3,rMap,gMap,bMap);
    dat0b = dat0b(hrg,wrg,:);
    dat0b = dat0b/2+dat0;

    f0 = [pOut,filesep,'Frame_',num2str(t00),'_se','.',ft0];
    imwrite(double(dat0b),f0); 
end

% events
ovCur = ov('Step 3b: events all');
col0 = ovCur.col;
for ii=1:nFrames
    t00 = tVec(ii);
    dat0 = dat(hrg,wrg,t00)*2;
    
    % foreground
    ov0 = ovCur.frame{t00};
    rMap = zeros(H,W);
    gMap = zeros(H,W);
    bMap = zeros(H,W);
    for jj=1:numel(ov0.pix)
        col00 = col0(ov0.idx(jj),:);
        rMap(ov0.pix{jj}) = ov0.val{jj}*col00(1);
        gMap(ov0.pix{jj}) = ov0.val{jj}*col00(2);
        bMap(ov0.pix{jj}) = ov0.val{jj}*col00(3);
    end
    dat0b = cat(3,rMap,gMap,bMap);
    dat0b = dat0b(hrg,wrg,:);
    dat0b = dat0b/2+dat0;

    f0 = [pOut,filesep,'Frame_',num2str(t00),'_evt','.',ft0];
    imwrite(double(dat0b),f0);     
end
















