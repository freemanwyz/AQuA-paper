% compare the speed of IBFS and BK

p_top = 'D:\OneDrive\projects\glia_kira\tmp\gtw_graph_large\tmp\';
addpath(genpath('../../repo/aqua/'));

s2 = 0.02;
smoBase = 1;
maxStp = 11;
nRep = 1;

timeBk = nan(10,nRep);
timeIbfs = nan(10,nRep);
nEdge = nan(10,1);
nNode = nan(10,1);


%%
% nn = 1;
for ii=2:-1:1
    fprintf('Data %d\n',ii)
    x = load([p_top,num2str(ii),'.mat']);
    [ ss,ee,gInfo ] = gtw.buildGTWGraph( x.ref, x.tst, x.s, x.t, smoBase, maxStp, s2);
    
    nEdge(nn) = numel(ss,1);
    nNode(nn) = numel(ee,1);
    
    for kk=1:nRep
        fprintf(' -- IBFS %d\n',kk)
        tic
        [~, labels1a] = aoIBFS.graphCutMex(ss,ee);
        timeIbfs(nn,kk) = toc;
        
        fprintf(' -- BK %d\n',kk)
        tic
        [~, labels1b] = aoBK.graphCutMex(ss,ee);
        timeBk(nn,kk) = toc;
    end
    disp(timeIbfs)
    disp(timeBk)
    nn = nn+1;
end


