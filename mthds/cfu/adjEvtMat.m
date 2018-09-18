function PairwiseP = adjEvtMat(numEvt,locy,locx,loct,evtCells,IoUThres,rad)
% Get the adjacent relationship between events
PairwiseP = nan(numEvt);
if length(rad)==1
    %r1 = rad;r2 = rad;
    rad = ones(numEvt,1)*rad;
end
for i=1:numEvt-1
    %disp(i);
    r1 = rad(i);
    for j=i+1:numEvt
        if loct(i)>loct(j)
            continue;
        end
        r2 = rad(j);
        dd = norm([locy(i)-locy(j),locx(i)-locx(j)]);
        %r1 = rad;r2 = rad;
        minIoU =  IoUThres*max(size(evtCells{i},1), size(evtCells{j},1));
        if minIoU>min(size(evtCells{i},1), size(evtCells{j},1))
            continue;
        end
        d = radiusFromSize(r1,r2,minIoU);% dichotomy tp get the distance value, accracy 10^-4 in default
        if dd<=d
            PairwiseP(i,j)=1;
            break;
        end
        
    end
end
end