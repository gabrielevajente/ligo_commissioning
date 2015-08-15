function l4cqatest(l4cSN,runMeas,printFigs)
% l4cqatest(l4cSN,runMeas,printFigs)
%
% l4cqatest runs quality assurance tests on aLIGO L4-Cs
% including a huddle transfer function
% Input:
% geoSN : a string indicating the serial number of test L4C
%         Ex: 'L400001070V' or 'L400000950H'
% runMeas : boolean indicating whether to run the tests 
%           (as opposed to just plotting results again) 
%           Should be true or false
% printFigs : booleam indicating whether to print figures to pdf files
%             Should be true or false
%
% Example
% >> l4cSN = {'L400001070V'}; runMeas = true; printFigs = false;
% >> l4cqatest(l4cSN,runMeas,printFigs);

% close all
% clear all
% clc

%%

svnHome = '/Users/llosbconf/SeismicSVN/seismic/';
        dataDir = [svnHome 'Common/Data/aLIGO_L4C_TestData/TestResults_RawASCII/'];
        resultsDir = [svnHome 'Common/Data/aLIGO_L4C_TestData/TestResults_PDFs/'];
        

scriptsDir = [svnHome 'Common/PythonTools/'];
huddleScript = [scriptsDir 'HuddleTFSR785.py'];

huddleMagRange = [-60 10];                
                
stsSN = '109826';
meastTag = 'HuddleTF';
% testTag = 'PM'; % Post LIGO Modifications
fileName = [l4cSN '_' meastTag];

huddleTestDuration = 120; % sec
drivenTestDuration = 75; % sec

huddleFreqRange = [0.1 25];
drivenFreqRange = [50 150];
drivenMagRange = [15 50];

%%
% Check if serial indicates that test GS-13 is vertical or horizontal
isVertical = strncmp(l4cSN(end),'V',2);
isNewFile = ~exist([dataDir fileName '.dat']);


%%
if runMeas
    % Be sure not to unintentionally overwrite data
    if ~isNewFile
        overWrite = input(['Files for ' l4cSN ' already exist. Continuing will '...
            'overwrite previous data. Continue? [y/n] '],'s');
        if strcmp(overWrite,'n')
            disp('OK, exiting measurement program.')
            return
        end
    end
    
    disp(['Running Huddle Test On L4C ' l4cSN ' ...'])
    disp(['Running Huddle Test, waiting ' num2str(huddleTestDuration) ' sec ...'])
    [junk,status] = system([huddleScript ' -f ' dataDir fileName]);
    display(status)
    disp('Huddle Test done.')
end

%%
modelFreq = logspace(log10(huddleFreqRange(1)),log10(huddleFreqRange(2)),500);

l4cModel_f = makesercell4c(modelFreq);
% dcGain = -35; % dB % 20 * log10((2200 * 40.2 * 1) / (1500 * 1) )
% dcGain = 0; % dB
stsGain = 20 * log10( 1 / (1500) ); % dB 

modelMag = 20*log10(abs(l4cModel_f)) + stsGain;
modelPha = 180/pi*angle(l4cModel_f);



%%
disp('Plotting results ...')

data = load([dataDir fileName '.dat']);

freq = data(:,1);
mag = data(:,2);
pha = data(:,3);

figure(1)
subplot(211)
lm = semilogx(freq,mag,...
    modelFreq,modelMag,'--');
title({'Huddle Test Transfer Function';...
    ['L4-C SN ' l4cSN ' / STS SN ' stsSN]},...
    'FontSize',12);
set(lm(1),'LineWidth',4)
set(lm(2),'LineWidth',2)
set(gca,'FontSize',12)
legend(l4cSN,'Ideal','Location','SouthEast')
xlabel('Frequency (Hz)')
ylabel('Magnitude (dB)')
legend('Measurement','Model')
xlim(huddleFreqRange)
% ylim(huddleMagRange)
grid on

subplot(212)
lp = semilogx(freq,pha,...
    modelFreq,modelPha,'--');
set(lp(1),'LineWidth',4)
set(lp(2),'LineWidth',2)
set(gca,'FontSize',12)
set(gca,'YTick',-180:45:180)
xlabel('Frequency (Hz)')
ylabel('Phase (Deg)')
xlim(huddleFreqRange)
ylim([-185 185])
grid on

if printFigs
    disp('Printing results ...')
    
    figure(1)
    FillPage('w')
    IDfig
    saveas(gcf,[resultsDir fileName '.pdf'])
end
disp(['Test Suite for ' l4cSN ' complete.'])

