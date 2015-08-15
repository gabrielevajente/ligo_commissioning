close all
clear all
clc

%% Hard Coded Paramters

% User Computer's Parameters 
svnRepo = '/Users/kissel/SeismicSVN/seismic/';
% dataDir = [svnRepo 'Common/Data/aLIGO_GS13_TestData/ASCII_Data_Files/'];
dataDir = '/Volumes/090811_1532/LIGO_DVD_1.1/';
dataDir801 = '/Users/kissel/Desktop/';
resultsDir = [svnRepo 'Common/Data/aLIGO_GS13_TestData/GeoTech_TestResults_PDFs/'];
matlabToolsDir_1 = [svnRepo 'Common/MatlabTools/'];
matlabToolsDir_2 = [svnRepo 'HAM-ISI/Common/MatlabTools/'];

% GS-13 Serial Numbers
refGS13.LV.SN = 676;
refGS13.LH.SN = 775;
testGS13.LV.SNs = 677:725;
testGS13.LH.SNs = 776:824;

% File type parameters
numHeaderLines.ts = 1;
firstRealFileNum = 4;
numFileTagChars = 28;
asciiFileExt = '.asc';

% Time Domain parameters
measDuration = 10*60; %10 minutes
sampleFreq = 500; %Hz

% Frequency Domain parameters
freqRes = 0.01; %Hz
numAvgs = 10;
percentOverlap = 50; % %
windowType = @tukeywin;
tukeyAlpha = 0.3;
detrendOrder = 2; % second order polynomial removal
% 
% Plotting Parameters
printFigs = true;
idNote = ', J. Kissel';
timeToLookAtPlots = 0; % sec
asdMagRange = [1e-12 1e-4];
tfMagRange = [0.75 1.25];
cohRange = [0.5 1.01];
tfTicks = min(tfMagRange):0.05:max(tfMagRange);

%% Initialize using hardcoded variables
addpath(dataDir,matlabToolsDir_1,matlabToolsDir_2)

dt = 1/sampleFreq;
time = dt:dt:measDuration;
time = time(:);

nyquistFreq = sampleFreq/2;
nFFTs = sampleFreq / freqRes;
nOverlap = nFFTs * (percentOverlap / 100);
chunkDuration = (1 / freqRes)*(1+(numAvgs)*(1 - (percentOverlap / 100)));
theWindow = window(windowType,nFFTs,tukeyAlpha);
freq = 0:freqRes:nyquistFreq;
freqRange = [min(freq) max(freq)];

gs13Model_f = makegeotechsgs13(freq);


%% Process Verticals
typeTag = 'V';

for iGS13LV = testGS13.LV.SNs
%     if iGS13LV == 713 %|| iGS13LV == 723
%         continue
%         % Can't read 713's test timeseries
%         % 723 has a mislabled file
%     end
    disp(['Starting ' num2str(iGS13LV)])
    
    % Create the path to the data, and go there
    dataFolder = [dataDir num2str(iGS13LV) '_vs_' num2str(refGS13.LV.SN) '/'];
    cd(dataFolder)
    
    % Get the generic file tag
    files = dir;
    fileTag = files(firstRealFileNum).name(1:numFileTagChars);
    
    % Load in the raw time series
    ref.rawts = textread([dataFolder fileTag num2str(refGS13.LV.SN) asciiFileExt],...
        '%f','headerlines',numHeaderLines.ts);
    test.rawts = textread([dataFolder fileTag num2str(iGS13LV) asciiFileExt],...
        '%f','headerlines',numHeaderLines.ts);
    
    % Detrend the raw time series data
    ref.fitCoeffs = polyfit(time, ref.rawts, detrendOrder);  
    ref.fit = polyval(ref.fitCoeffs, time); 
    ref.ts = ref.rawts - ref.fit;   % detrend
    
    test.fitCoeffs = polyfit(time, test.rawts, detrendOrder);  
    test.fit = polyval(test.fitCoeffs, time); 
    test.ts = test.rawts - test.fit;   % detrend
    
    % Create a calibrated amplitude spectral density (asd)
    [ref.psd, freq] = pwelch(ref.ts,theWindow,nOverlap,nFFTs,sampleFreq);
    ref.asd = sqrt(ref.psd) ./ gs13Model_f;
    
    [test.psd, freq] = pwelch(test.ts,theWindow,nOverlap,nFFTs,sampleFreq);
    test.asd = sqrt(test.psd) ./ gs13Model_f;
    
    % Create a calibrated transfer function
    [tf, freq] = tfestimate(ref.ts,test.ts,theWindow,nOverlap,nFFTs,sampleFreq);
    [coh.p, freq] = mscohere(ref.ts,test.ts,theWindow,nOverlap,nFFTs,sampleFreq);
    coh.a = sqrt(coh.p);
    
    % Plot the results
    figure;
    lt = plot(time,ref.rawts,time,test.rawts);
    title({'Time Series Comaprison'; ...
           ['S/N ' num2str(iGS13LV) typeTag ' vs. ' num2str(refGS13.LV.SN) typeTag]}, ...
           'FontSize',16,'Interpreter','None')
    set(gca,'FontSize',14)
    set(lt,'LineWidth',1.5)
    legend(['GS13L' typeTag ' S/N' num2str(refGS13.LV.SN)],['GS13L' typeTag ' S/N' num2str(iGS13LV)])
    xlabel('Time (s)')
    ylabel('Amplitude (V)')
    grid on
    
    figure;
    ll = loglog(freq,ref.asd,freq,test.asd);
    title({'Amplitude Spectral Density Comaprison'; ...
           ['S/N ' num2str(iGS13LV) typeTag ' vs. ' num2str(refGS13.LV.SN) typeTag]}, ...
           'FontSize',16,'Interpreter','None')   
    set(gca,'FontSize',14)
    set(ll(1),'LineWidth',3)
    set(ll(2),'LineWidth',2)
    legend(['GS13L' typeTag ' S/N' num2str(refGS13.LV.SN)],['GS13L' typeTag ' S/N' num2str(iGS13LV)])
    xlabel('Frequency (Hz)')
    ylabel('Amplitude (m / rtHz)')
    axis([freqRange asdMagRange])
    grid on
    
    figure;
    subplot(211)
    lm = semilogx(freq,abs(tf));
    title({'Transfer Function'; ...
           ['S/N ' num2str(iGS13LV) typeTag ' / ' num2str(refGS13.LV.SN) typeTag]}, ...
           'FontSize',16,'Interpreter','None')   
    set(gca,'FontSize',14)
    set(lm,'LineWidth',2)
    legend(['GS13L' typeTag ' S/N' num2str(iGS13LV) ' / GS13L' typeTag ' S/N' num2str(refGS13.LV.SN)],...
            'Location','NorthWest')
    xlabel('Frequency (Hz)')
    ylabel('Magnitude (m / m)')
    axis([freqRange tfMagRange])
    set(gca,'YTick',tfTicks)
    grid on
    
    subplot(212)
    lc = semilogx(freq,coh.a);
    title('Coherence','FontSize',16)   
    set(gca,'FontSize',14)
    set(lc,'LineWidth',2)
    xlabel('Frequency (Hz)')
    ylabel('Coherence')
    axis([freqRange cohRange])
    grid on
    
    if printFigs
        figure(1);
        IDfig(idNote)
        FillPage('w')
        saveas(gcf,[resultsDir 'GS13L' typeTag num2str(iGS13LV) '_vs_' num2str(refGS13.LV.SN) '_ts.pdf'])
        
        figure(2);
        IDfig(idNote)
        FillPage('w')
        saveas(gcf,[resultsDir 'GS13L' typeTag num2str(iGS13LV) '_vs_' num2str(refGS13.LV.SN) '_asd.pdf'])
        
        figure(3);
        IDfig(idNote)
        FillPage('w')
        saveas(gcf,[resultsDir 'GS13L' typeTag num2str(iGS13LV) '_vs_' num2str(refGS13.LV.SN) '_tf.pdf'])
    end
    pause(timeToLookAtPlots)
    disp(['Done with ' num2str(iGS13LV)])
    close(1:3)
    clear test ref tf coh freq
end


disp('Done with all the verticals')
disp(' ')

close all

%% Process Horizontals
typeTag = 'H';

for iGS13LH = testGS13.LH.SNs
    disp(['Starting ' num2str(iGS13LH)])
    
    % Create the path to the data, and go there
    if iGS13LH == 801
        dataFolder = [dataDir801 num2str(iGS13LH) '_vs_' num2str(refGS13.LH.SN) '/'];
        cd(dataFolder)
    else
        dataFolder = [dataDir num2str(iGS13LH) '_vs_' num2str(refGS13.LH.SN) '/'];
        cd(dataFolder)
    end
    
    % Get the generic file tag
    files = dir;
    fileTag = files(firstRealFileNum).name(1:numFileTagChars);
    
    % Load in the raw time series
%     if iGS13LH == 801
%         % 801 has a mislabled reference ascii file (should have 775 tag, it
%         % has 676)
%         test.rawts = textread([dataFolder fileTag num2str(refGS13.LV.SN) asciiFileExt],...
%             '%f','headerlines',numHeaderLines.ts);
%     else
        ref.rawts = textread([dataFolder fileTag num2str(refGS13.LH.SN) asciiFileExt],...
            '%f','headerlines',numHeaderLines.ts);
%     end
    test.rawts = textread([dataFolder fileTag num2str(iGS13LH) asciiFileExt],...
        '%f','headerlines',numHeaderLines.ts);

    % Detrend the raw time series data
    ref.fitCoeffs = polyfit(time, ref.rawts, detrendOrder);  
    ref.fit = polyval(ref.fitCoeffs, time); 
    ref.ts = ref.rawts - ref.fit;   % detrend
    
    test.fitCoeffs = polyfit(time, test.rawts, detrendOrder);  
    test.fit = polyval(test.fitCoeffs, time); 
    test.ts = test.rawts - test.fit;   % detrend
    
    % Create a calibrated amplitude spectral density (asd)
    [ref.psd, freq] = pwelch(ref.ts,theWindow,nOverlap,nFFTs,sampleFreq);
    ref.asd = sqrt(ref.psd) ./ gs13Model_f;
    
    [test.psd, freq] = pwelch(test.ts,theWindow,nOverlap,nFFTs,sampleFreq);
    test.asd = sqrt(test.psd) ./ gs13Model_f;
    
    % Create a calibrated transfer function
    [tf, freq] = tfestimate(ref.ts,test.ts,theWindow,nOverlap,nFFTs,sampleFreq);
    [coh.p, freq] = mscohere(ref.ts,test.ts,theWindow,nOverlap,nFFTs,sampleFreq);
    coh.a = sqrt(coh.p);
    
    % Plot the results
    figure(1);
    lt = plot(time,ref.rawts,time,test.rawts);
    title({'Time Series Comaprison'; ...
           ['S/N ' num2str(iGS13LH) typeTag ' vs. ' num2str(refGS13.LH.SN) typeTag]}, ...
           'FontSize',16,'Interpreter','None')
    set(gca,'FontSize',14)
    set(lt,'LineWidth',1.5)
    legend(['GS13L' typeTag ' S/N' num2str(refGS13.LH.SN)],['GS13L' typeTag ' S/N' num2str(iGS13LH)])
    xlabel('Time (s)')
    ylabel('Amplitude (V)')
    grid on
    
    figure(2);
    ll = loglog(freq,ref.asd,freq,test.asd);
    title({'Amplitude Spectral Density Comaprison'; ...
           ['S/N ' num2str(iGS13LH) typeTag ' vs. ' num2str(refGS13.LH.SN) typeTag]}, ...
           'FontSize',16,'Interpreter','None')   
    set(gca,'FontSize',14)
    set(ll(1),'LineWidth',3)
    set(ll(2),'LineWidth',2)
    legend(['GS13L' typeTag ' S/N' num2str(refGS13.LH.SN)],['GS13L' typeTag ' S/N' num2str(iGS13LH)])
    xlabel('Frequency (Hz)')
    ylabel('Amplitude (m / rtHz)')
    axis([freqRange asdMagRange])
    grid on
    
    figure(3);
    subplot(211)
    lm = semilogx(freq,abs(tf));
    title({'Transfer Function'; ...
           ['S/N ' num2str(iGS13LH) typeTag ' / ' num2str(refGS13.LH.SN) typeTag]}, ...
           'FontSize',16,'Interpreter','None')   
    set(gca,'FontSize',14)
    set(lm,'LineWidth',2)
    legend(['GS13L' typeTag ' S/N' num2str(iGS13LH) ' / GS13L' typeTag ' S/N' num2str(refGS13.LH.SN)],...
            'Location','NorthWest')
    xlabel('Frequency (Hz)')
    ylabel('Magnitude (m / m)')
    axis([freqRange tfMagRange])
    set(gca,'YTick',tfTicks)
    grid on
    
    subplot(212)
    lc = semilogx(freq,coh.a);
    title('Coherence','FontSize',16)   
    set(gca,'FontSize',14)
    set(lc,'LineWidth',2)
    xlabel('Frequency (Hz)')
    ylabel('Coherence')
    axis([freqRange cohRange])
    grid on
    
    if printFigs
        figure(1);
        FillPage('w')
        IDfig(idNote)
        saveas(gcf,[resultsDir 'GS13L' typeTag num2str(iGS13LH) '_vs_' num2str(refGS13.LH.SN) '_ts.pdf'])
        
        figure(2);
        FillPage('w')
        IDfig(idNote)
        saveas(gcf,[resultsDir 'GS13L' typeTag num2str(iGS13LH) '_vs_' num2str(refGS13.LH.SN) '_asd.pdf'])
        
        figure(3);
        FillPage('w')
        IDfig(idNote)
        saveas(gcf,[resultsDir 'GS13L' typeTag num2str(iGS13LH) '_vs_' num2str(refGS13.LH.SN) '_tf.pdf'])
    end
    
    pause(timeToLookAtPlots)
    disp(['Done with ' num2str(iGS13LH)])
    close(1:3)
    clear test ref tf coh freq
end

disp('Done with all the horizontals')
disp(' ')