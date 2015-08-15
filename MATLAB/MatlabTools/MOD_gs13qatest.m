function gs13qatest(geoSN,testTag,runMeas,printFigs)
% gs13qatest(geoSN,testTag,runMeas,printFigs)
%
% gs13qatest runs quality assurance tests on aLIGO GS-13s
% including a huddle transfer function and driven transfer function
% Input:
% geoSN : a string indicating the serial number of test GS-13
%         Ex: 'LV691' or 'LH660'
% testTag : string indicating which QA testing run
%           Should be
%            'AR' -> As Received
%            'PM' -> Post Modification
%            'VP' -> Vacuum Podded
% runMeas : boolean indicating whether to run the tests 
%           (as opposed to just plotting results again) 
%           Should be true or false
% printFigs : booleam indicating whether to print figures to pdf files
%             Should be true or false
%
% Example
% >> geoSN = {'LV691'}; testTag = 'PM'; runMeas = true; printFigs = false;
% >> gs13qatest(geoSN,testTag,runMeas,printFigs);

% close all
% clear all
% clc

%%

% svnHome = '/Users/llosbconf/SeismicSVN/seismic/';
% 
% switch testTag
%     case 'AR'
%         dataDir = [svnHome 'Common/Data/aLIGO_GS13_TestData/AsReceived_TestResults_RawASCII/'];
%         resultsDir = [svnHome 'Common/Data/aLIGO_GS13_TestData/AsReceived_TestResults_PDFs/'];
%         huddleMagRange = [-60 10];
%     case 'PM'
%         dataDir = [svnHome 'Common/Data/aLIGO_GS13_TestData/PostMod_TestResults_RawASCII/'];
%         resultsDir = [svnHome 'Common/Data/aLIGO_GS13_TestData/PostMod_TestResults_PDFs/'];       
%         huddleMagRange = [-20 60];
%     case 'VP'
%         dataDir = [svnHome 'Common/Data/aLIGO_GS13_TestData/VacPodded_TestResults_RawASCII/'];
%         resultsDir = [svnHome 'Common/Data/aLIGO_GS13_TestData/VacPodded_TestResults_PDFs/'];
% end

%scriptsDir = [svnHome 'Common/PythonTools/'];
%
%huddleScript = [scriptsDir 'MOD_HuddleTFSR785.py'];
%%drivenScript = [scriptsDir 'MOD_DrivenTFSR785.py'];
%
%exampleDrivenTfs = {[dataDir 'LV_ExampleBad_DrivenTF.dat'];...
%                    [dataDir 'LV_ExampleGood_DrivenTF.dat']};
%
stsSN = '109826';
measts = {'HuddleTF';'DrivenTF'};
% testTag = 'PM'; % Post LIGO Modifications
% fileNames{1} = [geoSN '_' testTag '_' measts{1}];
% fileNames{2} = [geoSN '_' testTag '_' measts{2}];

huddleTestDuration = 120; % sec
drivenTestDuration = 75; % sec

huddleFreqRange = [0.1 25];
drivenFreqRange = [50 150];
drivenMagRange = [15 50];

%%
% Check if serial indicates that test GS-13 is vertical or horizontal
%isVertical = strncmp(geoSN,'LV',2);
%isPostModTest = strcmp(testTag,'PM');
%isNewFile = ~exist([dataDir fileNames{1} '.dat']);


freqres = 4  % Freq resolution is normally found by converting number of points into a range. Seen in HuddleTFSR785.py. 
             %  Here its just a number for now.
freqrange = huddleFreqRange
starttime = NOW % I need to find out how GPS can give a time here.
%aa = get_calibratedtfs('G1:HUD-SIGNL_STS_X_IN1',starttime,freqres,freqrange)
aa = get_calibratedtf(G,starttime,freqres,freqrange)


%%
%#if runMeas
%#    % Be sure not to unintentionally overwrite data
%#    if ~isNewFile
%#        overWrite = input(['Files for ' geoSN ' already exist. Continuing will '...
%#            'overwrite previous data. Continue? [y/n] '],'s');
%#        if strcmp(overWrite,'n')
%#            disp('OK, exiting measurement program.')
%#            return
%#        end
%#    end
    
%#    if isVertical && isPostModTest
%#        disp([geoSN ' is a Post-Mod Vertical GS-13; Running Both Huddle and Driven Tests...'])
%#        disp(['Running Huddle Test, waiting ' num2str(huddleTestDuration) ' sec ...'])
%#        [junk,status] = system([huddleScript ' -f ' dataDir fileNames{1}]);
%#        display(status)
%#        disp('Huddle Test done.')
%#        
%#        disp(['Running Driven Test, waiting ' num2str(drivenTestDuration) ' sec ...'])
%#        [junk,status] = system([drivenScript ' -f ' dataDir fileNames{2}]);
%#        disp(status)
%#        disp('Driven Test done.')
%#    else
%#        disp('Running Huddle Test Only...')
%#        disp(['Running Huddle Test, waiting ' num2str(huddleTestDuration) ' sec ...'])
%#        [junk,status] = system([huddleScript ' -f ' dataDir fileNames{1}]);
%#        display(status)
%#        disp('Huddle Test done.')
%#    end
%#    
%end

%%
%modelFreq = logspace(log10(huddleFreqRange(1)),log10(huddleFreqRange(2)),500);
%switch testTag
%    case 'AR'
%        gs13Model_f = makegeotechsgs13(modelFreq);
%        if (strcmp(geoSN,'LV682') || strcmp(geoSN,'LV683') || strcmp(geoSN,'LV689') ||...
%           strcmp(geoSN,'LV690') || strcmp(geoSN,'LV692') || strcmp(geoSN,'LV697') ||...
%           strcmp(geoSN,'LV698') || strcmp(geoSN,'LV699') || strncmp(geoSN,'LH',2))
%            dcGain = -192;
%        else
%            dcGain = -178;
%        end
%    case {'PM','VP'}
%        gs13Model_f = makeligogs13(modelFreq);
%        dcGain = -35; % 20 * log10((2200 * 40.2 * 1) / (1500 * 1) )
%end
%modelMag = 20*log10(abs(gs13Model_f)) + dcGain;
%modelPha = 180/pi*angle(gs13Model_f);



%%
%disp('Plotting results ...')

%data{1} = load([dataDir fileNames{1} '.dat']);

%freq{1} = data{1}(:,1);
%mag{1} = data{1}(:,2);
%pha{1} = data{1}(:,3);

%figure(1)
%subplot(211)
%lm = semilogx(freq{1},mag{1},...
%    modelFreq,modelMag,'--');
%title({'Huddle Test Transfer Function';...
%    ['GS-13 SN ' geoSN ' / STS SN ' stsSN]},...
%    'FontSize',12);
%set(lm(1),'LineWidth',4)
%set(lm(2),'LineWidth',2)
%set(gca,'FontSize',12)
%legend(geoSN,'Ideal','Location','SouthEast')
%xlabel('Frequency (Hz)')
%ylabel('Magnitude (dB)')
%legend('Measurement','Model')
%xlim(huddleFreqRange)
%ylim(huddleMagRange)
%grid on
%
%subplot(212)
%lp = semilogx(freq{1},pha{1},...
%    modelFreq,modelPha,'--');
%set(lp(1),'LineWidth',4)
%set(lp(2),'LineWidth',2)
%set(gca,'FontSize',12)
%set(gca,'YTick',-180:45:180)
%xlabel('Frequency (Hz)')
%ylabel('Phase (Deg)')
%xlim(huddleFreqRange)
%ylim([-185 185])
%grid on

%if isVertical && isPostModTest
%    data{2} = load([dataDir fileNames{2} '.dat']);
%    
%    freq{2} = data{2}(:,1);
%    mag{2} = data{2}(:,2);
%    pha{2} = data{2}(:,3);
%    
%    bad.data = load(exampleDrivenTfs{1});
%    bad.freq = bad.data(:,1);
%    bad.mag = bad.data(:,2);
%    bad.pha = bad.data(:,3);
%    
%    good.data = load(exampleDrivenTfs{2});
%    good.freq = good.data(:,1);
%    good.mag = good.data(:,2);
%    good.pha = good.data(:,3);
%    
%    figure(2)
%    subplot(211)
%    lm = plot(good.freq,good.mag,'--',...
%        bad.freq,bad.mag,'--',...
%        freq{2},mag{2});
%    title({'BL White Noise Driven Transfer Function';...
%        ['GS-13 SN ' geoSN]},...
%        'FontSize',12);
%    set(lm,'LineWidth',2)
%    set(lm(3),'LineWidth',4)
%    set(gca,'FontSize',12)
%    legend('Example Good','Example Bad',geoSN,'Location','SouthEast')
%    xlabel('Frequency (Hz)')
%    ylabel('Magnitude (dB)')
%    xlim(drivenFreqRange)
%    ylim(drivenMagRange)
%    grid on
%    
%    subplot(212)
%    lp = plot(good.freq,good.pha,'--',...
%        bad.freq,bad.pha,'--',...
%        freq{2},pha{2});
%    set(lp,'LineWidth',2)
%    set(lp(3),'LineWidth',4)
%    set(gca,'FontSize',12)
%    set(gca,'YTick',-180:45:180)
%    xlabel('Frequency (Hz)')
%    ylabel('Phase (Deg)')
%    xlim(drivenFreqRange)
%    ylim([-185 185])
%    grid on
%end
%
%if printFigs
%    figure(1)
%    FillPage('w')
%    IDfig
%    saveas(gcf,[resultsDir fileNames{1} '.pdf'])
%    
%    if isVertical && isPostModTest
%        figure(2)
%        FillPage('w')
%        IDfig
%        saveas(gcf,[resultsDir fileNames{2} '.pdf'])
%    end 
%end
%disp(['Post Mod Test Suite for ' geoSN ' complete.'])
%
