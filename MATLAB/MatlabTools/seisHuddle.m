%% This is to do the seismic huddle test
addpath /cvs/cds/project/mDV/extra
%% LOAD seismic

% Columns: STS2_X, _Y, _Z STS2B_X, _Y, _Z
load sts_huddle.mat
srate = oot(1).rate;
z = oot; clear oot

target = z(1).data;
x2 = z(4).data;
y2 = z(5).data;
z2 = z(6).data;

%% Do software rotation
theta = -3.2* pi/180;
Rz = zeros(3,3);   % rotate around the z-axis
Rz(1,1) = cos(theta); Rz(1,2) = -sin(theta);
Rz(2,1) = sin(theta); Rz(2,2) =  cos(theta);

% rotate the witness seismometer
v1 = [z(4).data z(5).data z(6).data];
v2 = Rz * v1'; v2 = v2';
z(4).data = v2(:,1);
z(5).data = v2(:,2);
z(6).data = v2(:,3);

%% PWELCH to prove that something good is happening
nfft = srate * 64;

x = target;
x2 = z(4).data;

[p1,f] = pwelch(x,hanning(nfft),nfft/2,nfft,srate);
[p2,f] = pwelch(x2,hanning(nfft),nfft/2,nfft,srate);

disp('Starting FD subtraction...')
%[t12, f] = tfestimate(x,y,...
%                    hanning(nfft), nfft/2, nfft, srate);
%[c12, f] = mscohere(x,y,...
%                    hanning(nfft), nfft/2, nfft, srate);
[sub12 ,subf, vvv] = f_domainsubtract(x, x2, ...
                                hanning(nfft), nfft, srate, 'noplots');
mcal = 2.4e-9;
p1 = sqrt(vvv.pxx) .* mcal;
p2 = sqrt(vvv.pyy) .* mcal;

% sqrt(2) factor here to account for the noise of 2 seismometers
sub12 = sqrt(sub12) .* mcal / sqrt(2);

%% PLOT
figure(111)

% reference noise curve from manufacturer (via Stanford guys)
load sts_noise

top = subplot('Position',[0.13, 0.32, 0.82, 0.6]);
loglog(f, p1, 'b',...
       f, p2, 'r',...
       subf, sub12,'g',...
       noise_f,sts_noise,'k-*')
grid
set(top,'XTickLabel',[]);
ylabel('(m/s)/\surdHz')
axis([0.01 30 1e-12 1e-5])
title('STS2 Huddle')
legend('STS2',...
       'STS2B',...
       'Residual',...
       'Manu. Spec',...
       'Location','SouthWest')
   
bottom = subplot('Position',[0.13,0.1,0.82,0.2]);
loglog(f,1-vvv.cxy,'m')
axis([0.01 30 1e-6 1])
grid
set(gca,'YTick',[1e-6 1e-5 1e-4 1e-3 1e-2 1e-1 1])
xlabel('Frequency [Hz]')
ylabel('(1-Coherence)')

orient tall
