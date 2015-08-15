function [freq,tfs,cohs,startTime,measDuration] = huddletf(respChans,direction,startTime)

sampleFreq = 2048;       
numAvgs = 10;
freqRes = 0.05;
freqRange = [0.05 30];
percentOverlap = 50; % %
windowType = @tukeywin;
tukeyAlpha = 0.3;
detrendOrder = 2;

switch direction 
    case 'H'
        refChan = {'G1:HUD-SIGNL_STS_X_IN1_DAQ'}
    case 'V'
        refChan = {'G1:HUD-SIGNL_STS_Z_IN1_DAQ'}
end

%% Calculate additional measurement parameters
nChans = length(respChans);
channels = {refChan{:},respChans{:}}';
respInds = 2:nChans+1;

oneMeasPeriod = 1 / freqRes;
measDuration = numAvgs*oneMeasPeriod;

if ischar(startTime)
    newMeas = true;
    % This will take take the data from DAQ channel.  Still have to wait at
    % leasy measDuration for good data to be acquired.
    startTime = gps(['now - ' num2str(measDuration)]);  
end


dt = 1/sampleFreq;
time = dt:dt:measDuration;
time = time(:);

nyquistFreq = sampleFreq/2;
nFFTs = sampleFreq / freqRes;
nOverlap = nFFTs * (percentOverlap / 100);
chunkDuration = (1 / freqRes)*(1+(numAvgs)*(1 - (percentOverlap / 100)));
theWindow = window(windowType,nFFTs,tukeyAlpha);
freq = 0:freqRes:nyquistFreq;

%% Grab Sensor calibrations
% load(sensorDefsFileName)
% stsModel_f = abs(squeeze(freqresp(STS2_position_response,freq*2*pi)));
% gs13Model_f = abs(squeeze(freqresp(GS13_position_response,freq*2*pi)));
% clear freq

%% Get Data
disp(['Getting ' num2str(measDuration) ' secs of data'])
rawData = get_data(channels,'raw',startTime,measDuration);
%%

for iChan = respInds
% Detrend the raw time series data
    ref.fitCoeffs = polyfit(time, rawData(1).data, detrendOrder);  
    ref.fit = polyval(ref.fitCoeffs, time); 
    ref.ts = rawData(1).data - ref.fit;   % detrend

    test.fitCoeffs = polyfit(time, rawData(iChan).data, detrendOrder);  
    test.fit = polyval(test.fitCoeffs, time); 
    test.ts = rawData(iChan).data - test.fit;   % detrend
    
    [ttfs(:,iChan-1), tfreq] = tfestimate(ref.ts,test.ts,theWindow,nOverlap,nFFTs,sampleFreq);
    [tcohs(:,iChan-1), tfreq] = mscohere(ref.ts,test.ts,theWindow,nOverlap,nFFTs,sampleFreq);
end

minFreqInd = find(tfreq <= freqRange(1), 1,'last');
maxFreqInd = find(tfreq >= freqRange(2), 1,'first');
freq = tfreq(minFreqInd:maxFreqInd);

for iChan = respInds-1
    tfs(:,iChan) = ttfs(minFreqInd:maxFreqInd,iChan);
    cohs(:,iChan) = tcohs(minFreqInd:maxFreqInd,iChan);
end