% Generate the packet scheduler file, dummy video file and video info file
% for predictive opt scheme.
% Need to pre-load the 'Predict_<Cheat_>Lxx_OptResult_**.mat' file:
%   Must have s, T, W, dt (UN-downscaled); 
%   and resulting prob.s: fx (vector of slopes). 
% Must pass in seqName, optLen, factor, cheating.
% load('Predict_<Cheat_>L10_OptResult_F0.5_T300_W20_dt1_foreman');
% Output 'foreman_W20_dt1_P1024_L10_F0.5_dummy/info/scheduler.txt'
%   Cheat is L10_F0, optimal is [nothing] (already exist)

%seqName = 'news';
%load([seqName, '_seq_br'],'s');

P = 1024;   % packet size (byte)
%C = 350000; % data rate (byte / s)
F = 30;     % frame rate (frame / s)
%dt = 90;    % window movement offset / GOP size (frame)
%oW = 90;
%oT = size(s,2);

oW = W;
oT = T;

WW = ceil(oW/dt)*dt; % window size (frame)
TT = floor(oT/dt)*dt; % total number of frames (frame)

if (~exist('postfixName'))
    postfixName = '';
end
seqName_W_dt = [seqName, '_W', int2str(WW), '_dt',int2str(dt), '_P',int2str(P) , postfixName];
% s is the number of bytes in every frame

sP = ceil(s(1:TT)./P);    % sP is the number of packets in every frame
k = sum(sP);        % total number of packets (packet)
packetNum(1:TT+1) = 0; % packetNum maps frame ID to packet ID

for i=1:(TT+1)
    packetNum(i) = sum(sP(1:(i-1)))+1;
end


AvgRate = k*P*F/TT;

fprintf('packetID\tFrom\tWindowSize\tMode\n');

n = 0;  % total number of windows %coded packets need to be sent
NPacketInWindow = 1;%ceil(C*dt/F/P); % repeat time of sending the packets within a window
evalFrom = packetNum(WW-dt+1);
evalTo   = packetNum(TT-WW+dt+1)-1;

    
%output packet scheduler
fileSched = fopen([seqName_W_dt, '_scheduler.txt'],'w');
for frameN = 1:dt:TT-WW+1
    for i = 1:NPacketInWindow
        n = n+1;
        fprintf(fileSched, '%d\t%d\t%d\t%1.4f\n', n, packetNum(frameN), packetNum(frameN+WW)-packetNum(frameN), fx((frameN-1)/dt+1) );%0);
    end
end
fclose(fileSched);

%output dummy file
fileOutput = fopen([seqName_W_dt, '_dummy.txt'],'w');
for frameN = 1:TT
    for i = 1:sP(frameN)
        fprintf(fileOutput,'%s',repmat('A',1,P));
    end
end
fclose(fileOutput);

%output info file
fileInfo = fopen([seqName_W_dt, '_info.txt'],'w');
fprintf(fileInfo,'%s\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\n', seqName, P, F, dt, WW, TT, k, n, evalFrom, evalTo);
fprintf(fileInfo,'videoName\tP\tF\tdt\tW\tT\tk\twindowN\tevalFrom\tevalTo');
fprintf('%s\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\n', seqName, P, F, dt, WW, TT, k, n, evalFrom, evalTo);
fclose(fileInfo);