% Outputs the numerical results of total ASPs from reading a '**Results_**.txt' file.
% As in experiment results part in paper. It goes through some of the
% R and W combinations. DO NOT need to pre-load anything.

%close all
clear all
% Xmesh = [15:5:55];
Ymesh = [0.7:0.025:1.0];
dt='1';
lossRate='0.0';
packetSize='1024';
% foreman mobile akiyo bus coastguard football news stefan
% seqName = 'stefan';
filePrefix = '../results/warmup in time new dd/InTimeResults_';
%filePrefix = 'Results_';

%inputSeq= %[ 'foreman   ';  %300
inputSeq= [ 'mobile    ';  %300
            'akiyo     ';  %300
            'bus       ';  %150
           % 'coastguard';  %300
            'news      ';  %300
            'football  ';  %90
            'stefan    ']; %90
seqCell = cellstr(inputSeq);

inputC = [0.9; 
          0.975; 
          1;
          0.925;
          1;
          1];
      
inputD = [15;
          30;
          15;
          20;
          15;
          20];

% inputC = [0.825 0.875 1; 
%           0.85 0.95 0.975; 
%           0.825 0.925 0.975; 
%           0.95 0.975 1;
%           0.8 0.875 0.95;
%           0.825 0.875 0.925;
%           0.95 0.975 1;
%           0.95 0.975 1];
% inputD = [25 35 50;
%           15 25 35;
%           20 30 40;
%           15 20 25;
%           15 25 35;
%           15 20 30;
%           15 20 25;
%           15 20 25];

for seqi = 1:size(inputSeq,1);
    seqName = char(seqCell(seqi));
    %if(strcmp(seqName,'football') || strcmp(seqName,'stefan'))
    if(strcmp(seqName,'foreman'))
        Xmesh = [15:5:55];
    else
        Xmesh = [15:5:40];
    end
    [X Y Zfix] = readResultFile(filePrefix,seqName, 'fix', lossRate, dt, Xmesh, Ymesh);
    [X Y Znonopt] = readResultFile(filePrefix,seqName, 'nonopt', lossRate, dt, Xmesh, Ymesh);
    [X Y Zfun3] = readResultFile(filePrefix,seqName, 'fun3', lossRate, dt, Xmesh, Ymesh);
    [X Y Zblock] = readResultFile(filePrefix,seqName, 'block', lossRate, '1', Xmesh, Ymesh); % all dt are same for block
    [X Y Zfount] = readResultFile(filePrefix,seqName, 'fount', lossRate, dt, Xmesh, Ymesh);
    
    seqCodeRates = inputC(seqi,:);
    seqDelays = inputD(seqi,:);

    for kk = 1:size(inputC,2)
        inputCC = seqCodeRates(kk);
        inputDD = seqDelays(kk);
        for i=1:size(X,2)
            if (abs(inputDD-X(1,i)) <= 0.001)
                break;
            end
        end

        for j=1:size(Y,1)
            if (abs(inputCC-Y(j,1)) <= 0.001)
                break;
            end
        end

        % Compute code rate
        infoFileName = [seqName '_W' num2str(inputDD) '_dt' dt '_P' packetSize '_info.txt'];
        fileID = fopen(infoFileName,'r');
        fscanf(fileID,'%s',1);
        temp = fscanf(fileID,'%d',9);
        fclose(fileID);
        pkt_numm = temp(6);
        coded_window_numm = temp(7);
        frame_rate = temp(2);
        
        NPacketInWindow = (pkt_numm) /( inputCC * coded_window_numm);
	    dataRate = floor(NPacketInWindow * (frame_rate) * str2num(packetSize) / str2num(dt));
        
        fprintf('%f\t%d\n%f\n%f\n%f\n%f\n\n',Zfun3(j,i),dataRate,Znonopt(j,i),Zfix(j,i),Zblock(j,i),Zfount(j,i));
    end
end