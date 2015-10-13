% Overall controller of all optimizations

clear all
close all

Names = [ 'akiyo     ';  %300
          'bus       ';  %150
          'coastguard';  %300
          %'football  ';  %90
          'foreman   ';  %300
          'mobile    ';  %300
          'news      ';  %300
          %'stefan    ';  %90
          'sine      ']; %300

namesCell = cellstr(Names);
for i = 1:size(Names,1);
    seqName = char(namesCell(i));
    dt = 1;
    optimize;
end
