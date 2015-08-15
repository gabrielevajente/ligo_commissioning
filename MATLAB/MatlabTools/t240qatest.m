function t240qatest(SN,printFigs)
% 
% t240qatest(SN,freq,res,avgs,printFigs)
%
% t240qatest runs quality assurance tests on aLIGO Trillium 240s
% as huddle transfer function
% 
% Input:
%
% SN = the serial number of the T240 currently being tested.
% 
% freq = the measured frequency range.
%    example: freq = [0.1 50] --> enter in this format
%
% res = the resolution of the measurement
%
% avgs = the number of averages to measure over
%
% printFigs : boolean indicating whether to print figures to pdf files
%             Should be true or false
%
% (The response channels are hard-coded below.  It is assumed these will
% not need to change from test to test.  Other channels may be added if
% desired)
%
% Example input:

% >> t240qatest(109,[0.1 50],0.1, 10, true);

%%
svnHome = '/opt/svncommon/seisvn/seismic/';

t240SN = num2str(SN); %string SN input

numAvgs = 50;
freqRes1 = 0.002;
freqRange1 = [0.002 50];
%freqRes2=0.01;
%freqRange2=[0.05 50];
%freqRange=[0.001 50];

respChans ={'G1:HUD-SIGNL_T240_X_IN1_DAQ',...
    'G1:HUD-SIGNL_T240_Y_IN1_DAQ',...
    'G1:HUD-SIGNL_T240_Z_IN1_DAQ',...
    'G1:HUD-SIGNL_STS_X_IN1_DAQ',...
    'G1:HUD-SIGNL_STS_Y_IN1_DAQ',...
    'G1:HUD-SIGNL_STS_Z_IN1_DAQ'};

dataDir = [svnHome 'Common/Data/aLIGO_T240_TestData/AsReceived_TestResults_RawASCII/'];
resultsDir = [svnHome 'Common/Data/aLIGO_T240_TestData/AsReceived_TestResults_PDFs/'];
huddleMagRange = [-60 10];

scriptsDir = [svnHome 'Common/MatlabTools/'];

stsSN = '109826';
measts = {'HuddleTF'};
DoF = {'X' ,'Y', 'Z'};

%%
%isPostModTest = strcmp(testTag,'PM')

    fileNames(1).hudFile = [dataDir t240SN '_AR_' measts{1} '.mat'];
    fileNames(2).isNewFile = exist(fileNames(1).hudFile,'file');

%%
%START = 'now';
[freq,tfs,cohs,startTime1,measDuration1] = huddletf_t240(respChans,freqRange1,freqRes1,numAvgs);
%[freq2,tfs2,cohs2,startTime2,measDuration2] = huddletf_t240(respChans,freqRange2,freqRes2,numAvgs); 
%freq=[freq1;freq2];
%%tfs=[tfs1;tfs2];
%cohs=[cohs1;cohs2];

save(fileNames(1).hudFile,'freq','tfs','cohs');%,'startTime','measDuration');

    disp('Huddle Test done.')
    
%% Make the T240 & STS-2 Models
modelFreq = logspace(log10(freqRange1(1)),log10(freqRange1(2)),500);

t240Model_f = maketrillium240(modelFreq);
sts2Model_f = maketeststandsts2(modelFreq);

modelMag = 20*log10(abs(t240Model_f./sts2Model_f));
modelPha = 180/pi*angle(t240Model_f./sts2Model_f);

%%  Plotting of the Results
disp('Plotting results ...')

 %hud.legend{1,:} = ['T240 SN ' t240SN];
    
for i=1:3
figure(i)
subplot(311)
lm = semilogx(freq,20*log10(abs(tfs(:,i))),...
    modelFreq,modelMag,'--');
title({'Huddle Test Transfer Function';...
    ['T240 / STS-2 ' DoF{i} '-DoF' ];...
    ['T240 SN ' t240SN];...
    ['STS SN ' stsSN]},...
    'FontSize',12);
set(lm(1),'LineWidth',2)
set(lm(2),'LineWidth',4)
set(gca,'FontSize',12)
%legend(hud.legend,'Location','SouthEast')
xlabel('Frequency (Hz)')
ylabel('Magnitude (dB)')
xlim(freqRange1)
%ylim(huddleMagRange)
grid on

subplot(312)
lp = semilogx(freq,(180/pi*angle(tfs(:,i))),...
    modelFreq,modelPha,'--');
set(lp(1),'LineWidth',2)
set(lp(2),'LineWidth',4)
set(gca,'FontSize',12)
set(gca,'YTick',-180:45:180)
xlabel('Frequency (Hz)')
ylabel('Phase (Deg)')
xlim(freqRange1)
ylim([-185 185])
grid on

subplot(313)
lp = semilogx(freq,cohs(:,i));
set(lp(1),'LineWidth',2)
%set(lp(2),'LineWidth',4)
set(gca,'FontSize',12)
set(gca,'YTick',0:0.2:1)
xlabel('Frequency (Hz)')
ylabel('Coh')
xlim(freqRange1)
ylim([0 1])
grid on
end


if printFigs
    for i=1:3
    figure(i)
    FillPage('w')
    IDfig
    combined_name=[];
    
    substring(fileNames(1).hudFile,length(dataDir),length(dataDir)+5)
    combined_name=[combined_name substring(fileNames(1).hudFile,length(dataDir),length(dataDir)+5) '_' ];
    
    saveas(gcf,[ resultsDir combined_name  DoF{i} '_DoF' substring(fileNames(1).hudFile,length(dataDir)+6,length(fileNames(1).hudFile)-5) '.pdf'])
    end
end
disp('Post Mod Test Suite for ')
disp(t240SN)
disp(' is complete.')

% if runMeas
%     START = 'now';
%     if [fileNames.isNewFile]
%         disp('Files for: ');...
%             disp(T240SNs);...
%             disp('already exist.');
%         overWrite = input(['Continuing will '...
%             'overwrite previous data for T240 SN'...
%             'mentioned above. '...
%             'Continue? [y/n] '],'s');
%         if strcmp(overWrite,'n')
%             disp('OK, exiting measurement program.')
%             return
%         end
%     else
%         disp('Files for: ');...
%             disp(T240SNs);...
%             disp('do not already exist, continuing measurement ...');
%     end