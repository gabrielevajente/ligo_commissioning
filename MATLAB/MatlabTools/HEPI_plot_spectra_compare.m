%% HEPI_plot_spectra_compare
% Oct 24, 2014 - HR
% plot the calibrated Ground and L4C spectra (m/rt(Hz) or rad/rt(Hz))
%
% HEPI_plot_spectra_compare(IFO,Chamber,start_time,duration)

function HEPI_plot_spectra_compare(IFO,Chamber,Chamber2,start_time,start_time2,duration)


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
L4C_list2={[IFO ':HPI-' Chamber2 '_BLND_L4C_X_IN1_DQ'], ...
           [IFO ':HPI-' Chamber2 '_BLND_L4C_Y_IN1_DQ'], ...
           [IFO ':HPI-' Chamber2 '_BLND_L4C_Z_IN1_DQ'], ...
           [IFO ':HPI-' Chamber2 '_BLND_L4C_RX_IN1_DQ'], ...
           [IFO ':HPI-' Chamber2 '_BLND_L4C_RY_IN1_DQ'], ...
           [IFO ':HPI-' Chamber2 '_BLND_L4C_RZ_IN1_DQ'], ...
           };

GRD=get_data(GRD_list,'raw',start_time,duration);
GRD2=get_data(GRD_list,'raw',start_time2,duration);
L4C=get_data(L4C_list,'raw',start_time,duration);
L4C_2=get_data(L4C_list2,'raw',start_time2,duration);
%% Put time series in meters/radians

for Counter = 1:length(GRD_list)
    GRD(Counter).data=GRD(Counter).data./40/1500/1638.4;
    GRD2(Counter).data=GRD2(Counter).data./40/1500/1638.4;
end


for Counter = 1:length(L4C_list)
    L4C(Counter).data=L4C(Counter).data.*1e-9;
    L4C_2(Counter).data=L4C_2(Counter).data.*1e-9;
end

%% Power spectra calculation

for Counter=1:length(GRD_list)
    [GRD_p(Counter,:), GRD_freq] = asd2(GRD(Counter).data, 1/GRD(Counter).rate, 9, 3, @hann);
    [GRD2_p(Counter,:), GRD_freq] = asd2(GRD2(Counter).data, 1/GRD2(Counter).rate, 9, 3, @hann);
end

for Counter=1:length(L4C_list)
    [L4C_p(Counter,:), L4C_freq] = asd2(L4C(Counter).data, 1/L4C(Counter).rate, 9, 3, @hann);
end

for Counter=1:length(L4C_list2)
    [L4C_2_p(Counter,:), L4C_2_freq] = asd2(L4C_2(Counter).data, 1/L4C_2(Counter).rate, 9, 3, @hann);
end

%% Calibration
w_0=2*pi; Q=4.5;
L4C_num=[1 0 0 0]; L4C_den=[1 w_0/Q w_0^2];
L4C_Model=tf(L4C_num,L4C_den);
% L4C_2_num=[1 0 0 0]; L4C_2_den=[1 w_0/Q w_0^2];
% L4C_2_Model=tf(L4C_2_num,L4C_den);

STS_Model = 1/zpk([0 0 0],-2*pi*[pair(0.008,45)],1);

GRD_Model_resp=squeeze(freqresp(STS_Model,2*pi*GRD_freq));
L4C_Model_resp=squeeze(freqresp(L4C_Model,2*pi*L4C_freq));
% L4C_2_Model_resp=squeeze(freqresp(L4C_2_Model,2*pi*L4C_2_freq));


%% Calibrated power spectra

for Counter = 1:length(GRD_list)
    GRD_p(Counter,:)=GRD_p(Counter,:).*transpose(GRD_Model_resp);
    GRD2_p(Counter,:)=GRD2_p(Counter,:).*transpose(GRD_Model_resp);
end


for Counter = 1:length(L4C_list)
    L4C_p(Counter,:)=L4C_p(Counter,:)./transpose(L4C_Model_resp);
end

for Counter = 1:length(L4C_list2)
    L4C_2_p(Counter,:)=L4C_2_p(Counter,:)./transpose(L4C_Model_resp);
end


%% Noise curves
L4C_noise=SEI_sensor_noise('L4Cmeas',L4C_freq);

%% Plot

figure

for Counter=1:length(GRD_list)
    subplot(2,3,Counter)
    loglog(GRD_freq,abs(GRD_p(Counter,:)),'k','LineWidth',2)
    xlim([0.008 500])
    ylim([1e-12 1e-4])
    hold on
    loglog(GRD_freq,abs(GRD2_p(Counter,:)),'g','LineWidth',2)
    loglog(L4C_freq,abs(L4C_p(Counter,:)),'c','LineWidth',2)
    loglog(L4C_2_freq,abs(L4C_2_p(Counter,:)),'r','LineWidth',2)
    loglog(L4C_freq,abs(L4C_noise),'m-','LineWidth',2)
    grid on
    xlabel('Frequency (Hz)','FontSize',14)
    ylabel('ASD (m/rt(Hz) or rad/rt(Hz))','FontSize',14)
    legend_str={GRD(Counter).name, GRD2(Counter).name, L4C(Counter).name, L4C_2(Counter).name,'L4C noise'};
    legend(legend_str,'interpreter','none')
end


for Counter=4:length(L4C_list)
    subplot(2,3,Counter)
   loglog(L4C_freq,abs(L4C_p(Counter,:)),'c','LineWidth',2)
    xlim([0.008 500])
    ylim([1e-12 1e-4])
    hold on
    loglog(L4C_2_freq,abs(L4C_2_p(Counter,:)),'r','LineWidth',2)
    loglog(L4C_freq,abs(L4C_noise),'m-','LineWidth',2)
    grid on
    xlabel('Frequency (Hz)','FontSize',14)
    ylabel('ASD (m/rt(Hz) or rad/rt(Hz))','FontSize',14)
    legend_str2={L4C(Counter).name, L4C_2(Counter).name,'L4C noise'};
    legend(legend_str2,'interpreter','none')
end
FillPage('w')
title(subplot(2,3,2),sprintf(['ASD - ' Chamber ' Versus ' Chamber2 '\n Start time1: ' num2str(start_time) '\n Start time2: ' num2str(start_time2) ' Duration ' num2str(duration) ]),'FontSize',18)
subplot(2,3,6)
IDfig
