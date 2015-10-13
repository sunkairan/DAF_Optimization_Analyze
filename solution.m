clear ss
clear Ts
clear Ws
clear Tsx
clear XX
clear AvgXX
clear C
clear lambdaResult
clear lambdaDelta


for i=1:dt:T-dt+1
    ss(floor((i-1)/dt)+1)=sum(s(i:i+dt-1));
end

T=T
W=W
x=x
Ts = floor(T/dt);
Ws = ceil(W/dt);
Tsx = Ts-Ws+1;

XX = getXFromx( x, Ts, Ws, 1, ss );

AvgXX = sum(XX((2*Ws):(Ts-2*Ws+1)),2) / (Ts-4*Ws+2);

C = AvgXX;

lambdaResult(1:Tsx,1:Ws) = 0;

for i=1:Tsx
    for j=1:Ws
        outterSum = 0;
        for t=(i+j-Ws):(i+j-1)
            if(t<1 || t>Ts)
                continue;
            end
            innerSum = 0;
            for tp=(t-Ws+1):t
                if(tp<1 || tp>Tsx)
                    continue;
                end
                innerSum = innerSum + x(tp,t-tp+1);
            end
            innerSum = innerSum*x(i,j)*2/ss(t)/ss(t);
            outterSum = outterSum + innerSum - 2*C*x(i,j)/ss(t);
        end
        lambdaResult(i,j) = outterSum;
        %fprintf(' Lambda(%d,%2d) = %f\n', i, j, outterSum);
    end
end

lambdaResult=lambdaResult;
close all;
figure;plot(lambdaResult(1:Tsx,:)');
axis([1 Ws -0.01 0.01]);


lambdaDelta(1:Tsx,1:Ws) = 0;

for i=1:Tsx
    for j=1:Ws

        Cij = 0;

        for t=(i+j-Ws):(i+j-1)
            
            if(t<1 || t>Ts)
                continue;
            end
            
            Cij = Cij + C/ss(t);
        end

        %Cij

        outterSum = 0;
        for t=(i+j-1):(-1):(i+j-Ws)
            
            if(t<1 || t>Ts)
                continue;
            end
            
            %fprintf('+ 1/[s(%2d)]^2 * ( ', t);
            innerSum = 0;
            for tp=t:(-1):(t-Ws+1)
                
                if(tp<1 || tp>Tsx)
                    continue;
                end
                
                innerSum = innerSum + x(tp, t-tp+1);
                %fprintf('+ x(%2d,%2d) ', tp, t-tp+1);
            end
            outterSum = outterSum + innerSum / ss(t) / ss(t);
            %fprintf(')\n');
        end

        lambdaDelta(i,j) = outterSum - Cij;

    end
end

figure;plot(lambdaDelta(1:Tsx,:)');
axis([1 Ws -0.01 0.01]);


% solution

clear b
b(1:Tsx,1:Ws) = 0;

for t1=(2*Ws):(Ts-2*Ws+1)
    for t2=(t1-Ws+1):t1
        b(t2,t1-t2+1) = b(t2,t1-t2+1) + 1/(ss(t1)*(Ts-4*Ws+2));
    end
end

clear a
clear c
c(1:Tsx,1:Tsx,1:Ws) = 0;

for t=(2*Ws):(Ts-2*Ws+1)
    a(1:Tsx,1:Ws) = 0;
    for t0=(t-Ws+1):t
        a(t0,t-t0+1) = a(t0,t-t0+1) + 1/ss(t);
    end
    c(t,:,:) = a - b;
end

clear d
d(1:(Tsx*Ws),1:(Tsx*Ws)) = 0;

for p=1:Tsx
    for q=1:Ws
        pq = (p-1)*Ws+q;
        for t=(2*Ws):(Ts-2*Ws+1)
            for i=(Ws+1):(Ts-2*Ws+1)
                for j=1:Ws
                    ij = (i-1)*Ws+j;
                    d(pq,ij) = d(pq,ij) + 2*c(t,p,q)*c(t,i,j);
                end
            end
        end
    end
end

clear topright
clear negone;
negone(1:Ws,1:Tsx) = 0;
negone(:,1) = -1;
topright = negone;
for i=2:Tsx
    topright = [topright; circshift(negone,[0 i-1]) ];
end

clear bottomleft
clear posone
posone = -negone';
bottomleft = posone;
for i=2:Tsx
    bottomleft = [bottomleft circshift(posone,[i-1 0]) ];
end

coefs = [d, topright;
         bottomleft,zeros(Tsx)];
consts= [zeros(Tsx * Ws,1);
         ones(Tsx,1)];


clear oneLine
oneLine = zeros(1,(1+Ws)*Tsx);
oneLine(1) = 1;
for i=1:(Ws-1)
    for j=1:(Ws-1)
        ij = (i-1)*Ws + j;
        coefs(ij,:) = circshift(oneLine,[0 ij-1]);
        ijt = Tsx*Ws+1 - ij;
        coefs(ijt,:) = circshift(oneLine,[0 ijt-1]);
    end
end

for i=Ws:(2*Ws-1)
    for j=1:(2*Ws-i-1)
        ij = (i-1)*Ws + j;
        coefs(ij,:) = circshift(oneLine,[0 ij-1]);
        ijt = Tsx*Ws+1 - ij;
        coefs(ijt,:) = circshift(oneLine,[0 ijt-1]);
    end
end

solu_x = coefs\consts;
    
% check computation

clear x_vect
clear x0_vect
clear lambdaCompute
clear lambdaCompute0

x_vect = reshape(x',1,Tsx*Ws);
x0_vect = reshape(x0',1,Tsx*Ws);
lambdaCompute(1:Tsx,1:Ws) = 0;
lambdaCompute0(1:Tsx,1:Ws) = 0;
for p=1:Tsx
    for q=1:Ws
        pq = (p-1)*Ws+q;
        lambdaCompute(p,q) = sum(d(pq,:) .* x_vect);
        lambdaCompute0(p,q) = sum(d(pq,:) .* x0_vect);
    end
end
figure;plot(lambdaCompute(2*Ws:Tsx-2*Ws+1,:)');
axis([1 Ws -0.01 0.01]);

figure;plot(lambdaCompute0(2*Ws:Tsx-2*Ws+1,:)');
axis([1 Ws -0.01 0.01]);
