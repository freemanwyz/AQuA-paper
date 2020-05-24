% analyze results for in vivo data, draw example events
% propagation
% similar to some subfigues in fig 3 of the AQuA paper

folderTop = 'D:\OneDrive\projects\glia_kira\tmp\disser\invivo\';
img = '2826451(4)_1_2_4x_reg_200um_dualwv-001';
fOutTop = './tmp_disser/';

s = 1.61;
s2 = s^2;
spf = 0.744;

resCur = load([folderTop,img,'/',img,'_aqua.mat']);
res = resCur.res;
[H,W,T] = size(res.datOrg);
idxBurstLarge = [26,46,426];  % two burst events and one inter-burst


%% features
nEvtCur = numel(res.evt);
xArea = res.fts.basic.area';
xDuration = res.fts.curve.width55';
xProp = res.fts.propagation.propGrowOverall;
datMean = mean(double(res.datOrg),3)/65535;

% summary over time
T = size(res.datOrg,3);
tmp = reshape(res.datRAll,[],T);
actArea = sum(tmp>0,1);
figure;plot(actArea)


%% burst events and interburst events
timeBurst = actArea>max(actArea*0.1);
evtStatus = zeros(nEvtCur,1);
for ii=1:nEvtCur
    if sum(timeBurst(res.fts.loc.t0(ii):res.fts.loc.t1(ii)))>0
        evtStatus(ii) = 1;
    end
end

% scatterplot of features: burst vs. inter-burst
% xProp1 = sqrt(sum(xProp.^2,2));
figure;
scatter(sqrt(xProp(evtStatus==1))*s,xArea(evtStatus==1)*s2,'filled','MarkerFaceAlpha',0.5);
hold on;
scatter(sqrt(xProp(evtStatus==0))*s,xArea(evtStatus==0)*s2,'filled','MarkerFaceAlpha',0.5);

legend({'Burst','Inter-burst'})

xlabel('Propagation distance');
ylabel('Propagation area');

set(gca,'XTickLabel',[]);
set(gca,'YTickLabel',[]);


%% a large burst
datOv = imread([folderTop,img,'/',img,'_aqua.tif'],1450);
zzshow(datOv);
imwrite(datOv,[fOutTop,'large_burst.png']);


%% two events in this large burst
colors = [1,1,0;0,1,0;0,0,1];
cnt = 1;
for idx=idxBurstLarge
    evt0 = res.evt{idx};
    [ih,iw,it] = ind2sub(size(res.datOrg),evt0);
    datSelAll = double(res.datOrg(:,:,min(it):max(it)));
    datSelAll = datSelAll/max(datSelAll(:))/2;
    
    col0 = colors(cnt,:);
    for tt=1:size(datSelAll,3)
        tx = min(it)+tt-1;
        ih0 = ih(it==tx);
        iw0 = iw(it==tx);
        ihw0 = sub2ind([H,W],ih0,iw0);
        
        datLvl0 = double(res.datRAll(:,:,tx))/255;
        datMsk0 = zeros(H,W); datMsk0(ihw0) = 1;
        datMsk0 = datMsk0.*datLvl0;
        datSel = datSelAll(:,:,tt);
        
        m1 = datMsk0/2*col0(1);
        m2 = datMsk0/2*col0(2);
        m3 = datMsk0/2*col0(3);
        datOv0 = cat(3,datSel+m1,datSel+m2,datSel+m3);
        fOut = [fOutTop,'Event ',num2str(idx),' ',num2str(min(it)+tt-1),'.png'];
        imwrite(datOv0,fOut);
    end
    cnt = cnt + 1;
end


%% delay maps for two events
fpd = 0.744;
s = 1.616;
for idx=idxBurstLarge
    dly0 = res.riseLst{idx}.dlyMap;
    figure;imagesc(dly0*fpd,'AlphaData',~isnan(dly0));
    daspect([1,1,1]);
    %colorbar
    
    set(gca,'XTickLabel',[]);
    set(gca,'YTickLabel',[]);
end


%% delay maps of all bursts
% timeBurst = actArea>max(actArea*0.01);
% cc = bwconncomp(timeBurst);
% tw = cc.PixelIdxList;
%
% for kk=1:cc.NumObjects
%     % each burst
%     dlyAll = inf(H,W);
%     t0 = min(tw{kk});
%     t1 = max(tw{kk});
%     evtStatus = zeros(nEvtCur,1);
%     for ii=1:nEvtCur
%         % each event in the burst
%         ta = res.fts.loc.t0(ii);
%         tb = res.fts.loc.t1(ii);
%         if (ta<=t0 && tb>=t0) || (ta>=t0 && ta<=t1)
%             dly0 = res.riseLst{ii}.dlyMap;
%             rgh0 = res.riseLst{ii}.rgh;
%             rgw0 = res.riseLst{ii}.rgw;
%             dly0(isnan(dly0)) = inf;
%             dlyAll(rgh0,rgw0) = min(dlyAll(rgh0,rgw0),dly0);
%         end
%     end
%     figure;imagesc(dlyAll,'AlphaData',~isinf(dlyAll));
%     daspect([1,1,1]);colorbar
% end


%% directions of all events in the large burst
timeBurst = actArea>max(actArea*0.01);
cc = bwconncomp(timeBurst);
peakGrp = cc.PixelIdxList;
direcOveral = zeros(cc.NumObjects,2);

for kk=2:cc.NumObjects
    % each burst
    direc = zeros(1,2);
    t0 = min(peakGrp{kk});
    t1 = max(peakGrp{kk});
    evtStatus = zeros(nEvtCur,1);
    cnt = 1;
    
    % rising time map for the burst
    if 0
        dF = res.dF(:,:,t0:t1);
        zzshow(dF*3);
        close all
        datR = res.datRAll(:,:,t0:t1);
        onsetMap = inf(H,W);
        for h = 1:size(datR,1)
            for w = 1:size(datR,2)
                x = datR(h,w,:);
                t = find(x(:)>=255,1);
                if ~isempty(t)
                    onsetMap(h,w) = t;
                end
            end
        end
        figure;imagesc(onsetMap,'AlphaData',~isinf(onsetMap)); colorbar
        
        y = onsetMap(~isinf(onsetMap(:)));
        hvec = [];
        wvec = [];
        cntVec = [];
        for t = min(y):max(y)
            [h0,w0] = find(onsetMap<=t);
            hvec(t) = mean(h0)*s;
            wvec(t) = mean(w0)*s;
            cntVec(t) = numel(h0)*s2;
        end
        tvec = (1:numel(hvec))*spf;
        
        figure;plot(hvec);hold on;plot(wvec);
        plot(cntVec/max(cntVec)*max(max(hvec),max(wvec)))
        title(['Burst ',num2str(kk)])
    end
    
    % each event in this burst
    for ii=1:nEvtCur
        % each event in the burst
        ta = res.fts.loc.t0(ii);
        tb = res.fts.loc.t1(ii);
        if (ta<=t0 && tb>=t0) || (ta>=t0 && ta<=t1)
            vox = res.evt{ii};
            [h,w,t] = ind2sub([H,W,T],vox);
            
            h0 = h(t==min(t));
            w0 = w(t==min(t));
            hStart = mean(h0);
            wStart = mean(w0);
            
            h1 = h(t==max(t));
            w1 = w(t==max(t));
            %hEnd = mean(h1);
            %wEnd = mean(w1);
            hEnd = mean(h);
            wEnd = mean(w);
            
            hDif = hEnd-hStart;
            wDif = wEnd-wStart;
            
            if hDif~=0 || wDif~=0
                direc(cnt,:) = [wDif,-hDif]*s;
                cnt = cnt+1;
            end
        end
    end
    
    nArrow = size(direc,1);
    ss = sum(direc,1);
    direcOveral(kk,:) = ss;
    
    propDist = sqrt(sum(direc.^2,2));
    
    if 1
        figure;quiver(zeros(nArrow,1),zeros(nArrow,1),direc(:,1),direc(:,2));
        hold on;
        quiver(0,0,ss(1)/10,ss(2)/10,'LineWidth',2,'MaxHeadSize',10);
        daspect([1,1,1])
        title(num2str(kk))
    end
    
    %axis off
    fprintf('%d,%d\n',kk,max(propDist))
end

% overall
if 1
    nArrow = size(direcOveral,1);
    figure;quiver(zeros(nArrow,1),zeros(nArrow,1),direcOveral(:,1),direcOveral(:,2));
    ss = sum(direcOveral,1);
    hold on;
    quiver(0,0,ss(1),ss(2),'LineWidth',2,'MaxHeadSize',10);
    title('Overall')
end








