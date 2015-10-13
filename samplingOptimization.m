function [xMat, x0Mat, fval] = samplingOptimization(T, W, dt, s)
% samplingOptimization is the main optimization function to achieve per-frame optimization
% Input:
%   T, W, s is NOT downScaleS-ed;
% Output:
%   xMat is the optimal sampling distribution ( ASP*s(t) );
%   x0Mat is the distribution of uniform window distributions;
%   fval is the minimal variance value.
% See also functionToBeOpt.
%% down scale all the parameters using dt

[T W s] = downScaleS(T, W, dt, s);

save('optConstDss','T','W','dt','s');

Tx=T-W+1;


%% equations for the constraints of total probability=1
Aeq(1:Tx,1:Tx*W) = 0;

for i=1:Tx
    Aeq(i,1+(i-1)*W : i*W) = ones(1,W);
end

beq = ones(Tx,1);

%% upper and lower bounds
lb = zeros(Tx*W,1);
ub = ones(Tx*W,1);

for tp=1:W-1
    ub( (tp-1)*W+1 : tp*(W - 1), 1) = 0;
end

for tp=1:W-1
    ub(Tx*W+1 - tp*(W - 1) :  Tx*W - (tp-1)*W, 1) = 0;
end

%% inital point for x
% the guess is allocating according to the ratio of every frame's number of
% packets in the window
x0(1:Tx*W,1) = 0;

for i=1:Tx
    curW = ub((i-1)*W+1 : i*W).*s(i:i+W-1)';
    sumT = sum(curW);
    for j=1:W
        x0((i-1)*W+j) = curW(j)/sumT;
    end
end
    
%% do the optimization
A=[];
b=[];

[xMat, fval] = fmincon(@functionToBeOpt,x0,A,b,Aeq,beq,lb,ub);

x0Mat=reshape(x0,W,Tx)';

end