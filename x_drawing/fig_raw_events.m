%% flowchart 3D figures and curves
[dat,datSel,p] = pltPrep3D();
f = pltFlowRaw(datSel);
export_fig(f,'raw_data.png','-r800','-transparent');


%% three events
f = figure;
axRaw = axes(f);
[H0,W0,T0] = size(datSel);

for ii=1:T0
    % raw data and events
    img0 = datSel(:,:,ii);
    msk0 = p.msk(:,:,ii);
    Lx = cat(3,(msk0==2)+(msk0==3),0.5*(msk0==3),msk0==1);
    imgx = img0+Lx;
    alphaMap = (msk0>0)*0.5+0.05;
    addSliceRGB(imgx,-ii,axRaw,alphaMap);
end

pbaspect([W0 H0 W0*4])
axRaw.CameraUpVector = [0 1 0];
campos([1158,596 52]);
axis off

export_fig(f,'three_events.png','-r800','-transparent');


%% single event, no pixels
p3 = p;
msk0a = 1*(p.msk==1);
p3.mskSel = msk0a;
p3.pixMap = sum(p.msk==1,3)>0;
ff2 = pltFlowCommon(datSel,p3,'single_evt');
pbaspect([57 179 400])

x0a = [38 28 16 13 18]; y0a = [19 42 58 77 94];
ff2_c = showCurves(x0a,y0a,dat,p3.colxPixReg);

export_fig(ff2,'single_event.png','-r800','-transparent');
print(ff2_c,'curves_pixels.svg','-dsvg','-r800');










