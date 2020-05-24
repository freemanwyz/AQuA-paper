x = imgaussfilt(double(gTblue),2);
x = x/max(x(:));
x = imresize(x,0.333);

y = moving;
y = y - min(moving(:));
y = y/max(y(:));

zzshow(x)
zzshow(y)

%%
[optimizer, metric] = imregconfig('multimodal');

optimizer.InitialRadius = 0.009;
optimizer.Epsilon = 1.5e-4;
optimizer.GrowthFactor = 1.01;
optimizer.MaximumIterations = 300;

movingRegistered = imregister(x, y, 'affine', optimizer, metric);

imshowpair(y, movingRegistered,'Scaling','joint')


