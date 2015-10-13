function f = pridictiveFunctionToBeOpt( fx,T,W,s,sWindowSum,curASP)
% pridictiveFunctionToBeOpt is the target variance for predictive optimization.

%load('optConstPred');

x = convertSlopeToDistribution(fx,T,W,s,sWindowSum);

X = curASP .* s;

for t = 1:T
    for t0 = max(t-W+1, 1) : min(t, T-W+1)
        X(t) = X(t) + x(t0,t-t0+1);
    end
    X(t) = X(t) / s(t);
end

AvgX = mean(X(1:T));

sumX = 0;

%for t=2*W:T-2*W+1
for t = 1:T
    sumX = sumX + (X(t)-AvgX) * (X(t)-AvgX);
end

f=sumX;
end
