function fx = predictiveSamplingOptimization(T, W, dt, curASP, s)
% predictiveSamplingOptimization is the optimization function in predictive scheme to get optimal first slope in a window.
% Input:
%   curASP is the ASP that already exists in each frame.
%   length of curASP and s is 2*W-1;
%   W, s is NOT downScaleS-ed;
% Output:
%   fx is the optimal slope factor;
%% down scale all the parameters using dt

[T W s] = downScaleS(T, W, dt, s);
Tx=T-W+1; % Tx == W

for i=1:Tx
    sWindowSum(i) = sum(s(i:i+W-1));
end

%save('optConstPred','T','W','dt','s', 'sWindowSum','curASP');

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

[ffx, fval] = fmincon(@(x)pridictiveFunctionToBeOpt(x,T,W,s,sWindowSum,curASP),fx0,A,b,Aeq,beq,lb,ub);

fx = ffx(1);

end

