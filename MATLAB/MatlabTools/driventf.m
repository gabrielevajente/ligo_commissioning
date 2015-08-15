function [freq,tfs,cohs,startTime,measDuration] = driventf(respChans,startTime)

svnDir = '/opt/svncommon/seisvn/seismic/';
% scriptsDir = [svnDir 'HAM-ISI/X2/Scripts/Schroeder_Phase_Scripts']; 
scriptsDir = [svnDir 'Common/MatlabTools/Schroeder_Phase_Scripts'];

sampleFreq = 2048;
freqRes = 0.1; % Hz
freqRange = [50 150];
numAvgs = 4;

numGs13s = length(respChans);
excChan = 'G1:HUD-DRIVE_A_EXC';
channels = {[excChan '_DAQ'],...
            respChans{:}}';
gs13Inds = 2:numGs13s+1;
excInd = 1;
        
driveAmp = 120%500;  % cts (500cts = ~200 mVpkpk)        
Nramp = 0; % Defult from awgstream.
isFork = false;

percentOverlap = 50; % %
windowType = @tukeywin;
tukeyAlpha = 0.3;
detrendOrder = 2;

if ischar(startTime)
    newMeas = true;
    startTime = gps('now + 10');
end

%%
addpath(scriptsDir)


%% Calculate additional measurement parameters

oneMeasPeriod = 1 / freqRes;
measDuration = numAvgs*oneMeasPeriod;

dt = 1/sampleFreq;
time = dt:dt:measDuration;
time = time(:);

nyquistFreq = sampleFreq/2;
nFFTs = sampleFreq / freqRes;
nOverlap = nFFTs * (percentOverlap / 100);
chunkDuration = (1 / freqRes)*(1+(numAvgs)*(1 - (percentOverlap / 100)));
theWindow = window(windowType,nFFTs,tukeyAlpha);
freq = 0:freqRes:nyquistFreq;

%% Get Drive Time Series

normExc = get_comb_timeseries(sampleFreq, freqRes, numAvgs, freqRange(1), freqRange(2));

exc = driveAmp*normExc;

%% Drive
tic
[startTime, run_time] = awgstream(excChan, sampleFreq, startTime, exc, numAvgs, Nramp, isFork);
toc

%% Get Data

rawData = get_data(channels,'raw',startTime,measDuration);

%% Get Transfer Functions 

for iGS13 = gs13Inds
% Detrend the raw time series data
    ref.fitCoeffs = polyfit(time, rawData(excInd).data, detrendOrder);  
    ref.fit = polyval(ref.fitCoeffs, time); 
    ref.ts = rawData(excInd).data - ref.fit;   % detrend
    
    test.fitCoeffs = polyfit(time, rawData(iGS13).data, detrendOrder);  
    test.fit = polyval(test.fitCoeffs, time); 
    test.ts = rawData(iGS13).data - test.fit;   % detrend
    
    [ttfs(:,iGS13-1), tfreq] = tfestimate(ref.ts,test.ts,theWindow,nOverlap,nFFTs,sampleFreq);
    [tcohs(:,iGS13-1), tfreq] = mscohere(ref.ts,test.ts,theWindow,nOverlap,nFFTs,sampleFreq);
end

minFreqInd = find(tfreq <= freqRange(1), 1,'last');
maxFreqInd = find(tfreq >= freqRange(2), 1,'first');
freq = tfreq(minFreqInd:maxFreqInd);

tfPlotVect = [];
cohPlotVect = [];
for iGS13 = gs13Inds-1; 
    tfs(:,iGS13) = ttfs(minFreqInd:maxFreqInd,iGS13);
    cohs(:,iGS13) = tcohs(minFreqInd:maxFreqInd,iGS13);
    
    tfPlotVect = [tfPlotVect tfs(:,iGS13)];
    cohPlotVect = [cohPlotVect cohs(:,iGS13)];
end
    
%%   Plotting is performed in gs13qatest.m
plotRange = [75 125];

figure
subplot(211)
ll=semilogy(freq, abs(tfPlotVect));
legend(respChans,'Interpreter','None')
set(ll,'LineWidth',2)
grid on
xlim(plotRange)
%ylim(magRange)
xlabel('Frequency (Hz)')
ylabel('Magnitude')

subplot(212)
ll = plot(freq,180/pi*angle(tfPlotVect));
set(ll,'LineWidth',2)
grid on
xlim(plotRange)
ylim([-185 185])
xlabel('Frequency (Hz)')
ylabel('Magnitude')
