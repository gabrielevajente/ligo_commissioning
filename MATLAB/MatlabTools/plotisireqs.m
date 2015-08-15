% function [HAMreqs BSCreqs] = plotisireqs(freq)
% Plots HAM and BSC ISI absolute motion requirements for advanced LIGO.

close all 
clear all
clc

%%
printFigs = true;
newBscCurveApproved = false;

minFreq = 0.005;
maxFreq = 200;
nPoints = 200;
minRange = 1e-14;
maxRange = 1e-4;
freqRange = [minFreq maxFreq];
magRange = [minRange maxRange];

freq = logspace(log10(minFreq),log10(maxFreq),nPoints);
magTicks = logspace(log10(minRange),log10(maxRange),abs(log10(minRange)) - abs(log10(maxRange))+1);

% Figure out the location of the HAM-ISI subfolder of the Seismic
% repository 
[status, user] = system('whoami');
[status, hostip] = system('hostname -i');
if strncmpi(user,'BTL',3)          % Lantz's Laptop
    repoHome = '/Users/BTL/Brians_files/SeismicSVN/seismic/';
elseif strncmpi(user,'kissel',3)   % Kissel's Laptop
    repoHome = '/Users/kissel/SeismicSVN/seismic/';
elseif strncmpi(hostip,'10.100',6) % LLO Control Room
    repoHome = '/cvs/cds/project/SeismicSVN/seismic/';
else                               % LHO Control Room
    repoHome = '/users/controls/isi_local_files/SVN/seismic/';
end


toolDir = [repoHome 'HAM-ISI/Common/MatlabTools/'];
dataDir.L1 = [repoHome 'HAM-ISI/LLO/Data/'];
dataDir.H1 = [repoHome 'HAM-ISI/Common/DataAnalysis/'];
talkDir = '/Users/kissel/Documents/MyLIGO/Publications/LowFreqMotion_BostonMITVisit_091211/';

dataFileName.L1 = [dataDir.L1 '090605_L1PerformanceData_TotalOnly.mat'];
dataFileName.H1 = [dataDir.H1 '090319_H1vsL1PerformanceData.mat'];

%%
my_colors;
oldData.L1 = load(dataFileName.L1);
oldfreq.L1 = oldData.L1.freq;
gnd.L1 = oldData.L1.erthangON.sts;

oldData.H1 = load(dataFileName.H1);
oldfreq.H1 = oldData.H1.freq.H1;
gnd.H1 = oldData.H1.sts.H1;

clear oldData

%%

[BSCreqs.motion BSCreqs.diff BSCreqs.old] = BSC_req(freq);
HAMreqs.motion = HAM_req(freq);

%%

% As of Nov 2009, the extra bump which relaxes the requirement around 10 Hz
% has not been approved (by the BSC review committee). Once approved, this
% step can be removed.
if ~newBscCurveApproved
    [b, ind] = sort(abs(freq - 1));
    new2oldInd = ind(1);
    BSCreqs.motion = [BSCreqs.motion(1:new2oldInd) BSCreqs.old(new2oldInd+1:end)];
end

%%
figure(1)
ll = loglog(oldfreq.L1,gnd.L1.y,'--',...
            oldfreq.H1,gnd.H1.y,'--',...
            freq,HAMreqs.motion,...
            freq,BSCreqs.motion);
% title({'Internal Seismic Isolation Goals';'Advanced LIGO'},'FontSize',16)
set(gca,'FontSize',14,'YTick',magTicks)
set(ll,'LineWidth',2)
set(ll(1),'Color',[0 1 0])
set(ll(2),'Color',[1 0 0])
set(ll(3),'Color',orange,'LineWidth',3)
set(ll(4),'Color',purple)
legend('LLO Ground Motion (STS Only)',...
       'LHO Ground Motion (STS Only)',...
       'HAM ISI Goal',...
       'BSC ISI Goal',...
       'Location','SouthWest')
xlabel('Frequency (Hz)')
ylabel('Amplitude Spectral Density (m/rtHz)')
axis([freqRange magRange])
grid on

%%
if printFigs
    figure(1)
    FillPage('w')
    IDfig(', J. Kissel')
    saveas(gcf,[talkDir 'BSCvsHAMReqCurves_091203.pdf'])
end

