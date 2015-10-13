% Entrance for slope-only/perframe scheme optimization.

clear s T W outputPrefix
close all

%% Input parameters
%seqName= 'foreman';
%dt = 20;

%% Output parameters
outputPrefix = 'FO_OptResult_'; % 'OptResult_'

%% Init

load(strcat(seqName, '_seq_br'));
norm_s = s./(sum(s)/size(s,2));
T = size(norm_s,2);

%% optimization
tic

for W=45:5:55
    %dt = W;
    clear x
    clear x0
    clear fval
    fprintf('Optimizing seq:%s, delta t = %d, window size = %d...\n',seqName, dt, W);
    tic
    %[x,x0,fval] = samplingOptimization(T,W,dt,s);
    [fx,x,x0,fval] = firstOrderSamplingOptimization(T,W,dt,norm_s);
    toc
    %save(strcat('OptResult_T',num2str(T),'_W',num2str(W),'_dt',num2str(dt),'_',seqName),'seqName','x','x0','fval','T','W','dt','s');
    if(exist('outputPrefix'))
        save(strcat([outputPrefix 'T'],num2str(T),'_W',num2str(W),'_dt',num2str(dt),'_',seqName),'seqName','fx','x','x0','T','W','dt','s');
    end
    genPacketScheduler;
    %plotOptResults;
end
fprintf('All seq:%s finished.\n',seqName);

toc
