% Entrance for predictive scheme optimization.
% Online window-by-window optimization based on prediction. Take the first
% slope for each window.
% Input parameters:
%   seqName is the name of the sequence.
%   W and dt are window size and dt.
% Prediction control:
%   factor is the percentage of the newest frame's bit rate in pridiction.
%   cheat1 lets it know the average of future bit rates (overrides factor)
% Output parameters:
%   outputPrefix is the prefix of output file (comment it if no output)
% see also: predictiveSamplingOptimization.

clear s T W ASP fx cheat1 factor outputPrefix
%close all

%% Input parameters
seqName= 'foreman';
dt = 1;
W=40;

%% Prediction control
factor = 3/4; % prediction factor
cheat1 = 0;% knows the average of future bit rates (overrides factor)

%% Output parameters
outputPrefix = 'Predict_OptResult_3_to_4_';

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
for t0=W:(2*W-2)
    startFrm = t0 - W + 1;
    opt_a(startFrm) = 0;
    newASP = convertSlopeToDistribution(0,W,W,norm_s(startFrm:t0),sWindowSum(startFrm)) ./ norm_s(startFrm:t0);
    ASP(startFrm:t0) = ASP(startFrm:t0) + newASP;
end
% init prediction
predictLevel = mean(norm_s(W:2*W-2));

%% begin optimization
for t0=(2*W-1):T % t0 is the newly added frame 
    % init
    fprintf('Optimizing seq:%s, delta t = %d, window size = %d, frame no. %d...\n',seqName, dt, W, t0);
    startFrm = t0 - W + 1;
    % update prediction level
    predictLevel = (1-factor) * predictLevel + factor * norm_s(t0);
    % little cheat
    if (cheat1) 
        predictLevel = mean(norm_s(t0:min(t0 +2* W - 1,T)));
    end
    
    % put the existing and predicted ASP 
    curASP = zeros(1,2*W-1);
    curASP(1:W-1) = ASP(startFrm:t0-1); % curASP(1:W-1) are real ASP
    curASP(W+1:2*W-1) = [1:W-1]./(W*predictLevel); % curASP(W+1:2*W-1) are all predictive frms; 
    
    % optimize
    opt_a(startFrm) = predictiveSamplingOptimization(2*W-1, W, dt, curASP, [norm_s(startFrm:t0)  repmat(predictLevel,1,W-1)]);
    
    % execute the optimal slope
    newASP = convertSlopeToDistribution(opt_a(startFrm),W,W,norm_s(startFrm:t0),sWindowSum(startFrm)) ./ norm_s(startFrm:t0);
    ASP(startFrm:t0) = ASP(startFrm:t0) + newASP;
end
x = convertSlopeToDistribution(opt_a,T,W,norm_s,sWindowSum); % ASP == X
fx = opt_a;
fx0(1:Tx,1) = 0;
x0 = convertSlopeToDistribution(fx0,T,W,norm_s,sWindowSum);

if(exist('outputPrefix'))
    save(strcat([ outputPrefix 'T'],num2str(T),'_W',num2str(W),'_dt',num2str(dt),'_',seqName),'seqName','fx','x','x0','T','W','dt','s');
end

plotOptResults

fprintf('All seq:%s finished.\n',seqName);
