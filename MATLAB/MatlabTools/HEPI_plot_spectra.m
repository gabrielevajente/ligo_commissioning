%% HEPI_plot_spectra
% Sept 18, 2014 - SB
% plot the calibrated Ground and L4C spectra (m/rt(Hz) or rad/rt(Hz))
%
% HEPI_plot_spectra(IFO,Chamber,start_time,duration)

function HEPI_plot_spectra(IFO,Chamber,start_time,duration)


%% Data list

GRD_list={[IFO ':HPI-' Chamber '_STSINF_B_X_IN1_DQ'], ...
           [IFO ':HPI-' Chamber '_STSINF_B_Y_IN1_DQ'], ...
           [IFO ':HPI-' Chamber '_STSINF_B_Z_IN1_DQ'], ...
            };

L4C_list={[IFO ':HPI-' Chamber '_BLND_L4C_X_IN1_DQ'], ...
    [IFO ':HPI-' Chamber '_BLND_L4C_Y_IN1_DQ'], ...
    [IFO ':HPI-' Chamber '_BLND_L4C_Z_IN1_DQ'], ...
    [IFO ':HPI-' Chamber '_BLND_L4C_RX_IN1_DQ'], ...
    [IFO ':HPI-' Chamber '_BLND_L4C_RY_IN1_DQ'], ...
    [IFO ':HPI-' Chamber '_BLND_L4C_RZ_IN1_DQ'], ...
    };

GRD=get_data(GRD_list,'raw',start_time,duration);
L4C=get_data(L4C_list,'raw',start_time,duration);

%% Put time series in meters/radians

for Counter = 1:length(GRD_list)
    GRD(Counter).data=GRD(Counter).data./40/1500/1638.4;
end


for Counter = 1:length(L4C_list)
    L4C(Counter).data=L4C(Counter).data.*1e-9;
end

%% Power spectra calculation

for Counter=1:length(GRD_list)
    [GRD_p(Counter,:), GRD_freq] = asd2(GRD(Counter).data, 1/GRD(Counter).rate, 9, 3, @hann);
end

for Counter=1:length(L4C_list)
    [L4C_p(Counter,:), L4C_freq] = asd2(L4C(Counter).data, 1/L4C(Counter).rate, 9, 3, @hann);
end


%% Calibration
w_0=2*pi; Q=4.5; L4C_num=[1 0 0 0]; L4C_den=[1 w_0/Q w_0^2];
L4C_Model=tf(L4C_num,L4C_den);

STS_Model = 1/zpk([0 0 0],-2*pi*[pair(0.008,45)],1);

GRD_Model_resp=squeeze(freqresp(STS_Model,2*pi*GRD_freq));
L4C_Model_resp=squeeze(freqresp(L4C_Model,2*pi*L4C_freq));


%% Calibrated power spectra

for Counter = 1:length(GRD_list)
    GRD_p(Counter,:)=GRD_p(Counter,:).*transpose(GRD_Model_resp);
end


for Counter = 1:length(L4C_list)
    L4C_p(Counter,:)=L4C_p(Counter,:)./transpose(L4C_Model_resp);
end

%% Noise curves
L4C_noise=SEI_sensor_noise('L4Cmeas',L4C_freq);

%% Plot

figure

XLim([.01 100])
YLim([1e-12 1e-4])
% xlim('manual')
% set(gca,'FontSize',fontsize_gca,'XLim',xrange,'YLim',[1E-4 1E7],'Ytick',10.^[-4:7])
% set(gca,'FontSize',fontsize_gca,'XLim',xrange,'YLim',[1E-4 1E7],'Ytick',10.^[-4:7])
for Counter=1:length(GRD_list)
    subplot(2,3,Counter)
    loglog(GRD_freq,abs(GRD_p(Counter,:)),'k','LineWidth',2)
    hold on
    loglog(L4C_freq,abs(L4C_p(Counter,:)),'c','LineWidth',2)
    hold on
    loglog(L4C_freq,abs(L4C_noise),'m-','LineWidth',2)
    hold on
    grid on
    xlabel('Frequency (Hz)','FontSize',14)
    ylabel('ASD (m/rt(Hz) or rad/rt(Hz))','FontSize',14)
    legend_str={GRD(Counter).name, L4C(Counter).name,'L4C noise'};
    legend(legend_str,'interpreter','none')
end


for Counter=3:length(L4C_list)
    subplot(2,3,Counter)
   loglog(L4C_freq,abs(L4C_p(Counter,:)),'c','LineWidth',2)
    hold on
    loglog(L4C_freq,abs(L4C_noise),'m-','LineWidth',2)
    hold on
    grid on
    xlabel('Frequency (Hz)','FontSize',14)
    ylabel('ASD (m/rt(Hz) or rad/rt(Hz))','FontSize',14)
    legend_str2={L4C(Counter).name,'L4C noise'};
    legend(legend_str2,'interpreter','none')
end

title(subplot(2,3,2),sprintf(['ASD - ' Chamber '\n Start time: ' num2str(start_time) '\n Duration ' num2str(duration) ]),'FontSize',18)
subplot(2,3,6)
IDfig
