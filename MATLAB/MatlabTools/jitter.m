%% load data
load jitter.mat
% columns: PD SUM, QPD3 P, QPD3 Y, QPD4 P, QPD4 Y, QPD3 SUM, QPD4 SUM

srate = oot(1).rate;
nfft = srate*1;
%% need some functions from here
addpath /cvs/cds/project/mDV/extra/


%% weights for better subtraction
% zs = -2*pi*[1; 1];
% ps = -2*pi*[100; 100];
% [m,p] = bode(zpk(zs,ps,1),2*pi*0.1);
% [zd,pd,kd] = bilinear(zs,ps,1/m,srate);
% [sos1,g1] = zp2sos(zd,pd,kd);
% g1 = real(g1);
% for kk = 1:length(oot);
%   oot(kk).data = g1 * sosfilt(sos1,oot(kk).data);
% end

%% new variable names
pdsum = oot(1).data;
q3p = oot(2).data;
q3y = oot(3).data;
q4p = oot(4).data;
q4y = oot(5).data;
q3sum = oot(6).data;
q4sum = oot(7).data;

%% wf
N = 128; % minimum accurate (statistics of 1) subtraction frequency determined by Fs/N
X = q3sum; % can be matrix of inputs, to do MISO
Y = pdsum; 

display('Calculating WF ...')
tic
[h,r,p] = miso_firlev(N, X, Y);
toc

% one column per input signal
hmat = [];
[rows,cols] = size(X);
for ii = 1:cols;
 hmat(:,ii) = h(N*(ii-1)+1:ii*N);
end

%% filter data
hX = zeros(size(Y));
for jj = 1:cols
  hX = hX + filter(h(1+N*(jj-1):jj*N), 1, X(:,jj));
end

%% plots
figure(1);
[PX,f] = pwelch(X(2048:end),hanning(nfft),nfft/2,nfft,srate);
PX = sqrt(PX);
[PY,f] = pwelch(Y(2048:end),hanning(nfft),nfft/2,nfft,srate);
PY = sqrt(PY);
subtr = Y - hX;
[Psubtr,f] = pwelch(subtr(2048:end),hanning(nfft),nfft/2,nfft,srate);
Psubtr = sqrt(Psubtr);
[PhX,f] = pwelch(hX(2048:end),hanning(nfft),nfft/2,nfft,srate);
PhX = sqrt(PhX);

HR = sos2freqresp(sos1,2*pi*f,srate);
% loglog(f,PY./abs(HR),'r',f,Psubtr./abs(HR),'k'); grid
loglog(f,PX, 'b', ...
       f,PY,'r', ...
       f,PhX, 'g', ...
       f,Psubtr, 'k'); 
grid
xlim([1/(nfft/srate) srate/2])
legend('source', 'target', 'estimate', 'target - estimate');


%%
figure(2)
[Cxy, f] = mscohere(X, Y, hanning(nfft),nfft/2,nfft,srate);
semilogx(f, Cxy)
ylim([0 1]);
xlim([1/(nfft/srate) srate/2])


