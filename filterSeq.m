function ss = filterSeq(s,dt)
T=size(s,2);
for i=1:dt:(floor(T/dt)*dt-dt+1)
    ss(floor((i-1)/dt)+1)=sum(s(i:i+dt-1));
end

ss = interp1([1:dt:(floor(T/dt)*dt-dt+1)],ss,[1:(floor(T/dt)*dt-dt+1)]);

l=size(ss,2);
for i=(l+1):T
    ss(i) = ss(i-1);
end
figure;plot(ss,'g'); 
end