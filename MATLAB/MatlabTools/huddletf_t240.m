function [freq,tfs,cohs,startTime,measDuration] = huddletf_t240(respChans,freqRange,freqRes,numAvgs)

sampleFreq = 2048;       
percentOverlap = 50; % %
windowType = @tukeywin;
tukeyAlpha = 0.3;
detrendOrder = 2;


%% Calculate additional measurement parameters
nChans = length(respChans);
channels = {respChans{:}};


oneMeasPeriod = 1 / freqRes;
measDuration = numAvgs*oneMeasPeriod;
newMeas = true;
startTime = gps(['now - ' num2str(measDuration)]);

    % This will take the data from DAQ channel .  Still have to wait at
    % least measDuration for good data to be acquired.


dt = 1/sampleFreq;
time = dt:dt:measDuration;
time = time(:);

nyquistFreq = sampleFreq/2;
nFFTs = sampleFreq / freqRes;
nOverlap = nFFTs * (percentOverlap / 100);
chunkDuration  = (1 / freqRes)*(1+(numAvgs)*(1 - (percentOverlap / 100)));
theWindow = window(windowType, nFFTs, tukeyAlpha);
freq = 0:freqRes:nyquistFreq;


%% Grab Sensor calibrations
% load(sensorDefsFileName)
% stsModel_f = abs(squeeze(freqresp(STS2_position_response,freq*2*pi)));
% gs13Model_f = abs(squeeze(freqresp(GS13_position_response,freq*2*pi)));
% clear freq

%% Get Data
disp(['Getting ' num2str(measDuration) ' secs of data'])
rawData = get_data(channels,'raw',startTime-30,measDuration);
%%

% fit the T240 data
for iChan = 1:3
    test_fitCoeffs(iChan,:) = polyfit(time,rawData(iChan).data,detrendOrder);
    test_fit(:,iChan) = polyval(test_fitCoeffs(iChan,:),time);
    test_ts(iChan,:) = rawData(iChan).data(:,1) - test_fit(:,iChan);
end
% fit the STS-2 data
for iChan = 4:6
    ref_fitCoeffs(iChan-3,:) = polyfit(time, rawData(iChan).data, detrendOrder);
    ref_fit(:,iChan-3) = polyval(ref_fitCoeffs(iChan-3,:),time);
    ref_ts(iChan-3,:) = rawData(iChan).data(:,1) - ref_fit(:,iChan-3);
    
end
% compute the T240/STS tranfer function 
for iChan = 1:3
    [ttfs(:,iChan),tfreq] = tfestimate(ref_ts(iChan,:), test_ts(iChan,:),theWindow,nOverlap,nFFTs,sampleFreq);
    [tcohs(:,iChan),tfreq] = mscohere(ref_ts(iChan,:), test_ts(iChan,:),theWindow,nOverlap,nFFTs,sampleFreq);
end
   
    
minFreqInd = find(tfreq <= freqRange(1), 1,'last');
maxFreqInd = find(tfreq >= freqRange(2), 1,'first');
freq = tfreq(minFreqInd:maxFreqInd);

for iChan = 1:3  % respInds-1
    tfs(:,iChan) = ttfs(minFreqInd:maxFreqInd,iChan);
    cohs(:,iChan) = tcohs(minFreqInd:maxFreqInd,iChan);
end