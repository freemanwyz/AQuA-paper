function genNormalRankTopMeanDist()
    % genNormalRankTopMeanDist for normal order statistics
    % Rank 1000 RVs ~N(0,1), choose top k, get the mean and variance 
    % use simulation
    
    tbTopNorm = zeros(1000,3);  % ratio, mean, std
    
    x = randn(1e6,1000);
    x = sort(x,2,'descend');
    
    xs = cumsum(x,2);
    xsm = xs./(1:1000);
    
    tbTopNorm(:,1) = (1:1000)/1000;
    tbTopNorm(:,2) = mean(xsm,1)';
    tbTopNorm(:,3) = std(xsm,0,1)';
    xInfo = 'ratio, mean, std. 1000 ratios: 1/1000 to 1. Simulated 1e6 times';
    
    save('normTopMeanDist.mat','tbTopNorm','xInfo');
    
end