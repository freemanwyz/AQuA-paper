%% figure 1b flow chart 3D

% data
folderTop = 'D:\OneDrive\projects\glia_kira\se_aqua\';
folderAnno = [folderTop,'x_paper\labels\'];
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
p.bdLst = [];
p.actFrame = [];
p.colxPixReg = lines;
p.colEvt = [0 0 1;1 0 0;1 0.5 0];
p.curveCol = 'curve'; % curve: one curve, one color, from colxPixReg. peak: peak color from colEvt


%% raw data
ff_raw = pltFlowRaw(datSel);
export_fig(ff_raw,'fig_raw.png','-r800','-transparent');


%% single event
p0a = p;
msk0a = msk==1;
p0a.mskSel = msk.*(msk0a);
x0a = [38 28 16 13 18]; y0a = [19 42 58 77 94];
[p0a.bdLst,p0a.actFrame] = getRegInfo(x0a,y0a,msk0a);
ff0a = pltFlowCommon(datSel,p0a,'single_evt');
ff0a_c = showCurves(x0a,y0a,dat,p0a.colxPixReg);


%% temporal separation
p0b = p;
msk0b = (msk==1)|(msk==3);
p0b.mskSel = msk.*(msk0b);
x0b = 14; y0b = 77;
[p0b.bdLst,p0b.actFrame] = getRegInfo(x0b,y0b,p0b.mskSel);
% p0b.pixMap = sum(msk==1,3)>0;
% p0a.colxPixReg(:,1:2) = p0a.colxPixReg(:,1:2)/5;
p0b.colxPixReg = [1 0 0];
p0b.curveCol = 'peak';
ff0b = pltFlowCommon(datSel,p0b,'two_evts_time');
ff0b_c = showCurves(x0b,y0b,dat,p0b.colxPixReg);


%% spatial separation
p0c = p;
msk0c = (msk==1)|(msk==2);
p0c.mskSel = msk.*(msk0c);
x0c = [42,39]; y0c = [164,18];
[p0c.bdLst,p0c.actFrame] = getRegInfo(x0c,y0c,msk0c);
x1 = sum(msk1==1,3)>0;
x2 = sum(msk1==2,3)>0;
x1(x2>0) = 0;  % events 1 and 2 has some spatial overlapping
p0c.colxPixReg = [1 0 0;0 0 1];
ff0c = pltFlowCommon(datSel,p0c,'two_evts_spatial');
ff0c_c = showCurves(x0c,y0c,dat,p0c.colxPixReg);


%% finding peaks
p1r = p;
p1r.mskSel = msk.*0;
ff1r = pltFlowCommon(datSel,p1r,'single_evt');

p1a = p;
x1a = [14,15,38,42,35,26,13,26,30,24]; y1a = [77,67,18,164,27,45,101,101,124,148];

[p1a.bdLst,p1a.actFrame] = getRegInfo(x1a,y1a,msk);
p1a.mskSel = msk.*0;
ff1a = pltFlowCommon(datSel,p1a,'peaks');

p1a0 = p1a;
p1a0.actFrame = p1a0.actFrame*0;
ff1a0 = pltFlowCommon(datSel,p1a0,'peaks');


%% 2D map of super voxels
dat1Avg = mean(dat1,3);
dat1Avg = dat1Avg/max(dat1Avg(:));
eMsk = p.L1>0;
cLayer = cat(3,eMsk*0,eMsk*0,eMsk);
L1 = cLayer/4+sqrt(dat1Avg)/2;
ff_flow_sv_2d = figure;
image(L1);
axis image
axis off


%% super voxels to super events
p1 = p;
ff1b = pltFlowCommon(datSel,p1,'sv');
ff1c = pltFlowCommon(datSel,p1,'sv_node'); %ff1c.Color = 'w';
ff1c1 = pltFlowCommon(datSel,p1,'sv_node_a');
ff1d = pltFlowCommon(datSel,p1,'sv_node_grp'); %ff1d.Color = 'w';

p2 = p;
mskSe = msk;
mskSe(mskSe==1 | mskSe==2) = 1;
p2.msk = mskSe;
p2.mskSel = mskSe;
ff1e = pltFlowCommon(datSel,p2,'se');


%% three events
ff1f = figure;
axRaw = axes(ff1f);
[H0,W0,T0] = size(datSel);

for ii=1:T0
    % raw data and events
    img0 = datSel(:,:,ii);
    msk0 = msk(:,:,ii);
    Lx = cat(3,(msk0==2)+(msk0==3),0.5*(msk0==3),msk0==1);
    imgx = img0+Lx;
    alphaMap = (msk0>0)*0.5+0.05;
    addSliceRGB(imgx,-ii,axRaw,alphaMap);
end

pbaspect([W0 H0 W0*4])
axRaw.CameraUpVector = [0 1 0];
campos([1158,596 52]);
axis off


%% single event, no pixels
p3 = p;
msk0a = 1*(msk==1);
p3.mskSel = msk0a;
p3.pixMap = sum(msk==1,3)>0;
ff2 = pltFlowCommon(datSel,p3,'single_evt');
pbaspect([57 179 400])

% ff2_fp = pltFootprint(datSel,p3);
% pbaspect([57 179 1])
% campos([75,100,50])
% p3.pixMap = [];
% ff2_oneevt = pltFlowCommon(datSel,p3,'single_evt');

x0a = [38 28 16 13 18]; y0a = [19 42 58 77 94];
ff2_c = showCurves(x0a,y0a,dat,p3.colxPixReg);


%% output
export_fig(ff0a,'fig1b_a_single.png','-r800','-transparent');
export_fig(ff0b,'fig1b_a_temporal.png','-r800','-transparent');
export_fig(ff0c,'fig1b_a_spatial.png','-r800','-transparent');
print(ff0a_c,'rule_single_c.svg','-dsvg','-r800');
print(ff0b_c,'rule_temporal_c.svg','-dsvg','-r800');
print(ff0c_c,'rule_spatial_c.svg','-dsvg','-r800');

export_fig(ff1r,'fig1b_b_raw.png','-r800','-transparent');
export_fig(ff1a,'fig1b_b_peaks.png','-r800','-transparent');
export_fig(ff1a0,'flow_sv_seeds.png','-r800','-transparent');
export_fig(ff1b,'fig1b_b_sv.png','-r800','-transparent');
export_fig(ff1c,'fig1b_b_sv_node.png','-r800','-transparent');
export_fig(ff1c1,'fig1b_b_sv_node_1.png','-r800','-transparent');
export_fig(ff1d,'fig1b_b_sv_node_grp.png','-r800','-transparent');
export_fig(ff1e,'fig1b_b_se.png','-r800','-transparent');
export_fig(ff1f,'fig1b_b_evt.png','-r800','-transparent');

export_fig(ff2,'fig1c_evt.png','-r800','-transparent');
% export_fig(ff2_fp,'fig1c_footprint.png','-r800','-transparent');
% export_fig(ff2_oneevt,'fig1c_oneevt.png','-r800','-transparent');
print(ff2_c,'feature_evt_c.svg','-dsvg','-r800');

export_fig(ff_flow_sv_2d,'ff_flow_sv_2d.png','-r800','-transparent');



