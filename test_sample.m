T = 100;
w = 5;
n = 30;
db(1:T) = floor(4*sin ((1:T)./4)) + 10;

axis([1 T 0 max(db)]);

k = sum(db);

total = 0;
belong(1:k) = 0;
t=0;

for i = 1: k
    if i > total
        total = total + db(t+1);
        t = t+1;
    end
    belong(i)=t;
end

sumPrSample(1:k) = 0;

for i = 1: k
    for t1 = (belong(i) - w + 1: belong(i))
        lsum = 0;
        for t = t1:t1+w-1
            if(t>=1 && t <=T)
                lsum = lsum + db(t);
            end
        end
        sumPrSample(i) = sumPrSample(i) + n / lsum;
    end
end

framePrSample(1:T) = 0;

for i = 1 : k
    framePrSample(belong(i)) = framePrSample(belong(i)) + sumPrSample(i); 
end

for i = 1: T
    framePrSample(i) = framePrSample(i) / db(i);
end

plot(db);hold on;
plot(framePrSample);