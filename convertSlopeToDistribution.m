function [ xMat ] = convertSlopeToDistribution( fx, T, W, s, sWindowSum)
% convertSlopeToDistribution converts slope factors into distributions.
% Input: resulting x is NOT ASP, but is ASP*s(t), as in (4) in INFOCOM
%   T, W, s is downScaleS-ed;
%   fx is the slope factors in [-1, 1] of length T-W;
%   sWindowSum(i) is the sum of s in the window starting from i;
% Output:
%   xMat is a Tx*W matrix. Each row is the distribution for a window.
% See also downScaleS.

Tx=T-W+1;

x(1:Tx*W,1) = 0;

for i=1:Tx
    a = 2*fx(i)/sWindowSum(i)/sWindowSum(i);
    b = (1-fx(i))/sWindowSum(i);
    right = 0;
    for j=1:W
        left = right;
        right = left + s(i+j-1);
        x((i-1)*W +j ) = (a * (left+right) / 2 + b)*s(i+j-1);
    end
end

xMat=reshape(x,W,Tx)';

end
