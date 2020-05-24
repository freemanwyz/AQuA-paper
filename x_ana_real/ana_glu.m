% analyze results for glutamate data

s2 = 0.466^2;

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

ftsLst = cell(1);
evtLst = cell(1);
szVec = zeros(1,3);
nImg = numel(imgLst);


%% read results
for nn = 1:numel(imgLst)    
    disp(nn)
    resCur = load([folderTop,imgLst{nn},'\',imgLst{nn},'_aqua.mat']);
    res = resCur.res;
    [H,W,T] = size(res.datOrg);

    ftsLst{nn} = res.fts;
    evtLst{nn} = res.evt;
    szVec(nn,:) = [H,W,T];
end


%% extract features
szBig = 200;

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
        map0x = zeros(H0,W0);
        map0x(hw0) = 1;
        map0x = bwareaopen(map0x,4);
        
        area0x = sum(map0x(:));
        tmp = regionprops(map0x,'Perimeter');
        peri0x = tmp.Perimeter;
        circ0x = (peri0x.^2)/(4*pi*area0x);
        
        area0(ii) = area0x;
        circ0(ii) = circ0x;
        peri0(ii) = peri0x;
        
        if area0x<szBig
            continue
        end
        
        % all size changes
        evtDur0x = max(t0)-min(t0)+1;
        a0x = zeros(1,evtDur0x);
        if max(t0)==min(t0)
            continue
        end
        for tt=1:evtDur0x
            a0x(tt) = sum(t0==(min(t0)+tt-1));
        end
        dif0x = a0x(1:end-1)-a0x(2:end);
        inc0 = [inc0,dif0x(dif0x<0)];
        dec0 = [dec0,dif0x(dif0x>0)];
    end
    incLst{nn} = inc0;
    decLst{nn} = dec0;
    areaLst{nn} = area0;
    circLst{nn} = circ0;
    periLst{nn} = peri0;
end


%% analysis
gp1 = 1:4;
gp2 = 5:7;

areaGp1 = cell2mat(areaLst(gp1));
areaGp2 = cell2mat(areaLst(gp2));

% area change rate
incGp1 = abs(cell2mat(incLst(gp1)));
incGp2 = abs(cell2mat(incLst(gp2)));

decGp1 = abs(cell2mat(decLst(gp1)));
decGp2 = abs(cell2mat(decLst(gp2)));

[~,pInc] = ttest2(incGp1,incGp2);
mean(incGp1)
mean(incGp2)

[~,pDec] = ttest2(decGp1,decGp2);
mean(decGp1)
mean(decGp2)

incGp1Log = log10(incGp1+1);
incGp2Log = log10(incGp2+1);
[~,pIncLog] = ttest2(incGp1Log,incGp2Log);

decGp1Log = log10(decGp1+1);
decGp2Log = log10(decGp2+1);
[~,pDecLog] = ttest2(decGp1Log,decGp2Log);

% circularity
circGp1 = cell2mat(circLst(gp1));
circGp2 = cell2mat(circLst(gp2));

figure;scatter(log10(areaGp1+1),circGp1);
hold on
scatter(log10(areaGp2+1),circGp2);

circGp1Big = circGp1(areaGp1>szBig);
circGp2Big = circGp2(areaGp2>szBig);

[~,pCirc] = ttest2(circGp1,circGp2);
mean(circGp1)
mean(circGp2)

[~,pCircBig] = ttest2(circGp1Big,circGp2Big);
mean(circGp1Big)
mean(circGp2Big)


%% circularity
circ = {circGp1Big,circGp2Big};
y = [circ{1},circ{2}];
x = [zeros(1,numel(circ{1})),ones(1,numel(circ{2}))];

violinplot(y,x)
set(gca,'xticklabel',{[]})
set(gca,'yticklabel',{[]})


%% increse of area per frame
incArea = {incGp1,incGp2};
y = [incArea{1},incArea{2}]*s2;
x = [zeros(1,numel(incArea{1})),ones(1,numel(incArea{2}))];
violinplot(y,x)
set(gca,'xticklabel',{[]})
set(gca,'yticklabel',{[]})

incArea = {incGp1Log,incGp2Log};
y = [incArea{1},incArea{2}]*s2;
x = [zeros(1,numel(incArea{1})),ones(1,numel(incArea{2}))];
violinplot(y,x)
set(gca,'xticklabel',{[]})
set(gca,'yticklabel',{[]})


%% decrease of area per frame
decArea = {decGp1,decGp2};
y = [decArea{1},decArea{2}]*s2;
x = [zeros(1,numel(decArea{1})),ones(1,numel(decArea{2}))];
violinplot(y,x)
set(gca,'xticklabel',{[]})
set(gca,'yticklabel',{[]})

incArea = {decGp1Log,decGp2Log};
y = [incArea{1},incArea{2}]*s2;
x = [zeros(1,numel(incArea{1})),ones(1,numel(incArea{2}))];
violinplot(y,x)
set(gca,'xticklabel',{[]})
set(gca,'yticklabel',{[]})

