function f = firstOrderFunctionToBeOpt( fx )
% firstOrderFunctionToBeOpt is the target variance as in (10) of INFOCOM.

load('optConstDss');

x = convertSlopeToDistribution(fx,T,W,s,sWindowSum);

X(1:T,1) = 0;

for t = W:(T-W+1)
    for t0 = t-W+1 : t
        X(t) = X(t) + x(t0,t-t0+1);
    end
    X(t) = X(t) / s(t);
end

%AvgX = sum(X(2*W:T-2*W+1),1) / (T-4*W+2);
AvgX = mean(X(W:T-W+1));

sumX = 0;

%for t=2*W:T-2*W+1
for t=W:T-W+1
    sumX = sumX + (X(t)-AvgX) * (X(t)-AvgX);
end

f=sumX;
end
