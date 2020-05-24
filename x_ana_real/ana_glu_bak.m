% analyze results for glutamate data

folderTop = 'D:\OneDrive\projects\glia_kira\tmp\disser\transmitter\';

imgLst = {...
    'gfap-120916-slice3-Baseline-012_reg',...
    'gfap-122616-slice1-baseline2-006-channel1_reg',...
    'gfap-122616-slice1-baseline2-006-channel1_2_reg',...
    'gfap-122616-slice1-baseline-005_channel1_reg',...
    'hsyn-102816-Slice1-ACSF-001_reg',...
    'hsyn-102816-Slice1-ACSF-Baseline-006_reg',...
    'hsyn-111016-Slice1-ACSF-003_reg'
    };

% lblLst = [1,1,1,1,2,2,2];

ftsLst = cell(1);
evtLst = cell(1);
szVec = zeros(1,3);

nImg = numel(imgLst);
% circ = cell(2,1);
% incArea = cell(2,1);
% decArea = cell(2,1);
% incArea1 = cell(2,1);
% decArea1 = cell(2,1);


%% read results
for nn = 1:numel(imgLst)    
    disp(nn)
    
    % read data
    resCur = load([folderTop,imgLst{nn},'\',imgLst{nn},'_aqua.mat']);
    res = resCur.res;
%     nEvtCur = numel(res.evt);
%     xArea = res.fts.basic.area';
%     xDuration = res.fts.curve.width55';
%     datMean = mean(double(res.datOrg),3)/65535;
    [H,W,T] = size(res.datOrg);
    
%     % features
%     xDynamic = sum(res.fts.propagation.propGrowOverall,2);
%     idxStatic = find(xDynamic==0);
%     idxDynamic = find(xDynamic>0);
%     [~,idx00] = sort(res.fts.loc.t0(idxDynamic));
%     idxDynamic = idxDynamic(idx00);
%     nDynamic = sum(xDynamic>0);
    
%     circ{lblLst(nn)} = [circ{lblLst(nn)},res.fts.basic.circMetric];  
    ftsLst{nn} = res.fts;
    evtLst{nn} = res.evt;
    szVec(nn,:) = [H,W,T];
    
%     % area incrase and decrease
%     inc0 = nan(1,nEvtCur);
%     dec0 = nan(1,nEvtCur);
%     for ii=1:nEvtCur
%         aAll = res.fts.propagation.areaFrame{ii};
%         a0 = aAll(:,2); a0 = a0(a0>0); a1 = a0;
%         [amax,tmax] = max(a1);
%         inc0(ii) = amax/tmax;
%         dec0(ii) = amax/(numel(a1)-tmax+1);        
%     end    
%     incArea{lblLst(nn)} = [incArea{lblLst(nn)},inc0];
%     decArea{lblLst(nn)} = [decArea{lblLst(nn)},dec0];
    
%     % only with dynamic events
%     inc0a = inc0(idxDynamic);
%     dec0a = dec0(idxDynamic);
%     incArea1{lblLst(nn)} = [incArea1{lblLst(nn)},inc0a];
%     decArea1{lblLst(nn)} = [decArea1{lblLst(nn)},dec0a];
end


%%
incLst = cell(1);
decLst = cell(1);
areaLst = cell(1);
circLst = cell(1);
periLst = cell(1);

for nn = 1:numel(imgLst)
    fts = ftsLst{nn};
    nEvtCur = numel(evtLst{nn});
    H0 = szVec(nn,1);
    W0 = szVec(nn,2);
    T0 = szVec(nn,3);
    
    inc0 = [];
    dec0 = [];
    area0 = [];
    circ0 = [];
    peri0 = [];
    
    for ii=1:nEvtCur
        % size per frame
        pix0 = evtLst{nn}{ii};
        [h0,w0,t0] = ind2sub([H0,W0,T0],pix0);
        
        hw0 = sub2ind([H0,W0],h0,w0);
        map0 = zeros(H0,W0);
        map0(hw0) = 1;
        map0 = bwareaopen(map0,4);
        
        area0x = sum(map0(:));
        tmp = regionprops(map0,'Perimeter');
        peri0x = tmp.Perimeter;
        circ0x = (peri0x.^2)/(4*pi*area0x);
        
        area0(ii) = area0x;
        circ0(ii) = circ0x;
        peri0(ii) = peri0x;
        
        % all size changes
        tAll = max(t0)-min(t0)+1;
        a0 = zeros(1,tAll);
        if max(t0)==min(t0)
            continue
        end
        for tt=1:tAll
            a0(tt) = sum(t0==(min(t0)+tt-1));
        end
        dif0 = a0(1:end-1)-a0(2:end);
        inc0 = [inc0,dif0(dif0<0)];
        dec0 = [dec0,dif0(dif0>0)];
    end
    incLst{nn} = inc0;
    decLst{nn} = dec0;
    areaLst{nn} = area0;
    circLst{nn} = circ0;
    periLst{nn} = peri0;
end


%% analysis
areaGp1 = cell2mat(areaLst(1:4));
areaGp2 = cell2mat(areaLst(5:7));

incGp1 = abs(cell2mat(incLst(1:4)));
incGp2 = abs(cell2mat(incLst(5:7)));

decGp1 = abs(cell2mat(decLst(1:4)));
decGp2 = abs(cell2mat(decLst(5:7)));

decGp1Big = decGp1(areaGp1>200);
decGp2Big = decGp2(areaGp2>200);

circGp1 = cell2mat(circLst(1:4));
circGp2 = cell2mat(circLst(5:7));

figure;scatter(log10(areaGp1+1),circGp1);
hold on
scatter(log10(areaGp2+1),circGp2);

circGp1Big = circGp1(areaGp1>200);
circGp2Big = circGp2(areaGp2>200);


%% circularity
circ = {circGp1Big,circGp2Big};
y = [circ{1},circ{2}];
x = [zeros(1,numel(circ{1})),ones(1,numel(circ{2}))];
figure; 
h = notBoxPlot(y,x);
d = [h.data];
set(d, 'markerfacecolor', [0.4,1,0.4], 'color', [0,0.4,0]);
set(d, 'markersize', 2);
set(gca,'xticklabel',{[]})
ylim([0,10])
[~,pCirc] = ttest2(circ{1},circ{2});


%% increse of area per frame
incArea = {incGp1,incGp2};

y = [incArea{1},incArea{2}];
x = [zeros(1,numel(incArea{1})),ones(1,numel(incArea{2}))];
figure; 
h = notBoxPlot(y,x);
d = [h.data];
set(d, 'markerfacecolor', [0.4,1,0.4], 'color', [0,0.4,0]);
set(d, 'markersize', 2);
set(gca,'xticklabel',{[]})
% ylim([-100,200])
[~,pInc] = ttest2(incArea{1},incArea{2});


%% decrease of area per frame
decArea = {decGp1,decGp2};

y = [decArea{1},decArea{2}];
x = [zeros(1,numel(decArea{1})),ones(1,numel(decArea{2}))];

figure; 
h = notBoxPlot(y,x);
d = [h.data];
set(d, 'markerfacecolor', [0.4,1,0.4], 'color', [0,0.4,0]);
set(d, 'markersize', 2);
set(gca,'xticklabel',{[]})
% ylim([-500,2000])
[~,pDec] = ttest2(decArea{1},decArea{2});





