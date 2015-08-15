close all
clear all
clc

%%
printFigs = true;

svnDir = '/ligo/svncommon/SeiSVN/seismic/';
matlabDir = [svnDir 'HAM-ISI/Common/MatlabTools'];
matlabDir2 = [svnDir 'Common/MatlabTools/'];
dataDir = [svnDir 'Common/Data/'];
figDir = '/home/celine.ramet/Documents/';
gndDataFile = [dataDir 'LLOSeismicData_T0900312.mat'];


figFileName1 = [figDir 'aligoseireqs.pdf'];
figFileName2 = [figDir 'aligoseisensornoise.pdf'];

channelInds.gndsts.y = 23;

freqRange = [0.01 100];
ampRange = [1e-14 1e-4];

%%
addpath(matlabDir)
addpath(matlabDir2)
addpath(dataDir)

%%
freq = logspace(log10(freqRange(1)),log10(freqRange(2)),250);

%%
out = BSC_req(freq);

req.bscisi = out(:); % X

[prcl,hsrcl,vsrcl] = HAM_req(freq);

req.hsrclisi = hsrcl(:); % X
req.vsrclisi = vsrcl(:);
req.prclisi = prcl(:); % X

%%

rawNoise.gs13 = SEI_sensor_noise('GS13meas',freq);
rawNoise.l4c = SEI_sensor_noise('L4C',freq);
rawNoise.cps = SEI_sensor_noise('ADE_p25mm',freq);
rawNoise.ips = SEI_sensor_noise('Kaman_IPS',freq);
rawNoise.t240 = SEI_sensor_noise('T240meas',freq);
rawNoise.sts2 = SEI_sensor_noise('T240spec',freq);

%%
stsy = 26;

ten = 1;
fifty = 3;
ninety = 5;

gndData = load(gndDataFile);
gnd.freq = gndData.LLOSeismicData(stsy).f;
gnd.ninety = gndData.LLOSeismicData(stsy).cont(:,ninety);
gnd.fifty = gndData.LLOSeismicData(stsy).cont(:,fifty);
gnd.ten = gndData.LLOSeismicData(stsy).cont(:,ten);
%%
figure(1)
ll = loglog(gnd.freq,gnd.ten,...
            gnd.freq,gnd.fifty,...
            gnd.freq,gnd.ninety,...
            freq,req.prclisi,...
            freq,req.hsrclisi,...
            freq,req.bscisi);
set(gca,'FontSize',20,'XTick',10.^(-3:2),'YTick',10.^(-14:-5))
set(ll,'LineWidth',3)
set(ll(1),'Color',[1.0 0.6 0.6])
set(ll(2),'Color',[1.0 0.3 0.3])
set(ll(3),'Color',[1.0 0.0 0.0])
set(ll(4),'Color',[1.0 0.3 0.0],'LineWidth',4,'LineStyle','--')
set(ll(5),'Color',[1.0 0.6 0.0],'LineWidth',4,'LineStyle','-.')
set(ll(6),'Color',[0.5 0.0  0.8],'LineWidth',4)
lleg = legend('GND (10th Percentile)',...
              'GND (50th Percentile)',...
              'GND (90th Percentile)',...
              'PRCL HAM ISI Req',...
              'SRCL HAM ISI Req',...
              'BSC ISI Req');
set(lleg,'FontSize',16)          
xlabel('Frequency (Hz)')
ylabel('Displacement Noise (m/rtHz)')
axis([freqRange ampRange])
grid on
%%

figure(2)
ll = loglog(gnd.freq,gnd.fifty,...
            freq,rawNoise.cps,...
            freq,rawNoise.ips,...
            freq,rawNoise.gs13,...
            freq,rawNoise.l4c,...
            freq,rawNoise.t240,...
            freq,rawNoise.sts2,...
            freq,req.prclisi,...
            freq,req.hsrclisi,...
            freq,req.bscisi);
set(gca,'FontSize',20,'XTick',10.^(-3:2),'YTick',10.^(-14:-5))
set(ll,'LineWidth',2)
set(ll(1),'Color',[1.0 0.3 0.3])
set(ll(2),'Color',[0.0 0.0 1.0],'LineWidth',4)
set(ll(3),'Color',[0.3 0.3 1.0],'LineWidth',4)
set(ll(4),'Color',[0.0 0.7 0.0],'LineWidth',4)
set(ll(5),'Color',[0.0 1.0 0.0],'LineWidth',4)
set(ll(6),'Color',[0.5 1.0 0.7],'LineWidth',4,'LineStyle','--')
set(ll(7),'Color',[0.1 1.0 0.1],'LineWidth',4,'LineStyle','--')
set(ll(8),'Color',[1.0 0.3 0.0],'LineWidth',6,'LineStyle','--')
set(ll(9),'Color',[1.0 0.6 0.0],'LineWidth',6,'LineStyle','-.')
set(ll(10),'Color',[0.5 0.0  0.8],'LineWidth',6)
lleg = legend('GND (50th Percentile)',...
              'Raw CPS Noise',...
              'Raw IPS Noise',...
              'Raw GS13 Noise',...
              'Raw L4C Noise',...
              'Raw T240 Noise',...
              'Raw STS Noise',...
              'PRCL HAM ISI Req',...
              'SRCL HAM ISI Req',...
              'BSC ISI Req',...
              'Location','SouthWest');
set(lleg,'FontSize',16)          
xlabel('Frequency (Hz)')
ylabel('Displacement Noise (m/rtHz)')
axis([freqRange ampRange])
grid on

%%
if printFigs
    figure(1)
    FillPage('tall')
    IDfig(', J. Kissel')
    saveas(gcf,figFileName1)
    
    figure(2)
    FillPage('tall')
    IDfig(', J. Kissel')
    saveas(gcf,figFileName2)
end