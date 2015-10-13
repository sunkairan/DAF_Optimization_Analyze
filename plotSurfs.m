% Outputs the surfaces and curves of total ASPs from reading a '**Results_**.txt' file.
% As in experiment results part in paper. It goes through all the
% combinations. DO NOT need to pre-load anything.
% Input parameters:
%   filePrefix defines the location and type of desired results.
%   seqName is the name of the sequence.
%   dt is the dt.
%   allW is all the possible values of W.
%   allCR is all the possible values of C.
%   Note that the elements in allW and allCR must exists in the results
%       files.
%   schemeFileNames_Legends_Colors_Line_Width is the description of scheme 
%       and the legend text, color and line spec of them in the figures.
% Figure options:
%   convert2second is to shrink the scale of W to convert to unit of second.
%   loss_rate_scale is to shrink the scale of C to simulate loss rate condition.
%   draw*** are the switches to turn on/off the plot for certain figures.
%   ***SubfigureColumns is how many columns to be plotted per row.
%   xScale and yScale define the limits of output surfaces/figures.
%   yLimit defines the range of shown decoding ratio.

close all
clear allW allCR scaledW scaledRC filePrefix xScale yScale allFigHandles allLineHandles
clear schemeFileNames_Legends_Colors_Line_Width_Group
clear X Y Z

%% Input parameters
allW = [20:5:45]; %[15:5:55];  % window size
allCR = [0.7:0.05:0.95]; %[0.7:0.025:1.0] code rate
dt='1';
% 'foreman' 'mobile' 'akiyo' 'bus' 'coastguard' 'news' 'football' 'stefan'
% seqName = 'mobile';
filePrefix = '../results/NMPC/InTimeResults_';
schemeFileNames_Legends_Colors_Line_Width_Group_Legend = {
  % scheme file   % legend            % color         % line  % width % group
    'fun3'          'DAF'               [1 0.5 0]       '^-'    0.35    1   1   % 'orange'
    'nonopt'        'DAF-L'             [0 0 1]         'v-'    0.35    1   1   % 'blue'
    'fix'           'S-LT'              [0 1 1]         '*-'    0.35    2   1   % 'green'
    'fount'         'Expand'            [1 1 0]         's-'    0.35    2   1   % 'cyan'
    'block'         'Block'             [1 0 1]         'o-'    0.35    2   1   % 'magenta'
%     '_NMPC_L20_F0.75'    'NL_{20}F_{.75}'     [1 0 0]         ':'     1.55    3  
%     '_NMPC_L15_F0.75'    'NL_{15}F_{.75}'     [1 0.15 0.15]   ':'     1.25    3
%     '_NMPC_L10_F0.75'    'NL_{10}F_{.75}'     [1 0.3 0.3]     ':'     0.95    3
%     '_NMPC_L5_F0.75'     'NL_{5}F_{.75}'      [1 0.45 0.45]   ':'     0.65    3
%     '_NMPC_L1_F0.75'     'NL_{1}F_{.75}'      [1 0.6 0.6]     ':'     0.35    3
    '_L20_F0.5'     'L_{20}F_{.5}'      [0 0 1]         ':'     1.55    3   0
    '_L15_F0.5'     'L_{15}F_{.5}'      [0.15 0.15 1]   ':'     1.25    3   0
    '_L10_F0.5'     'L_{10}F_{.5}'      [0.3 0.3 1]     ':'     0.95    3   0
    '_L5_F0.5'      'L_{5}F_{.5}'       [0.45 0.45 1]   ':'     0.65    3   0
    '_L1_F0.5'      'L_{1}F_{.5}'       [0.6 0.6 1]     ':'     0.35    3   0
    '_L20_F0.75'    'DAF-O'             [1 0 0]         ':'     1.55    4   1
    '_L15_F0.75'    'L_{15}F_{.75}'     [1 0.15 0.15]   ':'     1.25    4   0
    '_L10_F0.75'    'L_{10}F_{.75}'     [1 0.3 0.3]     ':'     0.95    4   0
    '_L5_F0.75'     'L_{5}F_{.75}'      [1 0 0]         ':'     1.55    4   0%[1 0.45 0.45]   ':'     0.65    4   0
    '_L1_F0.75'     'L_{1}F_{.75}'      [1 0.6 0.6]     ':'     0.35    4   0
    '_L20_F1'       'L_{20}F_{1}'       [1 0 1]         ':'     1.55    5   0
    '_L15_F1'       'L_{15}F_{1}'       [1 0.15 1]      ':'     1.25    5   0
    '_L10_F1'       'L_{10}F_{1}'       [1 0.3 1]       ':'     0.95    5   0
    '_L5_F1'        'L_{5}F_{1}'        [1 0.45 1]      ':'     0.65    5   0
    '_L1_F1'        'L_{1}F_{1}'        [1 0.6 1]       ':'     0.35    5   0
%     '_NMPC_L20_F0'       'NL_{20}F_{0}'       [0 1 0]         '--'    1.55    5
%     '_NMPC_L15_F0'       'NL_{15}F_{0}'       [0.15 1 0.15]   '--'    1.25    5
%     '_NMPC_L10_F0'       'NL_{10}F_{0}'       [0.3 1 0.3]     '--'    0.95    5
%     '_NMPC_L5_F0'        'NL_{5}F_{0}'        [0.45 1 0.45]   '--'    0.65    5
%     '_NMPC_L1_F0'        'NL_{1}F_{0}'        [0.6 1 0.6]     '--'    0.35    5
    '_L20_F0'       'DAF-M'             [0 1 0]         '--'    1.8     6   0
    '_L15_F0'       'L_{15}F_{0}'       [0.2 1 0.2]     '--'    1.00    6   0
    '_L10_F0'       'L_{10}F_{0}'       [0.3 1 0.3]     '--'    0.85    6   0
    '_L5_F0'        'L_{5}F_{0}'        [0.45 1 0.45]   '--'    0.65    6   0
    '_L1_F0'        'L_{1}F_{0}'        [0.6 1 0.6]     '--'    0.35    6   0
};

%% Figure options
convert2second = 1; % e.g. 0, 1
loss_rate_scale = 0.1; % e.g. 0.1
fullScreen = 1;
drawSurface = 1;
    xScale = 1:size(allCR,2);   % show how many data points
    yScale = 1:size(allW,2);
drawAllDelays = 1;
    delaySubfigureColumns = 3;
drawAllCodeRates = 1;
    codeRateSubfigureColumns = 3;
drawSelectedDelays = 1;
    delayList = 35;%[20 30 35 40];
drawSelectedCodeRates = 1;
    codeRateList = 0.8;%[0.95 0.85 0.8 0.75];
    yLimit = [0.7 1.01];    % the range of shown decoding ratio 
showGUI = 0;

%% Init
lossRate='0.0';
global allLineHandles
global allFigHandles
numOfGroups = max([schemeFileNames_Legends_Colors_Line_Width_Group_Legend{1:end,6}]);
numOfSchemes = size(schemeFileNames_Legends_Colors_Line_Width_Group_Legend,1);
allLineHandles = cell(numOfGroups,1);
for i=1:numOfGroups
    allLineHandles{i,1} = 0;
end
allFigHandles = cell(1);
allFigHandles{1} = 0;

if(convert2second == 1)
    scaledW = allW./30;
    timeUnit = 's';
else 
    scaledW = allW;
    timeUnit = 'frm.';
end

scaledCR = allCR .* (1-loss_rate_scale);
X = zeros(size(scaledCR,2),size(scaledW,2));
Y = zeros(size(scaledCR,2),size(scaledW,2));
Z = zeros(numOfSchemes,size(scaledCR,2),size(scaledW,2));

% read result files
for schemeNum = 1:numOfSchemes
    [X Y Z(schemeNum,:,:)] = readResultFile(filePrefix,seqName,  ...
        schemeFileNames_Legends_Colors_Line_Width_Group_Legend{schemeNum,1},  ...
        lossRate, dt, allW, allCR);
%     if(schemeNum == 1)
%         Z(1,find(Z(1,:,:)>0.99))=1.0
%     end
end

Y = Y .* (1-loss_rate_scale);
if(convert2second == 1)
    X = X./30;
end

%% draw the surfaces
if(drawSurface)
figure;
% numFigs = allFigHandles{1} + 1;
% allFigHandles{1} = numFigs;
% allFigHandles{numFigs + 1} = gca;
legendIn = [];
for schemeNum = 1:numOfSchemes
    groupID = schemeFileNames_Legends_Colors_Line_Width_Group_Legend{schemeNum,6};
    allLineHandles{groupID,1} = allLineHandles{groupID,1} + 1;
    allLineHandles{groupID,allLineHandles{groupID,1}+1} = ...
            mesh(X(xScale,yScale),Y(xScale,yScale),squeeze(Z(schemeNum,xScale,yScale)), ...
            'FaceColor',schemeFileNames_Legends_Colors_Line_Width_Group_Legend{schemeNum,3}, ...
            'EdgeColor',imadjust(schemeFileNames_Legends_Colors_Line_Width_Group_Legend{schemeNum,3},[0 1],[0.3 1])');
    if(schemeFileNames_Legends_Colors_Line_Width_Group_Legend{schemeNum,7} == 1)
        legendIn(end+1) = allLineHandles{groupID,allLineHandles{groupID,1}+1};
    end
    hold on;
end
hold off;

legend(legendIn, schemeFileNames_Legends_Colors_Line_Width_Group_Legend{find([schemeFileNames_Legends_Colors_Line_Width_Group_Legend{:,7}]==1),2});
camlight left;
lighting phong;
xlabel(['Delay (' timeUnit ')']);
ylabel('Code Rate');
zlabel('IDR');
ylim([min(scaledCR(xScale)) max(scaledCR(xScale))]);
xlim([min(scaledW(yScale)) max(scaledW(yScale))]);
end

%% Slice for all delays ('delaySubfigureColumns' columns per row)
if(drawAllDelays)
allDelayList = scaledW;
total_delays = size(scaledW,2);

if(fullScreen)
    figure('units','normalized','outerposition',[0 0 1 1]);
else
    figure;
end

for k = 1:total_delays
    delay = allDelayList(k);
    numFigs = allFigHandles{1} + 1;
    allFigHandles{1} = numFigs;
    allFigHandles{numFigs + 1} = ...
        subplot(ceil(total_delays/delaySubfigureColumns),delaySubfigureColumns,k);
    for i=1:size(X,2)
        if (abs(delay-X(1,i)) <= 0.0001)
            break;
        end
    end
    %figure;
    legendIn = [];
    for schemeNum = 1:numOfSchemes
        groupID = schemeFileNames_Legends_Colors_Line_Width_Group_Legend{schemeNum,6};
        allLineHandles{groupID,1} = allLineHandles{groupID,1} + 1;
        allLineHandles{groupID,allLineHandles{groupID,1}+1} = ...
            plot(scaledCR(xScale),squeeze(Z(schemeNum,xScale,i)), ...
            schemeFileNames_Legends_Colors_Line_Width_Group_Legend{schemeNum,4}, ...
            'Color', schemeFileNames_Legends_Colors_Line_Width_Group_Legend{schemeNum,3}, ...  
            'LineWidth', schemeFileNames_Legends_Colors_Line_Width_Group_Legend{schemeNum,5});
        hold on;
        if(schemeFileNames_Legends_Colors_Line_Width_Group_Legend{schemeNum,7} == 1)
            legendIn(end+1) = allLineHandles{groupID,allLineHandles{groupID,1}+1};
        end
    end
    hold off;
    xlim([min(scaledCR(xScale)), max(scaledCR(xScale))]);
    ylim(yLimit);
    %legend(schemeFileNames_Legends_Colors_Line{:,2});
    %xlabel('Code Rate');ylabel('IDR');%title([seqName, ', dt = ',dt,', delay = ',num2str(delay)]);
    if(mod(k,delaySubfigureColumns)==1)     % first column
            ylabel('IDR'); 
    end
    
    if(floor((k-1)/delaySubfigureColumns)+1 >= ceil(total_delays/delaySubfigureColumns)) % last row
            xlabel('Code Rate');
    end
    title(['Delay = ',num2str(delay),' ',timeUnit]);
    if(k==(ceil((delaySubfigureColumns+1)/2)))    % middle
         title(sprintf([seqName '\nDelay = ',num2str(delay),' ',timeUnit]));
    end
end
legend(legendIn, schemeFileNames_Legends_Colors_Line_Width_Group_Legend{find([schemeFileNames_Legends_Colors_Line_Width_Group_Legend{:,7}]==1),2},'Location','southwest');
end

%% Slice for all code rates ('codeRateSubfigureColumns' columns per row)
if(drawAllCodeRates)
allCodeRateList = scaledCR;
total_coderates = size(scaledCR,2);

if(fullScreen)
    figure('units','normalized','outerposition',[0 0 1 1]);
else
    figure;
end
for k = 1:total_coderates
    coderate = allCodeRateList(total_coderates-k+1);
    numFigs = allFigHandles{1} + 1;
    allFigHandles{1} = numFigs;
    allFigHandles{numFigs + 1} = ...
        subplot(ceil(total_coderates/codeRateSubfigureColumns),codeRateSubfigureColumns,k);
    for i=1:size(Y,1)
        if (abs(coderate-Y(i,1)) <= 0.0001)
            break;
        end
    end
    %figure;
    legendIn = [];
    for schemeNum = 1:numOfSchemes
        groupID = schemeFileNames_Legends_Colors_Line_Width_Group_Legend{schemeNum,6};
        allLineHandles{groupID,1} = allLineHandles{groupID,1} + 1;
        allLineHandles{groupID,allLineHandles{groupID,1}+1} = ...
            plot(scaledW(yScale),squeeze(Z(schemeNum,i,yScale)), ...
            schemeFileNames_Legends_Colors_Line_Width_Group_Legend{schemeNum,4}, ...
            'Color', schemeFileNames_Legends_Colors_Line_Width_Group_Legend{schemeNum,3}, ...
            'LineWidth', schemeFileNames_Legends_Colors_Line_Width_Group_Legend{schemeNum,5});
        hold on;
        if(schemeFileNames_Legends_Colors_Line_Width_Group_Legend{schemeNum,7} == 1)
            legendIn(end+1) = allLineHandles{groupID,allLineHandles{groupID,1}+1};
        end
    end
    hold off;
    xlim([min(scaledW(yScale)), max(scaledW(yScale))]);
    ylim(yLimit);
    %legend(schemeFileNames_Legends_Colors_Line{:,2});
    if(mod(k,codeRateSubfigureColumns)==1)     % first column
            ylabel('IDR'); 
    end
    
    if(floor((k-1)/codeRateSubfigureColumns)+1 >= ceil(total_delays/codeRateSubfigureColumns)) % last row
            xlabel(['Delay (' timeUnit ')']);
    end
    title(['Code Rate = ',num2str(coderate)]);
    if(k==(ceil((codeRateSubfigureColumns+1)/2)))    % middle
         title(sprintf([seqName '\nCode Rate = ',num2str(coderate)]));
    end

end
legend(legendIn, schemeFileNames_Legends_Colors_Line_Width_Group_Legend{find([schemeFileNames_Legends_Colors_Line_Width_Group_Legend{:,7}]==1),2},'Location','southwest');
end

%% Slice for a delay
if(drawSelectedDelays)

figure;
if (convert2second == 1)
    delayList = delayList./30;
end
seldelayl = numel(delayList);
seldelayRow = ceil(sqrt(seldelayl));
for k = 1:seldelayl
    delay = delayList(k);
    numFigs = allFigHandles{1} + 1;
    allFigHandles{1} = numFigs;
    allFigHandles{numFigs + 1} = ...
        subplot(seldelayRow,seldelayRow,k);
    for i=1:size(X,2)
        if (abs(delay-X(1,i)) <= 0.01)
            break;
        end
    end
    %figure;
    legendIn = [];
    for schemeNum = 1:numOfSchemes
        groupID = schemeFileNames_Legends_Colors_Line_Width_Group_Legend{schemeNum,6};
        allLineHandles{groupID,1} = allLineHandles{groupID,1} + 1;
        allLineHandles{groupID,allLineHandles{groupID,1}+1} = ...
            plot(scaledCR(xScale),squeeze(Z(schemeNum,xScale,i)), ...
            schemeFileNames_Legends_Colors_Line_Width_Group_Legend{schemeNum,4}, ...
            'Color', schemeFileNames_Legends_Colors_Line_Width_Group_Legend{schemeNum,3}, ...
            'LineWidth', schemeFileNames_Legends_Colors_Line_Width_Group_Legend{schemeNum,5});
        hold on;
        if(schemeFileNames_Legends_Colors_Line_Width_Group_Legend{schemeNum,7} == 1)
            legendIn(end+1) = allLineHandles{groupID,allLineHandles{groupID,1}+1};
        end
    end
    hold off;
    xlim([min(scaledCR(xScale)), max(scaledCR(xScale))]);
    ylim(yLimit);
    %legend('S-LT','DAF-L','DAF','Block','Location','southwest');
    xlabel('Code Rate');ylabel('IDR');%title([seqName, ', dt = ',dt,', delay = ',num2str(delay)]);
    title(['Delay = ',num2str(delay),' ',timeUnit]);

end
legend(legendIn, schemeFileNames_Legends_Colors_Line_Width_Group_Legend{find([schemeFileNames_Legends_Colors_Line_Width_Group_Legend{:,7}]==1),2},'Location','southwest');
end

%% Slice for a code rate
if(drawSelectedCodeRates)

figure;
codeRateList = codeRateList.* (1-loss_rate_scale);
selrcl = numel(codeRateList);
selrcRow = ceil(sqrt(selrcl));
for k = 1:selrcl
    codeRate = codeRateList(k);
    numFigs = allFigHandles{1} + 1;
    allFigHandles{1} = numFigs;
    allFigHandles{numFigs + 1} = ...
        subplot(selrcRow,selrcRow,k);
    for i=1:size(Y,1)
        if (abs(codeRate-Y(i,1)) <= 0.011)
            break;
        end
    end
    legendIn = [];
    for schemeNum = 1:numOfSchemes
        groupID = schemeFileNames_Legends_Colors_Line_Width_Group_Legend{schemeNum,6};
        allLineHandles{groupID,1} = allLineHandles{groupID,1} + 1;
        allLineHandles{groupID,allLineHandles{groupID,1}+1} = ...
            plot(scaledW(yScale),squeeze(Z(schemeNum,i,yScale)), ...
            schemeFileNames_Legends_Colors_Line_Width_Group_Legend{schemeNum,4}, ...
            'Color', schemeFileNames_Legends_Colors_Line_Width_Group_Legend{schemeNum,3}, ...
            'LineWidth', schemeFileNames_Legends_Colors_Line_Width_Group_Legend{schemeNum,5});
        hold on;
        if(schemeFileNames_Legends_Colors_Line_Width_Group_Legend{schemeNum,7} == 1)
            legendIn(end+1) = allLineHandles{groupID,allLineHandles{groupID,1}+1};
        end
    end
    hold off;
    xlim([min(scaledW(yScale)), max(scaledW(yScale))]);
    ylim(yLimit);
    %legend('S-LT','DAF-L','DAF','Block','Location','southeast');
    xlabel(['Delay (' timeUnit ')']);ylabel('IDR');%title([seqName, ', dt = ',dt,', code rate = ',num2str(codeRate)]);
    title(['Code Rate = ',num2str(codeRate)]);
end
legend(legendIn, schemeFileNames_Legends_Colors_Line_Width_Group_Legend{find([schemeFileNames_Legends_Colors_Line_Width_Group_Legend{:,7}]==1),2},'Location','southeast');
end

pause(0.01);

if(showGUI)
    plotSurfs_GUI;
end