close all
clear ss
clear X
clear X0
clear X1
clear x1

%% Draw video quality results using the sampling distributions
X0 = getXFromx( x0, T, W, dt, s );
X = getXFromx( x, T, W, dt, s );

timet=4;

for i=1:size(x0,1)
    x1(i,:) = (((x0(i,:)*size(x0,2)).^timet)/size(x0,2))./sum(((x0(i,:)*size(x0,2)).^timet)/size(x0,2));
end

X1 = getXFromx( x1, T, W, dt, s );

sRatio = 3/max(s);
figure;plot(X0,'b');hold on; plot(X,'r'); plot(X1,'c');

ss = s;
plot(ss*sRatio,'g'); hold off;

%% Draw sampling distributions for each window
resolution = 1/2;

figure;plot([1:T],ss(1:T)*sRatio,'g');hold on;

rW = ceil(W/dt);
rT = floor(T/dt);
for i=1:ceil(rW*resolution)*dt:rT*dt-rW*dt+1
    plot([i:i+rW*dt-1],interp1([i:dt:i+rW*dt-1],x(floor((i-1)/dt)+1,:), [i:i+rW*dt-1]),'r', ...
         [i:i+rW*dt-1],interp1([i:dt:i+rW*dt-1],x0(floor((i-1)/dt)+1,:),[i:i+rW*dt-1]),'b', ...
         [i:i+rW*dt-1],interp1([i:dt:i+rW*dt-1],x1(floor((i-1)/dt)+1,:),[i:i+rW*dt-1]),'c');
end

hold off;

%% Draw relative sampling distributions for each window
resolution = 1/2;

figure;plot([1:T],ss(1:T)*sRatio,'g');hold on;

rW = ceil(W/dt);
rT = floor(T/dt);
for i=1:ceil(rW*resolution)*dt:rT*dt-rW*dt+1
    plot([i:i+rW*dt-1],interp1([i:dt:i+rW*dt-1],x(floor((i-1)/dt)+1,:)./x0(floor((i-1)/dt)+1,:), [i:i+rW*dt-1]),'r', ...
         [i:i+rW*dt-1],interp1([i:dt:i+rW*dt-1],x0(floor((i-1)/dt)+1,:)./x0(floor((i-1)/dt)+1,:),[i:i+rW*dt-1]),'b', ...
         [i:i+rW*dt-1],interp1([i:dt:i+rW*dt-1],x1(floor((i-1)/dt)+1,:)./x0(floor((i-1)/dt)+1,:),[i:i+rW*dt-1]),'c');
end

hold off;