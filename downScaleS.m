function [TT, WW, ss] = downScaleS(T, W, dt, s)
% downScaleS downscales orginal T, W, and s by the factor of dt. 
% Output:
%   S is the sum of original s in dt packets.
    for i=1:dt:T-dt+1
        ss(floor((i-1)/dt)+1)=sum(s(i:i+dt-1));
    end
    TT = floor(T/dt);
    WW = ceil(W/dt);
end
