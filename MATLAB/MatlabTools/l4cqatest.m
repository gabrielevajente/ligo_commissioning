function l4cqatest(l4cSNs,respChans,runMeas,printFigs)
% l4cqatest(l4cSNs,respChans,runMeas,printFigs)
%
% l4cqatest runs quality assurance tests on aLIGO L4-Cs
% including a huddle transfer function and driven transfer function
% Input:
% l4cSNs : a cell array of strings indicating the serial numbers of test
%         L4-Cs.
%         Ex: {'L400001066V';...
%              'L400001067V'};
%          or {'L400001094H';...
%              'L400001095H';...
%              'L400001067V'};
% respChans : a cell array of strings indicating into which channels you've
%             plugged the L4Cs.
%         Ex : {'G1:HUD-SIGNL_L4C_A_IN1_DAQ';...
%               'G1:HUD-SIGNL_L4C_D_IN1_DAQ';...
%               'G1:HUD-SIGNL_L4C_B_IN1_DAQ'};
% runMeas : boolean indicating whether to run the tests
%           (as opposed to just plotting results again)
%           Should be true or false
% printFigs : booleam indicating whether to print figures to pdf files
%             Should be true or false
%
% Example
% >> l4cSNs = {'L400001066V';'L400001067V'}; runMeas = true; printFigs = false;
% >> respChans = {'G1:HUD-SIGNL_L4C_A_IN1_DAQ';...
%                 'G1:HUD-SIGNL_L4C_D_IN1_DAQ';...
%                 'G1:HUD-SIGNL_L4C_B_IN1_DAQ'};
% >> l4cqatest(geoSN,respChans,testTag,runMeas,printFigs);

% close all
% clear all
% clc

%%

svnHome = '/opt/svncommon/seisvn/seismic/';
% svnHome = '/Users/kissel/SeismicSVN/seismic/';
nL4Cs = length(l4cSNs);

dataDir = [svnHome 'Common/Data/aLIGO_L4C_TestData/TestResults_RawASCII'];
resultsDir = [svnHome 'Common/Data/aLIGO_L4C_TestData/TestResults_PDFs/'];
huddleMagRange = [-60 10];

scriptsDir = [svnHome 'Common/MatlabTools/'];

stsSN = '109826';
measts = 'HuddleTF';

huddleFreqRange = [0.1 25];

%%

for iL4C = 1:nL4Cs
    fileNames(iL4C).hudFile = [dataDir l4cSNs{iL4C} '_' measts '.mat'];
%    fileNames(iL4C).drvFile = [dataDir l4cSNs{iL4C} '_' measts{2} '.mat'];
%    This .drvFile should be a hold over from copying the GS13 code. No
%    purpose here.
    fileNames(iL4C).isNewFile = exist(fileNames(iL4C).hudFile,'file');
    
    % Check if serial indicates that test L4-C is vertical or horizontal
    fileNames(iL4C).isVertical = strncmp(l4cSNs{iL4C}(end),'V',1);
end

%%
if runMeas
    START = 'now';
    
    % Be sure not to unintentionally overwrite data
    if [fileNames.isNewFile]
        disp('Files for: ');...
            disp(l4cSNs);...
            disp('already exist.');
        overWrite = input(['Continuing will '...
            'overwrite previous data for L4C SN'...
            'mentioned above. '...
            'Continue? [y/n] '],'s');
        if strcmp(overWrite,'n')
            disp('OK, exiting measurement program.')
            return
        end
    else
        disp('Files for: ');...
            disp(l4cSNs);...
            disp('do not already exist, continuing measurement ...');
    end
    
    
    if [fileNames.isVertical]
        disp('Running Huddle Test ...')
        [hud.freq,hud.tf,hud.coh,hud.startTime,hud.measDuration] = huddletf(respChans,'V',START);
    else disp('Running Huddle Test ...')
        [hud.freq,hud.tf,hud.coh,hud.startTime,hud.measDuration] = huddletf(respChans,'H',START);
        disp('this is a horizontal');
    end
    
    for iL4C = 1:nL4Cs
        freq = hud.freq;
        tf = hud.tf(:,iL4C);
        coh = hud.coh(:,iL4C);
        startTime = hud.startTime;
        measDuration = hud.measDuration;
        save(fileNames(iL4C).hudFile,'freq','tf','coh','startTime','measDuration');
        clear('freq','tf','coh','startTime','measDuration');
    end
    disp('Huddle Test done.')
else
    getOldData = input('Do you want to load old data? [y/n]','s');
    if strcmp(getOldData,'n')
        disp('OK, exiting measurement program.')
        return
    elseif strcmp(getOldData,'y')
        hud.freq = [];
        hud.tf = [];
        hud.coh = [];
        
        for iL4C = 1:nL4Cs
            thud = load(fileNames(iL4C).hudFile);
            
            hud.freq = thud.freq;
            hud.tf(:,iL4C) = thud.tf;
            hud.coh(:,iL4C) = thud.coh;
            hud.startTime = thud.startTime;
            hud.measDuration = thud.measDuration;
            clear('thud')
        end
    end
end

%%
modelFreq = logspace(log10(huddleFreqRange(1)),log10(huddleFreqRange(2)),500);

l4cModel_f = makesercell4c(modelFreq);
sts2Model_f = maketeststandsts2(modelFreq);

modelMag = 20*log10(abs(l4cModel_f./sts2Model_f));
modelPha = 180/pi*angle(l4cModel_f./sts2Model_f);

%%
disp('Plotting results ...')

for iL4C = 1:nL4Cs
    hud.legend{iL4C,:} = ['L4-C SN ' l4cSNs{iL4C}];
    
    if iL4C == nL4Cs
        hud.legend{nL4Cs+1,:} = 'Ideal';
    end
end

figure(1)
subplot(211)
lm = semilogx(hud.freq,20*log10(abs(hud.tf)),...
    modelFreq,modelMag,'--');
title({'Huddle Test Transfer Function';...
    ['L4-C / STS-2 SN ' stsSN]},...
    'FontSize',12);
set(lm(1:nL4Cs),'LineWidth',2)
set(lm(nL4Cs+1),'LineWidth',4)
set(gca,'FontSize',12)
legend(hud.legend,'Location','SouthEast')
xlabel('Frequency (Hz)')
ylabel('Magnitude (dB)')
xlim(huddleFreqRange)
% ylim(huddleMagRange)
grid on

subplot(212)
lp = semilogx(hud.freq,180/pi*angle(hud.tf),...
    modelFreq,modelPha,'--');
set(lp(1:nL4Cs),'LineWidth',2)
set(lp(nL4Cs+1),'LineWidth',4)
set(gca,'FontSize',12)
set(gca,'YTick',-180:45:180)
xlabel('Frequency (Hz)')
ylabel('Phase (Deg)')
xlim(huddleFreqRange)
ylim([-185 185])
grid on



if printFigs
    figure(1)
    FillPage('w')
    IDfig
    combined_name=[];
    for iL4C = 1:nL4Cs
        substring(fileNames(iL4C).hudFile,length(dataDir),length(dataDir)+4)
        combined_name=[combined_name substring(fileNames(iL4C).hudFile,length(dataDir),length(dataDir)+4) '_' ];
    end
    saveas(gcf,[ resultsDir combined_name  substring(fileNames(iL4C).hudFile,length(dataDir)+6,length(fileNames(iL4C).hudFile)-5) '.pdf'])
    
    
end
disp('Post Mod Test Suite for ')
disp(l4cSNs)
disp(' is complete.')


