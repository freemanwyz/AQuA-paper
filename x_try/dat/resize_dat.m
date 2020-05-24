p_top = '../../glia_kira/raw/GRAB-NE/';
% f_dat = '190405_s1_002.tif';
% f_out = '190405_s1_002_ds5'; fpb = 5;
f_dat = '190405_s2_005.tif';
f_out = '190405_s2_005_ds5'; fpb = 5;

dat = readTiffSeq([p_top,f_dat]);

% spatial downsample
% dat1 = imresize(dat,[128,128]);
dat1 = dat;

% temporal binning
T = size(dat1,3);
dat2 = zeros(size(dat1));
cnt = 0;
for ii=1:floor(size(dat2,3)/fpb)
    t0 = (ii-1)*fpb+1;
    t1 = min(ii*fpb,T);
    dat2(:,:,ii) = mean(dat1(:,:,t0:t1),3);
end
dat2 = dat2(:,:,1:ii);

dat2 = dat2/max(dat2(:));

%% output
% save([p_top,f_out,'.mat'],'dat2');
writeTiffSeq([p_top,f_out,'.tif'],dat2,8);



