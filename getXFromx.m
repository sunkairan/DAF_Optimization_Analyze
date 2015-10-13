function [XX,XXX] = getXFromx( x, T, W, dt, s )
% getXFromx adds up the downscaled distributions in each window, output the non-downscaled total ASP.
% Input:
%   T, W, s is NOT downScaleS-ed; x is downScaleS-ed;
% Output:
%   both output are T (original/non-downscaled) length of ASP;
%   XX (first one) is interp-ed;
%   XXX (second one) is non-interp-ed.

XX(1:T) = 0;    %interp
XXX(1:T) = 0;   %non-interp

[T, W, ss] = downScaleS(T, W, dt, s);

X(1:T) = 0;

for t = 1:T
    for t0 = t-W+1 : t
        if( t0 < 1 || t0+W-1 > T )
            % this window does not exist
            continue;
        else
            X(t) = X(t) + x(t0,t-t0+1);
        end
    end
    X(t) = X(t) / (ss(t)/dt);
end

% up scale X to XX
T = T*dt;
XX = interp1([1:dt:T],X,[1:T]);
XXX= reshape(repmat(X,dt,1), 1, T);

end