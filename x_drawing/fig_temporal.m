%% figures for super voxels

[dat,datSel,p] = pltPrep3D();

x1a = [14,15,38,42,35,26,13,26,30,24]; 
y1a = [77,67,18,164,27,45,101,101,124,148];

x1c = [14,38,42,26,30]; 
y1c = [77,18,164,45,124];

x1b = 30;
y1b = 124;


%% curves
f = showCurves(x1a,y1a,dat,p.colxPixReg);
print(f,'flow_seed_curve_10.svg','-dsvg','-r800');
f = showCurves(x1b,y1b,dat,p.colxPixReg);
print(f,'flow_seed_curve_1.svg','-dsvg','-r800');
f = showCurves(x1c,y1c,dat,p.colxPixReg);
print(f,'flow_seed_curve_5.svg','-dsvg','-r800');


%% finding peaks
% colorful seeds
px = p;
[px.bdLst,px.actFrame] = getRegInfo(x1a,y1a,p.msk);
px.mskSel = p.msk.*0;
f = pltFlowCommon(datSel,px,'peaks');
export_fig(f,'flow_seeds_filled_active.png','-r800','-transparent');
px.actFrame = px.actFrame*0;
f = pltFlowCommon(datSel,px,'peaks');
export_fig(f,'flow_seeds_borders.png','-r800','-transparent');

% colorful seeds, but less
px = p;
[px.bdLst,px.actFrame] = getRegInfo(x1c,y1c,p.msk);
px.mskSel = p.msk.*0;
% px.colxPixReg = ones(100,3)*0.4;
f = pltFlowCommon(datSel,px,'peaks');
export_fig(f,'flow_seeds_filled_active_less.png','-r800','-transparent');

% gray seeds
px = p;
[px.bdLst,px.actFrame] = getRegInfo(x1a,y1a,p.msk);
px.mskSel = p.msk.*0;
px.colxPixReg = ones(100,3)*0.4;
f = pltFlowCommon(datSel,px,'peaks');
export_fig(f,'flow_seeds_filled_active_gray.png','-r800','-transparent');

% gray seeds, but less
px = p;
[px.bdLst,px.actFrame] = getRegInfo(x1c,y1c,p.msk);
px.mskSel = p.msk.*0;
px.colxPixReg = ones(100,3)*0.4;
f = pltFlowCommon(datSel,px,'peaks');
export_fig(f,'flow_seeds_filled_active_gray_less.png','-r800','-transparent');

% highlight one seed, also show others
px = p;
[px.bdLst,px.actFrame] = getRegInfo(x1a,y1a,p.msk);
px.mskSel = p.msk.*0;
xx = px.actFrame*0;
xx(9,:) = 1;
px.actFrame = xx;
f = pltFlowCommon(datSel,px,'peaks');
export_fig(f,'flow_one_seed_filled_all_with_others.png','-r800','-transparent');

% highlight one seed
px = p;
[px.bdLst,px.actFrame] = getRegInfo(x1b,y1b,p.msk);
px.colxPixReg = [1 0 0];
px.mskSel = p.msk.*0;
f = pltFlowCommon(datSel,px,'peaks');
export_fig(f,'flow_one_seed_filled_active.png','-r800','-transparent');
px.actFrame = ones(size(px.actFrame));
f = pltFlowCommon(datSel,px,'peaks');
export_fig(f,'flow_one_seed_filled_all.png','-r800','-transparent');


%% super voxels to super events
px = p;
f = pltFlowSvGrouping(datSel,px,'none');
export_fig(f,'flow_super_voxel_simple_groups_none.png','-r800','-transparent');
f = pltFlowSvGrouping(datSel,px,'one');
export_fig(f,'flow_super_voxel_simple_groups_one.png','-r800','-transparent');
f = pltFlowSvGrouping(datSel,px,'two');
export_fig(f,'flow_super_voxel_simple_groups_two.png','-r800','-transparent');

px = p;
f = pltFlowCommon(datSel,px,'sv');
export_fig(f,'flow_super_voxels_in_colors.png','-r800','-transparent');
f = pltFlowCommon(datSel,px,'sv_node');
export_fig(f,'flow_super_voxels_node.png','-r800','-transparent');
f = pltFlowCommon(datSel,px,'sv_node_a');
export_fig(f,'flow_super_voxels_node_one_group.png','-r800','-transparent');
f = pltFlowCommon(datSel,px,'sv_node_grp');
export_fig(f,'flow_super_voxels_node_two_groups.png','-r800','-transparent');

px = p;
mskSe = p.msk;
mskSe(mskSe==1 | mskSe==2) = 1;
px.msk = mskSe;
px.mskSel = mskSe;
f = pltFlowCommon(datSel,px,'se');
export_fig(f,'flow_super_events_both.png','-r800','-transparent');


%% misc
% cleaned raw data
p1r = p;
p1r.mskSel = p.msk.*0;
f = pltFlowCommon(datSel,p1r,'single_evt');
export_fig(f,'cleaned_raw.png','-r800','-transparent');

% 2D map of the super event
dat1Avg = mean(p.dat1,3);
dat1Avg = dat1Avg/max(dat1Avg(:));
eMsk = p.L1>0;
cLayer = cat(3,eMsk*0,eMsk*0,eMsk);
L1 = cLayer/4+sqrt(dat1Avg)/2;
f = figure;
image(L1);
axis image
axis off
export_fig(f,'flow_region_2D_map.png','-r800','-transparent');














