% Entrance for performing all predictive optimizations.
%   The input matches predictive_compare_result
% Input:
%   seqName: name of the sequence
%   factors: all the factors of prediction want to loop;
%       factor: 0 is cheating, non-opt or full-opt (means N/A);
%   optLen: 0 is non-opt (original); T is full-opt;
%   full opt: optLen = T & cheating = 2 & factor = 0;
%   non-opt: optLen = 0 & cheating = 0 & factor = 0;
% see also: predictive_compare_result

close all

seqName= 'news';
dt = 1;
cheat1 = 0; 
factors = [0.5 0.75 1]; % prediction factor
allW = [20:5:45];
maxOptLen = 20;

    
% all predictive
for factor = factors
    for W=allW
        for optLen= [1 [5:5:min(W,maxOptLen)]]
            cheat2= 0;
            outputPrefix = ['Predict_L' num2str(optLen) '_OptResult_F' num2str(factor) '_'];
            predictive_len_optimization;
        end
    end
end
    
% all cheat
factor = 0;
for W=allW
    for optLen=[1 [5:5:min(W,maxOptLen)]]
        cheat2= 1;
        cheatLen = 2*W;
        outputPrefix = ['Predict_Cheat_L' num2str(optLen) '_OptResult_F' num2str(factor) '_'];
        predictive_len_optimization;
    end
end