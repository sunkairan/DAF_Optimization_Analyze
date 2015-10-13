% Entrance for scalable predictive optimization.
% Online window-by-window optimization based on prediction. Take the first
% slope for each window.
% Input parameters:
%   seqName is the name of the sequence.
%   W and dt are window size and dt.
% Prediction control:
%   factor is the percentage of the newest frame's bit rate in pridiction.
%   optLen is how many frames to be optimized for each window (still takes the first one)
%   cheat1 lets it know the average of future bit rates (overrides factor)
%   cheat2 lets it know the exact future bit rates (overrides cheat1)
%   cheatLen is the length of the future frames cheat2 knows
% Output parameters:
%   outputPrefix is the prefix of output file (comment it if no output)
% see also: predictiveSamplingOptimization.
close all
clear s T ASP fx 
%clear cheat1 cheat2 cheatLen factor outputPrefi

%% Input parameters
% seqName= 'foreman';
% dt = 1;
% W=30;
% target = 0.9946;

%% Prediction control
% factor = 0.75;   % prediction factor
% optLen = 10;
% cheat1 = 0;     % knows the average of future bit rates (overrides factor)
% cheat2 = 1;     % knows the exact future bit rates (overrides cheat1)
cheatLen = 2*W;   % 
historyLen = 2 * W;

%% Output parameters
% outputPrefix = ['MPC_L' num2str(optLen) '_OptResult_F0.75_'];
% outputPrefix = ['MPC_Cheat_L' num2str(optLen) '_OptResult_F0_'];

%% Init

load(strcat(seqName, '_seq_br'));
norm_s = s./(sum(s)/size(s,2));
T = size(norm_s,2);


Tx = T-W+1;

% init warm-up period
% all uniform distribution in first W-1 windows
ASP = zeros(1,T);
opt_a = zeros(1,Tx);
sWindowSum = zeros(1,Tx);
for i=1:Tx
    sWindowSum(i) = sum(norm_s(i:i+W-1));
end
for t0=W:(2*W-1)
    startFrm = t0 - W + 1;
    opt_a(startFrm) = 0;
    newASP = convertSlopeToDistribution(0,W,W,norm_s(startFrm:t0),sWindowSum(startFrm)) ./ norm_s(startFrm:t0);
    ASP(startFrm:t0) = ASP(startFrm:t0) + newASP;
end
% init prediction
predictLevel = mean(norm_s(W:2*W-2));

%% begin optimization
for t0=(2*W):T % t0 is the newly added frame 
    fprintf('Optimizing seq:%s, delta t = %d, window size = %d, frame no. %d...\n',seqName, dt, W, t0);
    
    % init
    startFrm = t0 - W + 1;
    optTo  = min(t0 + optLen - 1, T);
    endFrm = min(t0 + optLen + W  - 2, T);
    curSLen = 2*W - 2 + optLen;
    
    historyFrm = max(W,startFrm-historyLen);

    % update prediction level
    predictLevel = (1-factor) * predictLevel + factor * norm_s(t0);
    % little cheat
    if(cheat1) 
        predictLevel = mean(norm_s(t0:endFrm));
    end
    
    % predict s
    curS = zeros(1,curSLen);
    curS(1:W) = norm_s(startFrm:t0);
    curS(W+1:curSLen) = repmat(predictLevel,1,curSLen-W);
    % big cheat
    if(cheat2) 
        tcheatLen = min(min(cheatLen, T-t0),curSLen-W);
        curS(1:W+tcheatLen) = norm_s(startFrm:t0+tcheatLen);
    end
    
    % compute predicted ASPs of the not-optimized parts with all 0 slopes
    predWindowSum = zeros(1,curSLen);
    for i=1+optLen : W+optLen-1
        predWindowSum(i) = sum(curS(i:i+W-1));
    end
    tempASP = convertSlopeToDistribution(zeros(1,W-1),2*W-2,W, curS(1+optLen:end), predWindowSum(1+optLen:end));
    predictASP = zeros(1,curSLen);
    [predictASP(1+optLen:end) , Xtemp] = getXFromx( tempASP, 2*W-2, W, 1, curS(1+optLen:end) );
    
    % put the existing and predicted ASP 
    curASP = zeros(1,W+optLen-1);
    curASP(1:W) = ASP(startFrm:t0);
    curASP = curASP + predictASP(1:W+optLen-1);
    
    % optimize
    target = mean(ASP(historyFrm:startFrm-1));
    opt_a(startFrm) = MPCSamplingOptimization(target, W+optLen-1, W, dt, curASP, curS);
    
    % execute the optimal slope
    newASP = convertSlopeToDistribution(opt_a(startFrm),W,W,norm_s(startFrm:t0),sWindowSum(startFrm)) ./ norm_s(startFrm:t0);
    ASP(startFrm:t0) = ASP(startFrm:t0) + newASP;
end
x = convertSlopeToDistribution(opt_a,T,W,norm_s,sWindowSum); % ASP == X
fx = opt_a;
fx0(1:Tx,1) = 0;
x0 = convertSlopeToDistribution(fx0,T,W,norm_s,sWindowSum);

if(exist('outputPrefix'))
    save(strcat([ outputPrefix 'T'],num2str(T),'_W',num2str(W),'_dt',num2str(dt),'_',seqName,'.mat'),'seqName','fx','x','x0','T','W','dt','s');
end

%plotOptResults

fprintf('All seq:%s finished.\n',seqName);
