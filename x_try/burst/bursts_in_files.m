%% find data sets with more bursts

% in vivo data sets
folder0 = 'D:\OneDrive\projects\glia_kira\raw\GCaMP_May17\Lck_Gcamp with Aldh1l1-tdtomato';

opts = util.parseParam(1,[],'parameters1.csv');

xx = dir(folder0);
for ii=1:numel(xx)
    xx0 = xx(ii);
    if xx0.isdir==1
        continue
    end
    fprintf('%s\n',xx0.name)
    [datOrg,opts] = burst.prep1(folder0,xx0.name,[],opts);
    datOrgVec = reshape(datOrg,[],size(datOrg,3));
    xm = mean(datOrgVec,1);
    ff = figure;plot(xm);title(xx0.name);
    saveas(ff,['./tmp/',xx0.name]);
    pause(0.5)
    close
end




