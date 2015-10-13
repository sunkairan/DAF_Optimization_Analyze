% Compute degree distribution for LT codes accroding to 'LT codes' paper
close all;
clear all;
%% Ideal Soliton distribution from LT codes
k=300;

rho(1:k) = 0;

rho(1) = 1/k;
for i=2:k
    rho(i)=1/i/(i-1);
end

figure;plot(rho);title('rho');xlim([1,30]);

%% Robust Soliton distribution from LT codes

%M=7;
c=0.4

delta=0.02;

M=floor(sqrt(k)/log(k/delta)/c);
%c=sqrt(k)/log(k/delta)/M

tau(1:k)=0;
mu(1:k)=0;

R = c*log(k/delta)*sqrt(k);

for i=1:M-1
    tau(i) = R/i/k;
end

tau(M) = R*log(R/delta)/k;

figure;plot(tau);title('tau');xlim([1,30]);

maxk = 30;

beta=sum(rho(1:maxk)+tau(1:maxk))

mu(1:maxk)=(rho(1:maxk)+tau(1:maxk))./beta;

figure;plot(mu(1:maxk));title('mu');xlim([1,30]);
for i=1:maxk
    fprintf('%f ',mu(i));
end
fprintf('\n');