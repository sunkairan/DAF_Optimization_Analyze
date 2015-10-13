function f = MPCFunctionToBeOpt( fx,target,T,W,s,sWindowSum,curASP)
% pridictiveFunctionToBeOpt is the target variance for predictive optimization.

%load('optConstPred');

x = convertSlopeToDistribution(fx,T,W,s,sWindowSum);

optLen=T-W+1;

X = curASP(1:optLen) .* s(1:optLen);

for t = 1:optLen
    for t0 = max(t-W+1, 1) : min(t, T-W+1)
        X(t) = X(t) + x(t0,t-t0+1);
    end
end

X = X ./ s(1:optLen);

sumX = 0;

%target =  mean(X);

for t = 1:optLen
    sumX = sumX + (X(t)-target).^2;
end

f=sumX;
end
