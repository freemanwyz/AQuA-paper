p0 = getWorkPath();

% in vivo
% show 1,4,5 in the table
res1 = load([p0,'simDat/running_time/run_1.mat']);

% ex vivo
% use 1,2,3
res2 = load([p0,'simDat/running_time/run_2.mat']);

% glutamate
% use 1,2,3
res4 = load([p0,'simDat/running_time/run_4b.mat']);


%%
x = res2.pLst{1};
y = res1.pLst{1};
z = res4.pLst{1};