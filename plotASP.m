%close all
clear X0_so
clear X0noint_so
clear X_so
clear Xnoint_so
clear X0_pf
clear X0noint_pf
clear X_pf
clear Xnoint_pf
clear s

seqName = 'foreman';
ddt = 5;
WW = 20;

load([seqName,'_seq_br.mat']);
TT = size(s,2);
range = [2*WW+1,TT-2*WW];

% bit rate
figure;plot(s);xlim(range);ylim([0,20000]);xlabel('Frame no.');ylabel('Bits');

% slope only
load(['FO_OptResult_T',num2str(TT),'_W',num2str(WW),'_dt',num2str(ddt),'_',seqName,'.mat']);
norm_s = s./(sum(s)/size(s,2));
[X0_so, X0noint_so] = getXFromx( x0, T, W, dt, norm_s );
[X_so , Xnoint_so] = getXFromx( x, T, W, dt, norm_s );

% per-frame
load(['OptResult_T',num2str(TT),'_W',num2str(WW),'_dt',num2str(ddt),'_',seqName,'.mat']);
norm_s = s./(sum(s)/size(s,2));
[X0_pf, X0noint_pf] = getXFromx( x0, T, W, dt, norm_s );
[X_pf , Xnoint_pf] = getXFromx( x, T, W, dt, norm_s );

% non-opt
% X0

% block
load(['FO_OptResult_T',num2str(TT),'_W',num2str(WW),'_dt',num2str(WW),'_',seqName,'.mat']);
norm_s = s./(sum(s)/size(s,2));
[X0_block, X0noint_block] = getXFromx( x0, T, W, dt, norm_s );
[X_block , Xnoint_block] = getXFromx( x, T, W, dt, norm_s );

figure;
plot(X0noint_block.*WW,'k');hold on;
plot([1:TT],X0_so.*ddt,'r',[1:TT],X_pf.*ddt,'b',[1:TT],X_so.*ddt,'g');hold on;
xlim(range);
%xlim([1,T]);
ylim([0.5,2]);
xlabel('Frame no.');ylabel('Accumulated Sampling Probability');

legend('non-overlap (block coding)','uniform within windows', 'per-frame optimization', 'slope-only optimization');