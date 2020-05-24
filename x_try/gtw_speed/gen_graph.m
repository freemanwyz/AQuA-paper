%%
p0 = getWorkPath();
f0 = '2826451(4)_1_2_4x_reg_200um_dualwv-001_nr';
f_dat = [p0,'/dat/',f0,'.tif'];
f_res = [p0,'/dat_detect/',f0,'_aqua.mat'];

dat = readTiffSeq(f_dat);
dat = double(dat(6:end-5,6:end-5,:));
dat = dat/max(dat(:));
tmp = load(f_res);
res = tmp.res;

seLst = res.seLst;
seMap = lst2map(seLst,size(dat));
[H,W,T] = size(dat);

dh = [0,-1,1,0];
dw = [-1,0,0,1];


%%
for ii=1:numel(seLst)
    fprintf('%d\n',ii)
    se0 = seLst{ii};
    [ih0,iw0,it0] = ind2sub(size(dat),se0);
    rgh = min(ih0):max(ih0);
    rgw = min(iw0):max(iw0);
    rgt = max(min(it0)-10,1):min(max(it0)+10,T);
    seMap0 = seMap(rgh,rgw,rgt);
    dat0 = double(dat(rgh,rgw,rgt));
    dat0 = dat0-min(dat0,[],3);
    dat0(seMap0>0 & seMap0~=ii) = 0;
    
    pixMap0 = sum(seMap0==ii,3)>0;
    
    [H0,W0,T0] = size(dat0);
    
    ix = find(pixMap0>0);
    pixMap0a = pixMap0*0;
    pixMap0a(ix) = 1:numel(ix);
    
    % curves
    dat0Vec = reshape(dat0,[],size(dat0,3));
    dat0Vec = dat0Vec(ix,:);
    tst = dat0Vec-min(dat0Vec,[],2);
    xMag = max(tst,[],2);
    refBase = mean(tst,1);
    refBase = refBase - min(refBase);
    refBase = refBase/max(refBase);
    ref = xMag*refBase;
    
    % graph
    s = nan(numel(ix)*4,1);
    t = nan(numel(ix)*4,1);
    [ih0,iw0] = ind2sub(size(pixMap0a),ix);
    nEdge = 1;
    for jj=1:numel(ix)
        for kk=1:numel(dh)
            ih1 = min(max(ih0(jj)+dh(kk),1),H0);
            iw1 = min(max(iw0(jj)+dw(kk),1),W0);
            tgt = pixMap0a(ih1,iw1);
            if tgt>jj
                s(nEdge) = jj;
                t(nEdge) = tgt;
                nEdge = nEdge+1;
            end
        end
    end
    s = s(~isnan(s));
    t = t(~isnan(t));
    
    save(['./tmp/',num2str(ii),'.mat'],'s','t','ref','tst');
end























