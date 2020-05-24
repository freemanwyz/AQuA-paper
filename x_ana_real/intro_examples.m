% analyze results for ex vivo data, draw example events
% heterogeneities among single astrocytes
% similar to some subfigues in fig 3 of the AQuA paper

folderTop = 'D:/OneDrive/projects/glia_kira/tmp/disser/example/';
imgIn = 'FilteredNRMCCyto16m_slice3_Baseline3_L2 3-015cycle1channel1';
fOutTop = './tmp_disser/';

resCur = load([folderTop,imgIn,'/',imgIn,'_aqua.mat']);
res = resCur.res;
zzshow(res.datOrg);
rgH = 114:391;
rgW = 114:391;


%% illustration for three rules
trg = [42,58;127,156];

for nn=1:size(trg,1)
    trg0 = trg(nn,1):trg(nn,2);
    for ii=1:numel(trg0)
        ovIn = imread([folderTop,imgIn,'/',imgIn,'_aqua.tif'],trg0(ii));
        ovOut = ovIn(rgH,rgW,:);
        fOut = [fOutTop,'Group ',num2str(nn),' frame ',num2str(ii),'.png'];
        imwrite(ovOut,fOut);
        rawOut = res.datOrg(rgH,rgW,trg0(ii));
        rawOut = (double(rawOut)/255).^2*4;
        fOut = [fOutTop,'Raw Group ',num2str(nn),' frame ',num2str(ii),'.png'];
        imwrite(rawOut,fOut);
    end
end




