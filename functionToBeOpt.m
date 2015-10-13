function f = functionToBeOpt( x )
% functionToBeOpt is the target variance for per-frame optimization.

load('optConstDss');

X(1:T,1) = 0;

for t = W:(T-W+1)
    for t0 = t-W+1 : t
        X(t) = X(t) + x((t0-1)*W+t-t0+1);
    end
    X(t) = X(t) / s(t);
end

AvgX = mean(X(2*W:T-2*W+1));

sumX = 0;

for t=2*W:T-2*W+1
    sumX = sumX + (X(t)-AvgX) * (X(t)-AvgX);
end

f=sumX;
end
