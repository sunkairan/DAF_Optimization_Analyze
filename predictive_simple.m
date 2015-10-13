% Entrance for simple predictive scheme.
% Input parameters:
%   seqName is the name of the sequence.
%   W and dt are window size and dt.
% Prediction control:
%   factor is the percentage of the newest frame's bit rate in pridiction.
%   cheat1 lets it know the average of future bit rates (overrides factor)
%   cheat2 lets it know the exact future bit rates (overrides cheat1)
% Output parameters:
%   outputPrefix is the prefix of output file (comment it if no output)

clear s T W ASP fx cheat1 cheat2 factor outputPrefix
%close all

%% Input parameters
seqName= 'foreman';
dt = 1;
W=20;

%% Prediction control
factor = 3/4;% prediction factor
cheat1 = 0; % knows the average of future bit rates (overrides factor)
cheat2 = 0; % knows the exact future bit rates (overrides cheat1)

%% Output parameter
%outputPrefix = 'PredictSimple_OptResult_';

%% init
load(strcat(seqName, '_seq_br'));
norm_s = s./(mean(s));
T = size(norm_s,2);
Tx = T-W+1;

% init warm-up period
% all uniform distribution in first W-1 windows
ASP = zeros(1,T);
%opt_a = zeros(1,Tx);
x=zeros(Tx,W);
sWindowSum = zeros(1,Tx);
for i=1:Tx
    sWindowSum(i) = sum(norm_s(i:i+W-1));
end
for t0=W:(2*W-2)
    startFrm = t0 - W + 1;
    %opt_a(startFrm) = 0;
    x(startFrm,:) = convertSlopeToDistribution(0,W,W,norm_s(startFrm:t0),sWindowSum(startFrm));
    opt_perframe = x(startFrm,:) ./ norm_s(startFrm:t0);
    ASP(startFrm:t0) = ASP(startFrm:t0) + opt_perframe;
end
% init prediction
predictLevel = mean(norm_s(W:2*W-2));

%% begin optimization
for t0=(2*W-1):T % t0 is the newly added frame 
    % init
    startFrm = t0 - W + 1;
    endFrm = min(t0 + W - 1,T);
    % update prediction level
    predictLevel = (1-factor) * predictLevel + factor * norm_s(t0);
    % little cheat
    if(cheat1) 
        predictLevel = mean(norm_s(t0:endFrm));
    end
    
    % predict s
    curS = zeros(1,2*W-1);
    curS(1:W) = norm_s(startFrm:t0);
    curS(W+1:2*W-1) = repmat(predictLevel,1,W-1);
    % big cheat
    if(cheat2) 
        curS(1:endFrm-startFrm+1) = norm_s(startFrm:endFrm);
    end
    
    predWindowSum = zeros(1,2*W-1);
    for i=2:W
        predWindowSum(i) = sum(curS(i:i+W-1));
    end
    tempASP = convertSlopeToDistribution(zeros(1,W-1),2*W-2,W, curS(2:end), predWindowSum(2:end));
    predictASP = zeros(1,2*W-1);
    [predictASP(2:end) , Xtemp] = getXFromx( tempASP, 2*W-2, W, 1, curS(2:end) );
    curASP = ASP(startFrm:t0) + predictASP(1:W);
    
    % execute the optimal slope (poor man's algorithm)
    minvar = 10000;
    opt_a = 0;
    opt_ASP = zeros(1,W);
    for i_opt_a = -1:0.05:1
        newASP = convertSlopeToDistribution(i_opt_a,W,W,norm_s(startFrm:t0),sWindowSum(startFrm)) ./ norm_s(startFrm:t0);
        tempvar = var(curASP + newASP);
        if (tempvar < minvar)
            minvar = tempvar;
            opt_a = i_opt_a;
            opt_ASP = newASP;
        end
    end
    x(startFrm,:) = opt_ASP .* norm_s(startFrm:t0);
    ASP(startFrm:t0) = ASP(startFrm:t0) + opt_ASP;
    fprintf('Computing seq:%s, delta t = %d, window size = %d, frame no. %d...\n',seqName, dt, W, t0);
end
% x = reshape(convertSlopeToDistribution(opt_a,T,W,norm_s,sWindowSum), W,Tx)'; % ASP == X
% fx = opt_a;
fx0(1:Tx,1) = 0;
x0 = convertSlopeToDistribution(fx0,T,W,norm_s,sWindowSum);
s
if(exist('outputPrefix'))
    save(strcat([ outputPrefix 'T'],num2str(T),'_W',num2str(W),'_dt',num2str(dt),'_',seqName),'seqName','fx','x','x0','T','W','dt','s');
end

plotOptResults

fprintf('All seq:%s finished.\n',seqName);