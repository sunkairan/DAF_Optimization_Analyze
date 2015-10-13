function [fx, xMat, x0Mat, fval] = firstOrderSamplingOptimization(T, W, dt, s)
% firstOrderSamplingOptimization is the main optimization function to achieve (10) in INFOCOM.
% Input:
%   T, W, s is NOT downScaleS-ed;
% Output:
%   fx is the optimal slope factors;
%   xMat is the corresponding distribution ( ASP*s(t) ) of fx;
%   x0Mat is the distribution of uniform window distributions;
%   fval is the minimal variance value.
% See also firstOrderFunctionToBeOpt.
%% down scale all the parameters using dt

[T W s] = downScaleS(T, W, dt, s);
Tx=T-W+1;

for i=1:Tx
    sWindowSum(i) = sum(s(i:i+W-1));
end

save('optConstDss','T','W','dt','s', 'sWindowSum');

%x(1:Tx*W,1) = 0;

fx(1:Tx,1) = 0;

%% upper and lower bounds
lb = -ones(Tx,1);
ub = ones(Tx,1);

%% inital point for x
% the guess is allocating according to the ratio of every frame's number of
% packets in the window
fx0(1:Tx,1) = 0;
   
%% do the optimization
Aeq = [];
beq = [];
A=[];
b=[];

[fx, fval] = fmincon(@firstOrderFunctionToBeOpt,fx0,A,b,Aeq,beq,lb,ub);

xMat = convertSlopeToDistribution(fx,T,W,s,sWindowSum);
x0Mat = convertSlopeToDistribution(fx0,T,W,s,sWindowSum);

end