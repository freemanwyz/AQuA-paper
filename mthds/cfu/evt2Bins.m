function bins = evt2Bins(PairwiseP, numEvt)
% find all evnets that belong to one microdomain

    bins = cell(numEvt,1);
    UsedId = [];
    for i=1:numEvt
        %bins{i} = i;
        if find(UsedId==i,1)
            UsedId(UsedId<=i)=[];
            continue;
        end
        bins{i} = i;
        pair1 = i;
        while ~isempty(find(PairwiseP(pair1,:)>0, 1))
            pos = find(PairwiseP(pair1,:)>0,1);
            %pSzRatio(i) = pSzRatio(i)+PairwiseP(pair1,pos);
            pair1 = pos;
            bins{i} = cat(2,bins{i},pair1);
            if isempty(UsedId)
                UsedId = pair1;
            else
                UsedId = cat(1,UsedId,pair1);
            end
        end
        %pSzRatio(i) = pSzRatio(i)/length(bins{i});
        %pOut(i)=myBinomTest(OvpNumEvt(i)-1,numEvt,szRatio(i),'one');
    end
end