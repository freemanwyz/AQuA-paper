% region growing for boundary refinement

pIn = 'D:\OneDrive\projects\glia_kira\se_aqua\simDat\';
f0 = 'ex_domain_avgsize_fixed_noprop_notempsmo_samedf_20180913_112045';
% f0 = 'ex_domain_avgsize_fixed_noprop_nosmo_samedf_20180912_222204';

xx = load([pIn,f0,'.mat']);
datSim = single(xx.datSim)/65535;

javaclasspath('-v1')
javaclasspath('..\..\repo\gfptoolbox\tools\FASP\out\production\FASP\')

% p2z = @(p) sqrt(2) * erfcinv(p*2);

[H,W,T] = size(datSim);
evtLst = xx.evtLst;
evtMap = zeros(size(datSim));
for nn=1:numel(evtLst)
    evtMap(evtLst{nn}) = nn;
end

%%
datSimNy = datSim + xx.dAvg*1.5 + randn(size(datSim))*0.01;
evts = sim1.refineEvts(datSimNy,evtLst,3);


%%
s0 = 0.1;
ioux = nan(numel(evtLst),2);

for nn=1:numel(evtLst)
    if mod(nn,10)==0
        fprintf('%d\n',nn);
    end
    
    pix0 = evtLst{nn};
    [ih,iw,it] = ind2sub([H,W,T],pix0);
    rgh = max(min(ih)-5,1):min(max(ih)+5,H);
    rgw = max(min(iw)-5,1):min(max(iw)+5,W);
    rgt = max(min(it)-10,1):min(max(it)+10,T);
    d0 = datSim(rgh,rgw,rgt);
    e0 = evtMap(rgh,rgw,rgt);
    d0(e0~=nn) = 0;
    e0(e0~=nn) = 0;
    
    d0n = d0 + randn(size(d0))*s0;
    fiu0 = sum(e0,3)>0;
    %zzshow(fiu0)

    d0nVec = reshape(d0n,[],size(d0n,3));
    charx0 = mean(d0nVec(fiu0>0,:),1);
        
    z0Vec = zeros(size(d0nVec,1),1);
    r0Vec = z0Vec;
    p0Vec = z0Vec;
    for ii=1:numel(z0Vec)
        [r,p] = corrcoef(charx0,d0nVec(ii,:));
        p0Vec(ii) = p(1,2);
        z00 = abs(norminv(p(1,2)/2));
        if r(1,2)>0
            z0Vec(ii) = z00;
        else
            z0Vec(ii) = -z00;
        end
        r0Vec(ii) = r(1,2);
    end
    
    zMap0 = reshape(z0Vec,size(fiu0));
    %r0Map = reshape(r0Vec,size(fiu0));
    vMap0 = ones(size(fiu0));
    
    %[~,seed0] = max(z01Map(:));
    
    % HTRG
    res0 = HTregionGrowingSuper(zMap0,vMap0,2,4,4,0);
    htMap00 = double(res0.connDmIDmap);
    %tmpZ = double(res0.connDmZmapSuper);
    cc = bwconncomp(htMap00);
    lbl = labelmatrix(cc);
    lblSel = mode(lbl(fiu0>0 & lbl>0));
    htMap0 = zeros(size(fiu0));
    if lblSel>0
        htMap0(cc.PixelIdxList{lblSel}) = 1;
    else
        fprintf('HTRG missed one\n')
    end
    
    % thresholding
    thMap00 = zMap0>2;
    cc = bwconncomp(thMap00);
    lbl = labelmatrix(cc);
    lbl0 = lbl(fiu0>0 & lbl>0);
    lblSel = mode(lbl0);
    thMap0 = zeros(size(fiu0));
    if lblSel>0
        thMap0(cc.PixelIdxList{lblSel}) = 1;
        thMap0 = imfill(thMap0,'holes');
    else
        fprintf('thr missed one\n')
    end
    
    % compare
    if 0
        figure;
        subplot(1,2,1);
        res = cat(3,fiu0,htMap0>0,htMap0*0); imshow(res)
        subplot(1,2,2);
        res = cat(3,fiu0,thMap0>0,thMap0*0); imshow(res)
        keyboard
        close
    end
    
    xInt = htMap0>0 & fiu0>0;
    xUni = htMap0>0 | fiu0>0;
    ioux(nn,1) = sum(xInt(:)>0)/sum(xUni(:)>0);  
    xInt = thMap0>0 & fiu0>0;
    xUni = thMap0>0 | fiu0>0;
    ioux(nn,2) = sum(xInt(:)>0)/sum(xUni(:)>0);
    
end














