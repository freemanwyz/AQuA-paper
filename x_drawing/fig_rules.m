%% figure for rules
[dat,datSel,p] = pltPrep3D();


%% single event
px = p;
mskx = p.msk==1;
px.mskSel = p.msk.*(mskx);
x0a = [38 28 16 13 18]; 
y0a = [19 42 58 77 94];
[px.bdLst,px.actFrame] = getRegInfo(x0a,y0a,mskx);
f = pltFlowCommon(datSel,px,'single_evt');
f1 = showCurves(x0a,y0a,dat,px.colxPixReg);

export_fig(f,'rule_single_event.png','-r800','-transparent');
print(f1,'rule_single_event_curves.svg','-dsvg','-r800');


%% temporal separation
px = p;
mskx = (p.msk==1)|(p.msk==3);
px.mskSel = p.msk.*(mskx);
x0b = 14; 
y0b = 77;
[px.bdLst,px.actFrame] = getRegInfo(x0b,y0b,px.mskSel);
% p0b.pixMap = sum(msk==1,3)>0;
% p0a.colxPixReg(:,1:2) = p0a.colxPixReg(:,1:2)/5;
px.colxPixReg = [1 0 0];
px.curveCol = 'peak';
f = pltFlowCommon(datSel,px,'two_evts_time');
f1 = showCurves(x0b,y0b,dat,px.colxPixReg);

export_fig(f,'rule_temporal_separation.png','-r800','-transparent');
print(f1,'rule_temporal_separation_curves.svg','-dsvg','-r800');


%% spatial separation
px = p;
mskx = (p.msk==1)|(p.msk==2);
px.mskSel = p.msk.*(mskx);
x0c = [42,39]; 
y0c = [164,18];
[px.bdLst,px.actFrame] = getRegInfo(x0c,y0c,mskx);
x1 = sum(p.msk1==1,3)>0;
x2 = sum(p.msk1==2,3)>0;
x1(x2>0) = 0;  % events 1 and 2 has some spatial overlapping
px.colxPixReg = [1 0 0;0 0 1];
f = pltFlowCommon(datSel,px,'two_evts_spatial');
f1 = showCurves(x0c,y0c,dat,px.colxPixReg);

export_fig(f,'rule_spatial_separation.png','-r800','-transparent');
print(f1,'rule_spatial_separation_curves.svg','-dsvg','-r800');







