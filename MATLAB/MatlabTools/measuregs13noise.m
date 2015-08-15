% Measure aLIGO GS13 Noise
% 
% GS-13s    %% CHANGE BELOW AS APPROPRIATE
% SN     Channel    Note
% XXXV    GS13_A    LIGO Modified
% XXXV    GS13_B    LIGO Modified
% XXXV    GS13_C    Stock
% XXXV    GS13_D    Stock
% XXXH    L4C_A     LIGO Modified
% XXXH    L4C_B     LIGO Modified
% XXXH    L4C_C     Stock
% XXXH    L4C_D     Stock

% STS
% SN
% 109826

close all
clear all
clc

%%
canGetData = true;

svnDir = '/opt/svncommon/seisvn/seismic/'; %% FIXME!!
dataDir = [svnDir 'Common/Data/aLIGO_GS13_TestData/'];


startTime.date = 'Dec 13 2010 00:30:00 UTC';  %% FIXME!!
startTime.str  = '101308-0030UTC';            %% FIXME!!
startTime.gps  = 976321815;                   %% FIXME!!

ifo = 'G1';
system = 'HUD-SIGNL';
sensor = 'GS13';
% geoSN = {'XXXV';'XXXV';'XXXV';'XXXV';...      %% FIXME!!
%          'XXXH';'XXXH';'XXXH';'XXXH'};        %% FIXME!!

geoSN = {'680V';'703V';...      %% FIXME!!(both modified)
         '794H';'820H';};        %% FIXME!!(first modified, second stock)
daq = 'IN1_DAQ';
dof = {'X';'Y';'Z'};

% respChans = {'G1:HUD-SIGNL_GS13_A_IN1_DAQ';...
%              'G1:HUD-SIGNL_GS13_B_IN1_DAQ';...
%              'G1:HUD-SIGNL_GS13_C_IN1_DAQ';...
%              'G1:HUD-SIGNL_GS13_D_IN1_DAQ';...
%              'G1:HUD-SIGNL_L4C_A_IN1_DAQ';...
%              'G1:HUD-SIGNL_L4C_B_IN1_DAQ';...
%              'G1:HUD-SIGNL_L4C_C_IN1_DAQ';...
%              'G1:HUD-SIGNL_L4C_D_IN1_DAQ'};

respChans = {'G1:HUD-SIGNL_L4C_B_IN1_DAQ';...
             'G1:HUD-SIGNL_L4C_D_IN1_DAQ';...
             'G1:HUD-SIGNL_GS13_B_IN1_DAQ';...
             'G1:HUD-SIGNL_GS13_D_IN1_DAQ'};
         
for iRespChan = 1:length(respChans);
    respDataFile{iRespChan} = [dataDir 'gs13sensornoisedata_' startTime.str '_7hrs_' ...
                               sensor '-SN' geoSN{iRespChan} '.mat'];
end

stsSN = '109826';
refChans = {'G1:HUD-SIGNL_STS_X_IN1_DAQ';...
            'G1:HUD-SIGNL_STS_Y_IN1_DAQ';...
            'G1:HUD-SIGNL_STS_Z_IN1_DAQ'};
        
refDataFiles = {[dataDir 'gs13sensornoisedata_' startTime.str '_7hrs_STS2-SN' stsSN '_X.mat'];...
                [dataDir 'gs13sensornoisedata_' startTime.str '_7hrs_STS2-SN' stsSN '_Y.mat'];...
                [dataDir 'gs13sensornoisedata_' startTime.str '_7hrs_STS2-SN' stsSN '_Z.mat']};

sampleFreq = 256;
numAvgs = 50;
freqRes = 0.002;
freqRange = [0.005 100];
percentOverlap = 50; % Percent
windowType = @tukeywin;
tukeyAlpha = 0.3;
detrendOrder = 2;

nFIRTaps = 128;

%%
nChans = length(respChans);
channels = {refChans{:},respChans{:}}';
respInds = (length(refChans)+1):nChans+length(refChans);

oneMeasPeriod = 1 / freqRes;
measDuration = numAvgs*oneMeasPeriod;
%%
dt = 1/sampleFreq;
time = dt:dt:measDuration;
time = time(:);

%%
nyquistFreq = sampleFreq/2;
nFFTs = sampleFreq / freqRes;
nOverlap = nFFTs * (percentOverlap / 100);
chunkDuration = (1 / freqRes)*(1+(numAvgs)*(1 - (percentOverlap / 100)));
theWindow = window(windowType,nFFTs,tukeyAlpha);
freq = 0:freqRes:nyquistFreq;

%%
if canGetData
    for iRefChan = 1:length(refChans)
        disp(['Getting STS2 ' dof{iRefChan} ' Data ...']);
        channel = refChans{iRefChan};
        refData = get_data(channel,'raw',startTime.gps,measDuration);
        refData.data = decimate(refData.data,...
                                refData.rate/sampleFreq, ...
                                'FIR');
        refData.rate = sampleFreq;
        disp(['Saving STS2 ' dof{iRefChan} ' Data ...']);
        save(refDataFiles{iRefChan},'refData','channel','startTime','measDuration');
    end
    for iRespChan = 1:length(respChans)
        disp(['Getting GS13' channels{iRespChan} ' Data ...'])
        channel = respChans(iRespChan);
        respData = get_data(respChans(iRespChan),'raw',startTime.gps,measDuration);
        respData.data = decimate(respData.data,...
                                 respData.rate/sampleFreq, ...
                                 'FIR');
        respData.rate = sampleFreq;
        disp(['Saving GS13' channels{iRespChan} ' Data ...'])
        save(respDataFile{iRespChan},'respData','channel','startTime','measDuration');
    end
    disp('Done getting Data.')
        
else
    dataStruct = load(refDataFiles);
    refData.data = dataStruct.refData.data;
    refData.sensor = ['STS-' stsSN];
    refData.channel = refChan; 
    refData.rate = dataStruct.refData.rate;
    
    for iRespChan = 1:4
        dataStruct = load(respDataFile{iRespChan});
        respData(iRespChan).data = dataStruct.respData.data;
        respData(iRespChan).sensor = ['GS13-' geoSN{iRespChan}];
        respData(iRespChan).channel = respChans{iRespChan};
        respData(iRespChan).rate = dataStruct.respData.rate;
        clear dataStruct
    end 
end

%%

% % Detrend the raw time series data
% ref.fitCoeffs = polyfit(time, refData.data, detrendOrder);
% ref.fit = polyval(ref.fitCoeffs, time);
% ref.ts = refData.data - ref.fit;   % detrend
% 
% for iRespChan = 1:length(respChans)
%     % Detrend the raw time series data
%     test.fitCoeffs = polyfit(time, respData(iRespChan).data, detrendOrder);  
%     test.fit = polyval(test.fitCoeffs, time); 
%     respData(iRespChan).ts = respData(iRespChan).data - test.fit;   % detrend
%     
%     disp(['   Calculating ASD for GS13' channel{iRespChan} '...'])
%     tic
%     [powerSpectrum, tfreq] = pwelch(respData(iRespChan).ts,theWindow,nOverlap,nFFTs,sampleFreq);
%     tasd(:,iRespChan) = sqrt(powerSpectrum);
%     toc
%     
%     disp(['   Calculating TF between GS13' channel{iRespChan} ' and STS-2...'])
%     tic
%     [ttfs(:,iRespChan), tfreq] = tfestimate(ref.ts,respData(iRespChan).ts,theWindow,nOverlap,nFFTs,sampleFreq);
%     toc
%     disp(['   Calculating COH between GS13' channel{iRespChan} ' and STS-2...'])
%     tic
%     [tcohs(:,iRespChan), tfreq] = mscohere(ref.ts,respData(iRespChan).ts,theWindow,nOverlap,nFFTs,sampleFreq);
%     toc
%     
%     minFreqInd = find(tfreq <= freqRange(1), 1,'last');
%     maxFreqInd = find(tfreq >= freqRange(2), 1,'first');
%     freq = tfreq(minFreqInd:maxFreqInd);
%     
%     respData(iRespChan).asd = tasd(minFreqInd:maxFreqInd,iRespChan);
%     respData(iRespChan).ststf = ttfs(minFreqInd:maxFreqInd,iRespChan);
%     respData(iRespChan).stscoh = tcohs(minFreqInd:maxFreqInd,iRespChan);
%     disp('  ')
% end

%%
clear test tasd ttfs tcohs




