% Outputs the optimization results from reading a 'FO_OptResult_**.mat' file.
% As in optimization results part in paper. 
% Need to pre-load the 'FO_OptResult_**.mat' file:
%   Must have s, T, W, dt (UN-downscaled); 
%   and resulting prob.s: x, x0 (matrix of sampling prob.s, not slopes). 
% sRatio is the scaling factor to adjust original s to fit with prob.s.
% resolution is the rate of output optimizaztion results of windows.
% xScope defines the scope of frames showing in the resulting figure.


load('FO_OptResult_T300_W30_dt1_foreman');
%load('NMPC_Cheat_L10_OptResult_F0_T300_W30_dt1_foreman.mat');
%load('Predict_Cheat_L20_OptResult_F0_T300_W20_dt1_foreman.mat');
%load('NMPC_L10_OptResult_F0.75_T300_W30_dt1_foreman.mat');
%load('Predict_L10_OptResult_F0.75_T300_W30_dt1_foreman.mat');

close all
clear norm_s ss rW rT
clear X X0 X0noint Xnoint x x0 vx vx0 VX VX0 VX0noint VXnoint
clear drawSamplingDist drawSAP drawQuality

schemeFileNames_Legends_Colors_Line_Width = {
  % scheme file                                                 % legend            % color         % line  % width % group
    'Predict_L10_OptResult_F0.75_T300_W30_dt1_foreman.mat'      'DAF-O'             [0 0 1]         '--'    0.35     % 'cyan'
    'Predict_Cheat_L20_OptResult_F0_T300_W30_dt1_foreman.mat'   'DAF-M'             [1 0 0]         '-.'    0.35     % 'green'
    'FO_OptResult_T300_W30_dt1_foreman.mat'                     'DAF'               [0 1 0]         ':'    1.6     % 'orange'
    %'FO_OptResult_T300_W30_dt30_foreman.mat'                    'Block'             [1 0.5 0]         '-'    1     % 'magenta'
};
DAFL_Names_Legends_Colors_Line_Width = {         'dummy.mat'    'DAF-L'             [0 0 0]         '-'    0.35  };
resolution = 1/4;
%xScope = [W+1,T-W];
xScope = [1,T];
drawSamplingDist = 0;
drawASP = 1;
drawQuality = 0;
drawDecodingRatio = 0;
numOfSchemes = size(schemeFileNames_Legends_Colors_Line_Width,1);

%% prepare parameters
for schemeNum = 1:numOfSchemes
    load(schemeFileNames_Legends_Colors_Line_Width{schemeNum,1});
    vx0{schemeNum} = x0; 
    vx{schemeNum}  = x;
    VT{schemeNum} = T;
    VW{schemeNum} = W;
    vdt{schemeNum} = dt;
    norm_s = s./(sum(s)/size(s,2));
    [VX0{schemeNum}, VX0noint{schemeNum}] = getXFromx( x0, T, W, dt, norm_s );
    [VX{schemeNum} , VXnoint{schemeNum}] = getXFromx( x, T, W, dt, norm_s );
    VX0{schemeNum} = VX0noint{schemeNum};
    VX{schemeNum} =  VXnoint{schemeNum};
    sRatio = 3/max(norm_s);
    ss = norm_s*sRatio;
end

%% Draw sampling distributions for each window
if(drawSamplingDist)
    for schemeNum = 1:numOfSchemes
        x = vx{schemeNum};
        x0 = vx0{schemeNum};
        W = VW{schemeNum};
        T = VT{schemeNum};
        dt = vdt{schemeNum};
        rW = ceil(W/dt);
        rT = floor(T/dt);
        if (dt==W)
            continue;
        end
        figure;
        hold on;
        for i=1:ceil(rW*resolution)*dt:rT*dt-rW*dt+1
            plot([i:i+rW*dt-1],interp1([i:dt:i+rW*dt-1], x(floor((i-1)/dt)+1,:), [i:i+rW*dt-1]),'r', ...
                 [i:i+rW*dt-1],interp1([i:dt:i+rW*dt-1], x0(floor((i-1)/dt)+1,:), [i:i+rW*dt-1]),'b');
        end
        legend('trend of the bit rate' , 'optimized distributions', 'uniform distributions');
        title(schemeFileNames_Legends_Colors_Line_Width{schemeNum,2});
        hold off;
        xlim(xScope);
        xlabel('Frame no.');
        ylabel('Sampling Prob. within Windows');
    end
end

%% Draw relative sampling distributions (ASP) for each window
if(drawASP)
    figure;plot([1:T],s./1024.*30,'k-');hold on;
    xlabel('Frame no.');
    ylabel('bit rate (kbps)');
    xlim(xScope);
    for schemeNum = 1:numOfSchemes
        W = VW{schemeNum};
        T = VT{schemeNum};
        dt = vdt{schemeNum};

        rW = ceil(W/dt);
        rT = floor(T/dt);
        x = vx{schemeNum};
        x0 = vx0{schemeNum};
        if (dt==W)
            continue;
        end
        figure;
        
        for i=1:ceil(rW*resolution)*dt:rT*dt-rW*dt+1
            plot([i:i+rW*dt-1],interp1([i:dt:i+rW*dt-1],x(floor((i-1)/dt)+1,:)./x0(floor((i-1)/dt)+1,:), [i:i+rW*dt-1]),'Color',schemeFileNames_Legends_Colors_Line_Width{schemeNum,3});hold on;
            %plot([i:i+rW*dt-1],interp1([i:dt:i+rW*dt-1],x0(floor((i-1)/dt)+1,:)./x0(floor((i-1)/dt)+1,:),[i:i+rW*dt-1]),'b');hold on;
        end

        %legend('trend of the bit rate' , 'optimized distributions', 'uniform distributions');
        %title(schemeFileNames_Legends_Colors_Line_Width{schemeNum,2});

        hold off;
        xlabel('Frame no.');
        ylabel('Sampling Prob.');
        xlim(xScope);
    end
end

%% Draw video quality results using the sampling distributions
if(drawQuality)
    figure;
    for schemeNum = 0:numOfSchemes
        if(schemeNum == 0)
            X = VX0{1};
            lineTp = DAFL_Names_Legends_Colors_Line_Width{4};
            colorTp = DAFL_Names_Legends_Colors_Line_Width{3};
            lineWTp = DAFL_Names_Legends_Colors_Line_Width{5};
            legendTp{schemeNum+1} = [DAFL_Names_Legends_Colors_Line_Width{2} ' (var: ' num2str(var(X(W:T-W+1)),2) ')'];
        else
            X = VX{schemeNum};
            lineTp = schemeFileNames_Legends_Colors_Line_Width{schemeNum,4};
            colorTp = schemeFileNames_Legends_Colors_Line_Width{schemeNum,3};
            lineWTp = schemeFileNames_Legends_Colors_Line_Width{schemeNum,5};
            legendTp{schemeNum+1} = [schemeFileNames_Legends_Colors_Line_Width{schemeNum,2} ' (var: ' num2str(var(X(W:T-W+1)),2) ')'];
        end
        plot(1:T,X, lineTp, 'Color', colorTp, 'LineWidth', lineWTp);
        hold on;
    end
    %plot(ss*sRatio,'g'); hold off;
    xlim(xScope);
    hold off;
    xlabel('Frame no.');
    ylabel('ASP');
    legend(legendTp,'Location','southwest');
end


%% Draw ASP coverage ratio
if(drawDecodingRatio)
    figure;
    X0 = VX0{1};
    minASP = min(X0(W:T-W+1));
    maxASP = max(X0(W:T-W+1));
    for schemeNum = 0:numOfSchemes
        if(schemeNum == 0)
            X = VX0{1};
            lineTp = DAFL_Names_Legends_Colors_Line_Width{4};
            colorTp = DAFL_Names_Legends_Colors_Line_Width{3};
            lineWTp = DAFL_Names_Legends_Colors_Line_Width{5};
            legendTp{schemeNum+1} = DAFL_Names_Legends_Colors_Line_Width{2};
        else
            X = VX{schemeNum};
            lineTp = schemeFileNames_Legends_Colors_Line_Width{schemeNum,4};
            colorTp = schemeFileNames_Legends_Colors_Line_Width{schemeNum,3};
            lineWTp = schemeFileNames_Legends_Colors_Line_Width{schemeNum,5};
            legendTp{schemeNum+1} = schemeFileNames_Legends_Colors_Line_Width{schemeNum,2};
        end

        xPercents = zeros(1,101);
        for i=0:100
           level = 1/maxASP + (1/minASP - 1/maxASP)*i/100;
           xPercents(i+1) = numel(find(X(W:T-W+1)>=(1/level)))/(T-2*W+2);
        end
        plot([0:0.01:1],xPercents,lineTp, 'Color', colorTp, 'LineWidth', lineWTp);
        hold on;
    end
    hold off;
    xlabel('normalized code rate (c)');
    ylabel('ASP coverage ratio (\rho(c))');
    legend(legendTp,'Location','southeast');
end
fprintf('Seq: %s, W: %d.\n',seqName,W);
pause(0.1);