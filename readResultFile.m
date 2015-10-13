function [X, Y, Z] = readResultFile(prefix, seqName, scheme, lossRate, dt, Xmesh, Ymesh)
% readResultFile reads the '**Results_**.txt' file for plotSurfs and paperCompareResults
%   prefix, seqName, scheme, lossRate, dt describe the file name;
%   Xmesh, Ymesh define all the possible values of W and C.
% see also: plotSurfs, paperCompareResults.
[X,Y] = meshgrid(Xmesh,Ymesh);
Z=0;

resultName = [prefix, seqName, '_', scheme,'_LR',lossRate,'_dt',dt,'.txt'];
%fprintf(resultName);
fileID = fopen(resultName,'r');
fgets(fileID);
%fgets(fileID); repeatNum = 10;
temp = fscanf(fileID,'%s',3); repeatNum = fscanf(fileID,'%d',1);
num = 0;
Z = ones(size(Ymesh,2),size(Xmesh,2)).*-1;
while(1)
    temp = fscanf(fileID,'%f',repeatNum+2);
    if(numel(temp) ~= repeatNum+2)
        break;
    end
    codeRateIndex = find(abs(Ymesh-temp(2))<= 0.0001);
    windIndex = find(abs(Xmesh-temp(1))<= 0.1);
    if(numel(windIndex)==1 && numel(codeRateIndex)==1)
        Z(codeRateIndex,windIndex) = median(temp(3:repeatNum+2));
        if(Z(codeRateIndex,windIndex)~=-1)
            num = num+1;
        else
            error('Duplicated elements in result file.');
        end
    end
end

if ( num~=(size(Ymesh,2)*size(Xmesh,2)) )
    error('Some of the data points in the input data are not included in the result file.');
end

fclose(fileID);


