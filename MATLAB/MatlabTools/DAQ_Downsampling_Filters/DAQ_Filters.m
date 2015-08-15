%% DAQ Filters - VL November 8, 2012 - Data from Rolf Email

Frequency=logspace(-1,5,5000);
i=sqrt(-1);

% DESIGN   LSC0_ADC_DT 0 zpk([27.3067-i*16384;27.3067+i*16384;180+i*17999.1;180-i*17999.1;0-i*26546.1;0+i*26546.1], \
%                            [5927.96+i*4220.6;5927.96-i*4220.6;3289.06+i*9860.52;3289.06-i*9860.52;852.168-i*11899.9; \
%                            852.168+i*11899.9],1,"n")
DS0=zpk(-2*pi*[27.3067-i*16384;27.3067+i*16384;180+i*17999.1;180-i*17999.1;0-i*26546.1;0+i*26546.1],-2*pi*[5927.96+i*4220.6;5927.96-i*4220.6;3289.06+i*9860.52;3289.06-i*9860.52;852.168-i*11899.9;852.168+i*11899.9],1);
DS0_resp=squeeze(freqresp(DS0,2*pi*Frequency))/squeeze(freqresp(DS0,0));


% DESIGN   LSC0_ADC_DT 1 zpk([27.3067-i*16384;27.3067+i*16384;180+i*17999.1;180-i*17999.1;0-i*26546.1;0+i*26546.1], \
%                            [5927.96+i*4220.6;5927.96-i*4220.6;3289.06+i*9860.52;3289.06-i*9860.52;852.168-i*11899.9; \
%                            852.168+i*11899.9],1,"n")
DS1=zpk(-2*pi*[27.3067-i*16384;27.3067+i*16384;180+i*17999.1;180-i*17999.1;0-i*26546.1;0+i*26546.1],-2*pi*[5927.96+i*4220.6;5927.96-i*4220.6;3289.06+i*9860.52;3289.06-i*9860.52;852.168-i*11899.9;852.168+i*11899.9],1);
DS1_resp=squeeze(freqresp(DS1,2*pi*Frequency))/squeeze(freqresp(DS1,0));


% DESIGN   LSC0_ADC_DT 2 zpk([6.15016+i*4096;6.15016-i*4096;143.333+i*5158;143.333-i*5158;1160-i*11541.8;1160+i*11541.8], \
%                            [1300.79+i*926.136;1300.79-i*926.136;754.008+i*2260.5;754.008-i*2260.5;201.015+i*2807.02; \
%                            201.015-i*2807.02],0.999998,"n")

DS2=zpk(-2*pi*[6.15016+i*4096;6.15016-i*4096;143.333+i*5158;143.333-i*5158;1160-i*11541.8;1160+i*11541.8],-2*pi*[1300.79+i*926.136;1300.79-i*926.136;754.008+i*2260.5;754.008-i*2260.5;201.015+i*2807.02;201.015-i*2807.02],1);
DS2_resp=squeeze(freqresp(DS2,2*pi*Frequency))/squeeze(freqresp(DS2,0));



% DESIGN   LSC0_ADC_DT 3 zpk([0+i*2048;0-i*2048;0+i*2642.97;0-i*2642.97;0+i*6618.41;0-i*6618.41], \
%                            [623.639+i*444.019;623.639-i*444.019;362.167+i*1085.77;362.167-i*1085.77;106.886+i*1349.3; \
%                            106.886-i*1349.3],1,"n")
DS3=zpk(-2*pi*[0+i*2048;0-i*2048;0+i*2642.97;0-i*2642.97;0+i*6618.41;0-i*6618.41],-2*pi*[623.639+i*444.019;623.639-i*444.019;362.167+i*1085.77;362.167-i*1085.77;106.886+i*1349.3;106.886-i*1349.3],1);
DS3_resp=squeeze(freqresp(DS3,2*pi*Frequency))/squeeze(freqresp(DS3,0));


% DESIGN   LSC0_ADC_DT 4 zpk([0+i*1024;0-i*1024;0+i*1323.62;0-i*1323.62;0+i*3386.56;0-i*3386.56], \
%                            [311.172+i*221.549;311.172-i*221.549;180.783+i*541.982;180.783-i*541.982;53.3703+i*673.732; \
%                            53.3703-i*673.732],1,"n")

DS4=zpk(-2*pi*[0+i*1024;0-i*1024;0+i*1323.62;0-i*1323.62;0+i*3386.56;0-i*3386.56],-2*pi*[311.172+i*221.549;311.172-i*221.549;180.783+i*541.982;180.783-i*541.982;53.3703+i*673.732;53.3703-i*673.732],1)
DS4_resp=squeeze(freqresp(DS4,2*pi*Frequency))/squeeze(freqresp(DS4,0));


[z,p,k] = ellip(5,1,60,2*pi*256,'s');
DS5=zpk(z,p,k);
DS5_resp=squeeze(freqresp(DS5,2*pi*Frequency))/squeeze(freqresp(DS5,0));

[z,p,k] = ellip(5,1,60,2*pi*128,'s');
DS6=zpk(z,p,k);
DS6_resp=squeeze(freqresp(DS6,2*pi*Frequency))/squeeze(freqresp(DS6,0));

[z,p,k] = ellip(4,1,60,2*pi*64,'s');
DS7=zpk(z,p,k);
DS7_resp=squeeze(freqresp(DS7,2*pi*Frequency))/squeeze(freqresp(DS7,0));






% DESIGN   LSC0_ADC_DT 6 ellip("LowPass",5,1,60,128)
% DESIGN   LSC0_ADC_DT 7 ellip("LowPass",4,1,60,64)


fontsize_gca=14;
fontsize_title=18;
fontsize_legend=14;
rads=180/pi;scrsz = get(0,'ScreenSize');
if scrsz(3)>2*scrsz(4)
    Position_figure=[1 1 scrsz(3)/2 scrsz(4)/1.07]; 
else
	Position_figure=[1 1 scrsz(3) scrsz(4)/1.07]; 
end
figure('Name','DAQ Filters')
set(gcf,'Position',Position_figure)
set(gcf,'Color','white')
subplot(2,1,1)
hold on
% plot(Frequency,abs(DS0_resp),'b')
plot(Frequency,abs(DS1_resp),'r')
plot(Frequency,abs(DS2_resp),'k')
plot(Frequency,abs(DS3_resp),'g')
plot(Frequency,abs(DS4_resp),'m')
plot(Frequency,abs(DS5_resp),'c')
plot(Frequency,abs(DS6_resp),'m--')
plot(Frequency,abs(DS7_resp),'k--')
grid
legend('16KHz','8KHz','4KHz','2KHz','1KHz','512Hz','256Hz','128Hz')
set(gca,'FontSize',fontsize_gca,'Xscale','log','Yscale','log','Ytick',10.^[-6:1:2])
xlabel('Frequency (Hz)')
ylabel('Magnitude')

subplot(2,1,2)
hold on
% plot(Frequency,rads*angle(DS0_resp),'b')
plot(Frequency,rads*angle(DS1_resp),'r')
plot(Frequency,rads*angle(DS2_resp),'k')
plot(Frequency,rads*angle(DS3_resp),'g')
plot(Frequency,rads*angle(DS4_resp),'m')
plot(Frequency,rads*angle(DS5_resp),'c')
plot(Frequency,rads*angle(DS6_resp),'m--')
plot(Frequency,rads*angle(DS7_resp),'k--')

set(gca,'XScale','log','YScale','lin')
grid
set(gca,'FontSize',fontsize_gca,'Xscale','log','Yscale','lin','Ytick',-180:45:180)
xlabel('Frequency (Hz)')
ylabel('Angle \circ')

% save aLIGO_DAQ_Downsampling_Filters DS0 DS1 DS2 DS3 DS4