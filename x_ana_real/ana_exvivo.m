% analyze results for ex vivo data
% heterogeneities among single astrocytes
% similar to some subfigues in fig 3 of the AQuA paper

folderTop = 'D:/OneDrive/projects/glia_kira/tmp/disser/exvivo/';

imgLst = {...
    'FilteredNRMCCyto16m_slice1_baseline1_L2 3-001cycle1channel1',...
    'FilteredNRMCCyto16m_slice1_baseline2_L2 3-002cycle1channel1',...
    'FilteredNRMCCyto16m_slice2_Baseline1_L2 3-007cycle1channel1',...
    'FilteredNRMCCyto16m_slice2_Baseline2_L2 3-008cycle1channel1',...
    'FilteredNRMCCyto16m_slice2_Baseline3_L2 3-009cycle1channel1'...
    };


%% gather events and features
% static-away-toward, min-dist-to-soma, start-dist-to-soma
% area, duration

xArea = [];
xDuration = [];
xAway = [];
xToward = [];
xMinDistSoma = [];
xStartDistSoma = [];

for ii=1:numel(imgLst)
    disp(ii);
    resCur = load([folderTop,imgLst{ii},'/',imgLst{ii},'_aqua.mat']);
    res = resCur.res;
    nEvtCur = numel(res.evt);
    
    xArea = [xArea;res.fts.basic.area'];
    xDuration = [xDuration;res.fts.curve.width55'];
    
    xMinDistSoma = [xMinDistSoma;res.fts.region.landmarkDist.distMin];
    
    xAwayCur = res.fts.region.landmarkDir.chgAway;
    xTowardCur = res.fts.region.landmarkDir.chgToward;
    xAway = [xAway;xAwayCur];
    xToward = [xToward;xTowardCur];
    
    xStartDistSomaCur = nan(nEvtCur,1);
    for jj=1:nEvtCur
        x0 = res.fts.region.landmarkDist.distPerFrame{jj};
        if ~isempty(x0)
            xStartDistSomaCur(jj) = x0(1);
        end
    end
    xStartDistSoma = [xStartDistSoma;xStartDistSomaCur];
end

%%
isGood = xArea>=16;

xAreaFilter = xArea(isGood);
xDurationFilter = xDuration(isGood);
xAwayFilter = xAway(isGood);
xTowardFilter = xToward(isGood);
xMinDistSomaFilter = xMinDistSoma(isGood);
xStartDistSomaFilter = xStartDistSoma(isGood);


%% min-dist to soma vs. number of events (static, non-static)
minDistMax = max(xMinDistSomaFilter);
nSeg = 10;
nStatic = zeros(nSeg,1);
nDynamic = zeros(nSeg,1);
for kk=1:nSeg
    % distance range
    d0 = (kk-1)*minDistMax/nSeg;
    d1 = kk*minDistMax/nSeg;
    d01 = xMinDistSomaFilter>=d0 & xMinDistSomaFilter<d1;
    
    % event type in this range
    nStatic(kk) = sum( (xAwayFilter==0 & xTowardFilter==0) & d01);
    nDynamic(kk) = sum( (xAwayFilter>0 | xTowardFilter>0) & d01);
end

% figure;plot(nStatic/sum(nStatic));hold on;plot(nDynamic/sum(nDynamic))
figure; b = bar([nStatic,nDynamic]);legend({'Static','Dynamic'})
b(1).FaceColor = [.2 .6 .2];
b(2).FaceColor = [.5 .5 .5];


%% start-dist to soma vs. mean area/duration (away, toward)
% use <50% and >50% max-start-dist
minDistMax = max(xStartDistSomaFilter);

isAway = xAwayFilter./xTowardFilter > 2;
isToward = xTowardFilter./xAwayFilter > 2;

nSeg = 10;

awayArea = zeros(nSeg,1);
towardArea = zeros(nSeg,1);
awayDur = zeros(nSeg,1);
towardDur = zeros(nSeg,1);

awayAreaLst = cell(nSeg,1);
towardAreaLst = cell(nSeg,1);
awayDurLst = cell(nSeg,1);
towardDurLst = cell(nSeg,1);

for kk=1:nSeg
    % distance range
    d0 = (kk-1)*minDistMax/nSeg;
    d1 = kk*minDistMax/nSeg;
    d01 = xStartDistSomaFilter>=d0 & xStartDistSomaFilter<d1;
    
    % event type in this range
    awayAreaLst{kk} = xAreaFilter(isAway & d01);
    towardAreaLst{kk} = xAreaFilter(isToward & d01);    
    awayArea(kk) = mean(xAreaFilter(isAway & d01));
    towardArea(kk) = mean(xAreaFilter(isToward & d01));
    
    awayDurLst{kk} = xDurationFilter(isAway & d01);
    towardDurLst{kk} = xDurationFilter(isToward & d01);
    awayDur(kk) = mean(xDurationFilter(isAway & d01));
    towardDur(kk) = mean(xDurationFilter(isToward & d01));
end

figure;bar([awayArea,towardArea]);legend({'Away','Toward'})
figure;bar([awayDur,towardDur]);legend({'Away','Toward'})


%% p values
% area
awayArea0 = cell2mat(awayAreaLst(1:nSeg/2));
towardArea0 = cell2mat(towardAreaLst(1:nSeg/2));

awayArea1 = cell2mat(awayAreaLst(nSeg/2+1:end));
towardArea1 = cell2mat(towardAreaLst(nSeg/2+1:end));

[~,p0] = ttest2(awayArea0,towardArea0);
% [~,p0] = ttest2(awayArea0,towardArea0,'Vartype','unequal');
dat = [mean(awayArea0),mean(towardArea0)];
s0 = [std(awayArea0)/sqrt(numel(awayArea0)),std(towardArea0)/sqrt(numel(towardArea0))];
figure; bar(dat); hold on; er = errorbar(1:2,dat,s0); er.Color = [0 0 0]; er.LineStyle = 'none';

% duration
awayDur0 = cell2mat(awayDurLst(1:nSeg/2));
towardDur0 = cell2mat(towardDurLst(1:nSeg/2));

awayDur1 = cell2mat(awayDurLst(nSeg/2+1:end));
towardDur1 = cell2mat(towardDurLst(nSeg/2+1:end));

[~,p1] = ttest2(awayDur0,towardDur0);
% [~,p1] = ttest2(awayDur0,towardDur0,'Vartype','unequal');
dat = [mean(awayDur0),mean(towardDur0)];
s0 = [std(awayDur0)/sqrt(numel(awayDur0)),std(towardDur0)/sqrt(numel(towardDur0))];
figure; bar(dat); hold on; er = errorbar(1:2,dat,s0); er.Color = [0 0 0]; er.LineStyle = 'none';




