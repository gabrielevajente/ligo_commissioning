function [data] = sr785_gains_ade(data,data1,data2,data3);

%Inputs data in V/rthz, converts it to m/rthz and plots the results.


start_pts = 4;

Gain = 1E-3/15 ; %m/V  1mm /10 V, 1mm /20V for differential--divide by two later 


temp(:,1) = data(start_pts:end,1);
%recorded power spectra /rtHz of channel 1 6.25hz range
temp(:,2) = 1E-3/20*abs(data(start_pts:end,2))
data = temp;
x=data(:,1);
%divided by two because of differential outputs on the ADE
y=data(:,2);



temp1(:,1) = data1(start_pts:end,1);
%recorded power spectra /rtHz of channel 2 6.25hz range
temp1(:,2) = 1E-3/20*abs(data1(start_pts:end,2))
data1 = temp1;
x1=data1(:,1)
%divided by two because of differential outputs on the ADE
y1=data1(:,2);



temp2(:,1) = data2(start_pts:end,1);
%recorded power spectra /rtHz of channel 1 100hz range
temp2(:,2) = 1E-3/20*abs(data2(start_pts:end,2))
data2 = temp2;
x2=data2(:,1)
%divided by two because of differential outputs on the ADE
y2=data2(:,2);




temp3(:,1) = data3(start_pts:end,1);
%recorded power spectra /rtHz of channel 2 100hz range
temp3(:,2) = 1E-3/20*abs(data3(start_pts:end,2))
data3 = temp3;
x3=data3(:,1)
%divided by two because of differential outputs on the ADE
y3=data3(:,2);



adex=[1e-3 2e-3 1e-2 0.1 0.7 100]
adey=[5e-8 9e-9 2.5e-9 5e-10 2e-10 2e-10]

figure(1);
lineHandle= loglog(x,y,x1,y1,x2,y2,x3,y3,adex,adey)

title(['ADE +/-1mm HAM, Two channels in set of Four   09-July-2010'   '  S/N 8800-12008/12019'], 'FontSize',16) 
set(gca,'FontSize',14)
set(lineHandle, 'LineWidth',2)
xlabel('Frequency, (Hz)')
ylabel('Amplitude Spectral Density (m/rtHz)')
legend('12008 Channel Measured Performance 50 avgs centered','12008 Channel Measured Performance 50 avgs 0.082",-0.47V','12019 Channel Measured Performance 50 avgs centered','12019 Channel Measured Performance 50 avgs 0.090",-0.54v','+/-1mm ADE SEI Noise Estimates T0900450-v1')
axis([1e-2 10 1e-10 1e-7])
grid on;

ylim([1e-10 1e-7]);

xlim([1e-2 100]);

figureNote = ', E. Allwine';
fileName = 'C:\ADE_8800_+-1mm_HAM_12008_12019_JULY2010_beforeandafterbake.pdf';

figure(1);
FillPage('w')
IDfig(figureNote)
saveas(gcf,fileName) 
return