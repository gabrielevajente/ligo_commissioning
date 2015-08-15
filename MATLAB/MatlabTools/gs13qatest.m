function gs13qatest(geoSNs,respChans,testTag,runMeas,printFigs)
% gs13qatest(geoSNs,respChans,testTag,runMeas,printFigs)
%
% gs13qatest runs quality assurance tests on aLIGO GS-13s
% including a huddle transfer function and driven transfer function
% Input:
% geoSNs : a cell array of strings indicating the serial numbers of test
%         GS-13s.
%         Ex: {'LV691';...
%              'LV692'};
%          or {'LH660';...
%              'LH662';...
%              'LH675'};
% respChans : a cell array of strings indicating into which channels you've
%             plugged the GS13s.
%         Ex : {'G1:HUD-SIGNL_GS13_A_IN1_DAQ';...
%               'G1:HUD-SIGNL_GS13_D_IN1_DAQ';...
%               'G1:HUD-SIGNL_L4C_B_IN1_DAQ'};
% testTag : string indicating which QA testing run
%           Should be
%            'AR' -> As Received
%            'PM' -> Post Modification
%            'VP' -> Vacuum Podded
% runMeas : boolean indicating whether to run the tests
%           (as opposed to just plotting results again)
%           Should be true or false
% printFigs : boolean indicating whether to print figures to pdf files
%             Should be true or false
%
% Example
% >> geoSN = {'LV691'}; testTag = 'PM'; runMeas = true; printFigs = false;
% >> respChans = {'G1:HUD-SIGNL_GS13_A_IN1_DAQ';...
%                 'G1:HUD-SIGNL_GS13_D_IN1_DAQ';...
%                 'G1:HUD-SIGNL_L4C_B_IN1_DAQ'};
% >> gs13qatest(geoSN,respChans,testTag,runMeas,printFigs);

% close all
% clear all
% clc

%%

svnHome = '/opt/svncommon/seisvn/seismic/';
% svnHome = '/Users/kissel/SeismicSVN/seismic/';
nGS13s = length(geoSNs);

switch testTag
    case 'AR'
        dataDir = [svnHome 'Common/Data/aLIGO_GS13_TestData/AsReceived_TestResults_RawASCII/'];
        resultsDir = [svnHome 'Common/Data/aLIGO_GS13_TestData/AsReceived_TestResults_PDFs/'];
        huddleMagRange = [-60 10];
    case 'PM'
        dataDir = [svnHome 'Common/Data/aLIGO_GS13_TestData/PostMod_TestResults_RawASCII/'];
        resultsDir = [svnHome 'Common/Data/aLIGO_GS13_TestData/PostMod_TestResults_PDFs/'];
        huddleMagRange = [-20 60];
    case 'VP'
        dataDir = [svnHome 'Common/Data/aLIGO_GS13_TestData/VacPodded_TestResults_RawASCII/'];
        resultsDir = [svnHome 'Common/Data/aLIGO_GS13_TestData/VacPodded_TestResults_PDFs/'];
end

scriptsDir = [svnHome 'Common/MatlabTools/'];

exampleDrivenTfs = {[dataDir 'LV_ExampleBad_DrivenTF.dat'];...
    [dataDir 'LV_ExampleGood_DrivenTF.dat']};

stsSN = '109826';
measts = {'HuddleTF';'DrivenTF'};

huddleFreqRange = [0.1 25];
drivenFreqRange = [50 150];
drivenMagRange = [15 50];

%%
isPostModTest = strcmp(testTag,'PM');

for iGS13 = 1:nGS13s
    fileNames(iGS13).hudFile = [dataDir geoSNs{iGS13} '_' testTag '_' measts{1} '.mat'];
    fileNames(iGS13).drvFile = [dataDir geoSNs{iGS13} '_' testTag '_' measts{2} '.mat'];
    fileNames(iGS13).isNewFile = exist(fileNames(iGS13).hudFile,'file');
    
    % Check if serial indicates that test GS-13 is vertical or horizontal
    fileNames(iGS13).isVertical = strncmp(geoSNs{iGS13},'LV',2);
end

%%
if runMeas
    START = 'now';
    
    % Be sure not to unintentionally overwrite data
    if [fileNames.isNewFile]
        disp('Files for: ');...
            disp(geoSNs);...
            disp('already exist.');
        overWrite = input(['Continuing will '...
            'overwrite previous data for GS13 SN'...
            'mentioned above. '...
            'Continue? [y/n] '],'s');
        if strcmp(overWrite,'n')
            disp('OK, exiting measurement program.')
            return
        end
    else
        disp('Files for: ');...
            disp(geoSNs);...
            disp('do not already exist, continuing measurement ...');
    end
    
    
    if [fileNames.isVertical]
        disp('Running Huddle Test ...')
        [hud.freq,hud.tf,hud.coh,hud.startTime,hud.measDuration] = huddletf(respChans,'V',START);
    else disp('Running Huddle Test ...')
        [hud.freq,hud.tf,hud.coh,hud.startTime,hud.measDuration] = huddletf(respChans,'H',START);
    end
    
    for iGS13 = 1:nGS13s
        freq = hud.freq;
        tf = hud.tf(:,iGS13);
        coh = hud.coh(:,iGS13);
        startTime = hud.startTime;
        measDuration = hud.measDuration;
        save(fileNames(iGS13).hudFile,'freq','tf','coh','startTime','measDuration');
        clear('freq','tf','coh','startTime','measDuration');
    end
    disp('Huddle Test done.')
    
    if [fileNames(iGS13).isVertical] && isPostModTest
        disp('Looks like ')
        disp(geoSNs)
        disp('are Post-Mod Vertical GS-13s.')
        disp('Running Driven Test ...')
        
        [drv.freq,drv.tf,drv.coh,drv.startTime,drv.measDuration] = driventf(respChans,START);
        disp('Driven Test done.')
        
        for iGS13 = 1:nGS13s
            freq = drv.freq;
            tf = drv.tf(:,iGS13);
            coh = drv.coh(:,iGS13);
            startTime = drv.startTime;
            measDuration = drv.measDuration;
            save(fileNames(iGS13).drvFile,'freq','tf','coh','startTime','measDuration');
            clear('freq','tf','coh','startTime','measDuration');
        end
    end
else
    getOldData = input('Do you want to load old data? [y/n]','s');
    if strcmp(getOldData,'n')
        disp('OK, exiting measurement program.')
        return
    elseif strcmp(getOldData,'y')
        hud.freq = [];
        hud.tf = [];
        hud.coh = [];
        
        for iGS13 = 1:nGS13s
            thud = load(fileNames(iGS13).hudFile);
            
            hud.freq = thud.freq;
            hud.tf(:,iGS13) = thud.tf;
            hud.coh(:,iGS13) = thud.coh;
            hud.startTime = thud.startTime;
            hud.measDuration = thud.measDuration;
            clear('thud')
        end
        if [fileNames(iGS13).isVertical] && isPostModTest
            for iGS13 = 1:nGS13s
                tdrv = load(fileNames(iGS13).drvFile);
                
                drv.freq = tdrv.freq;
                drv.tf(:,iGS13) = tdrv.tf;
                drv.coh(:,iGS13) = tdrv.coh;
                drv.startTime = tdrv.startTime;
                drv.measDuration = tdrv.measDuration;
            end
        end
    end
end

%%
modelFreq = logspace(log10(huddleFreqRange(1)),log10(huddleFreqRange(2)),500);
switch testTag
    case 'AR'
        gs13Model_f = makegeotechgs13(modelFreq);
        sts2Model_f = maketeststandsts2(modelFreq);
    case {'PM','VP'}
        gs13Model_f = makeligogs13(modelFreq);
        sts2Model_f = maketeststandsts2(modelFreq);
end
modelMag = 20*log10(abs(gs13Model_f./sts2Model_f));
modelPha = 180/pi*angle(gs13Model_f./sts2Model_f);

%%
disp('Plotting results ...')

drv.legend = {'Example Good';'Example Bad'};
for iGS13 = 1:nGS13s
    hud.legend{iGS13,:} = ['GS-13 SN ' geoSNs{iGS13}];
    drv.legend{iGS13+2,:} = ['GS-13 SN ' geoSNs{iGS13}];
    
    if iGS13 == nGS13s
        hud.legend{nGS13s+1,:} = 'Ideal';
    end
end

figure(1)
subplot(211)
lm = semilogx(hud.freq,20*log10(abs(hud.tf)),...
    modelFreq,modelMag,'--');
title({'Huddle Test Transfer Function';...
    ['GS-13 / STS-2 SN ' stsSN]},...
    'FontSize',12);
set(lm(1:nGS13s),'LineWidth',2)
set(lm(nGS13s+1),'LineWidth',4)
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
set(lp(1:nGS13s),'LineWidth',2)
set(lp(nGS13s+1),'LineWidth',4)
set(gca,'FontSize',12)
set(gca,'YTick',-180:45:180)
xlabel('Frequency (Hz)')
ylabel('Phase (Deg)')
xlim(huddleFreqRange)
ylim([-185 185])
grid on

if [fileNames(1).isVertical] && isPostModTest%assumes  here thaht all GS13 are of the same type
    bad.data = load(exampleDrivenTfs{1});
    bad.freq = bad.data(:,1);
    bad.mag = bad.data(:,2);
    bad.pha = bad.data(:,3);
    
    good.data = load(exampleDrivenTfs{2});
    good.freq = good.data(:,1);
    good.mag = good.data(:,2);
    good.pha = good.data(:,3);
    
    figure(2)
    subplot(211)
    lm = plot(good.freq,good.mag,'--',...
        bad.freq,bad.mag,'--',...
        drv.freq,20*log10(abs(drv.tf)));
    title({'Driven Transfer Function';...
        'GS-13 / PZT Drive'},...
        'FontSize',12);
    set(lm,'LineWidth',2)
    set(lm(2+[1:nGS13s]),'LineWidth',4)
    set(gca,'FontSize',12)
    legend(drv.legend,'Location','SouthEast')
    xlabel('Frequency (Hz)')
    ylabel('Magnitude (dB)')
    xlim(drivenFreqRange)
    ylim(drivenMagRange)
    grid on
    
    subplot(212)
    lp = plot(good.freq,good.pha,'--',...
        bad.freq,bad.pha,'--',...
        drv.freq,180/pi*angle(drv.tf));
    set(lp,'LineWidth',2)
    set(lp(2+[1:nGS13s]),'LineWidth',4)
    set(gca,'FontSize',12)
    set(gca,'YTick',-180:45:180)
    xlabel('Frequency (Hz)')
    ylabel('Phase (Deg)')
    xlim(drivenFreqRange)
    ylim([-185 185])
    grid on
end

if printFigs
    figure(1)
    FillPage('w')
    IDfig
    combined_name=[];
    for iGS13 = 1:nGS13s
        substring(fileNames(iGS13).hudFile,length(dataDir),length(dataDir)+4)
        combined_name=[combined_name substring(fileNames(iGS13).hudFile,length(dataDir),length(dataDir)+4) '_' ];
    end
    saveas(gcf,[ resultsDir combined_name  substring(fileNames(iGS13).hudFile,length(dataDir)+6,length(fileNames(iGS13).hudFile)-5) '.pdf'])
    
    if [fileNames(1).isVertical] && isPostModTest
        figure(2)
        FillPage('w')
        IDfig
        for iGS13 = 1:nGS13s
            combined_name=[combined_name substring(fileNames(iGS13).hudFile,length(dataDir),length(dataDir)+4) '_' ];
        end
        saveas(gcf,[ resultsDir combined_name  substring(fileNames(iGS13).hudFile,length(dataDir)+6,length(fileNames(iGS13).hudFile)-5) '.pdf'])
    end
end
disp('Post Mod Test Suite for ')
disp(geoSNs)
disp(' is complete.')

