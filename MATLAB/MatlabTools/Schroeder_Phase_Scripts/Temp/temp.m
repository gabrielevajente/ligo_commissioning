clear
 '***********************'
ntapes = 5000;
DEC  = 10;
xrange = [1 ntapes/2];
rads = 180/pi;
ts = 1/2000;
 nyquist = 0.5/ts;
XX  = get_comb_timeseries(1/ts, 0.1, 1, 1, 10,tf(1))/90;
fXX = fft(XX);
 
npts = length(XX);
fXX = fXX(1:npts/2);
freq =  nyquist*(1:length(fXX))/length(fXX);
YY = decimate(XX,DEC,ntapes,'fir');
% YY = decimate(XX,DEC,4);

npts_d = length(YY);
fYY = fft(YY)*DEC;
fYY = fYY(1:npts_d/2);
freq_d =  nyquist/DEC*(1:length(fYY))/length(fYY);

 
FIRS = fir1(ntapes,1/DEC);
%freqz(FIRS,1,1000)
FFIRS = fft(FIRS);
FFIRS = FFIRS(1:floor(length(FFIRS)/2));

figure(111)
 
subplot(211)
 
 FIR_freq = nyquist*(1:length(FFIRS))/length(FFIRS);
loglog(FIR_freq,abs(FFIRS),...
       freq,abs(fXX),...
        freq_d,abs(fYY));

 

grid on
set(gca,'XLim',xrange,'YLim',[1E-9 3]);

 

subplot(212)
semilogx(FIR_freq ,rads*angle(FFIRS),...
     freq,rads*angle(fXX),...
     freq_d,rads*angle(fYY));
grid on
set(gca,'XLim',xrange);