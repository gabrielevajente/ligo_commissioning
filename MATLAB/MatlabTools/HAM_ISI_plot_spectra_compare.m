%% HAM_ISI_plot_spectra_compare
% Sept 18, 2014 - SB
% plot the calibrated Ground and GS13 spectra (m/rt(Hz) or rad/rt(Hz))
%
% HAM_ISI_plot_spectra_compare(IFO,Chamber,start_time,duration)

function HAM_ISI_plot_spectra_compare(IFO,Chamber,start_time,start_time2,duration)


%% Data list

GRD_list={[IFO ':HPI-' Chamber '_STSINF_B_X_IN1_DQ'], ...
           [IFO ':HPI-' Chamber '_STSINF_B_Y_IN1_DQ'], ...
           [IFO ':HPI-' Chamber '_STSINF_B_Z_IN1_DQ'], ...
            };

GS13_list={[IFO ':ISI-' Chamber '_BLND_GS13X_IN1_DQ'], ...
    [IFO ':ISI-' Chamber '_BLND_GS13Y_IN1_DQ'], ...
    [IFO ':ISI-' Chamber '_BLND_GS13Z_IN1_DQ'], ...
    [IFO ':ISI-' Chamber '_BLND_GS13RX_IN1_DQ'], ...
    [IFO ':ISI-' Chamber '_BLND_GS13RY_IN1_DQ'], ...
    [IFO ':ISI-' Chamber '_BLND_GS13RZ_IN1_DQ'], ...
    };

GRD=get_data(GRD_list,'raw',start_time,duration);
GS13=get_data(GS13_list,'raw',start_time,duration);
GS13_2=get_data(GS13_list,'raw',start_time2,duration);

%% Put time series in meters/radians

for Counter = 1:length(GRD_list)
    GRD(Counter).data=GRD(Counter).data./40/1500/1638.4;
end


for Counter = 1:length(GS13_list)
    GS13(Counter).data=GS13(Counter).data.*1e-9;
end

for Counter = 1:length(GS13_list)
    GS13_2(Counter).data=GS13_2(Counter).data.*1e-9;
end

%% Power spectra calculation

for Counter=1:length(GRD_list)
    [GRD_p(Counter,:), GRD_freq] = asd2(GRD(Counter).data, 1/GRD(Counter).rate, 9, 3, @hann);
end

for Counter=1:length(GS13_list)
    [GS13_p(Counter,:), GS13_freq] = asd2(GS13(Counter).data, 1/GS13(Counter).rate, 9, 3, @hann);
end

for Counter=1:length(GS13_list)
    [GS13_p2(Counter,:), GS13_freq] = asd2(GS13_2(Counter).data, 1/GS13_2(Counter).rate, 9, 3, @hann);
end

%% Calibration
w_0=2*pi; Q=4.5; GS13_num=[1 0 0 0]; GS13_den=[1 w_0/Q w_0^2];
GS13_Model=tf(GS13_num,GS13_den);

STS_Model = 1/zpk([0 0 0],-2*pi*[pair(0.008,45)],1);

GRD_Model_resp=squeeze(freqresp(STS_Model,2*pi*GRD_freq));
GS13_Model_resp=squeeze(freqresp(GS13_Model,2*pi*GS13_freq));


%% Calibrated power spectra

for Counter = 1:length(GRD_list)
    GRD_p(Counter,:)=GRD_p(Counter,:).*transpose(GRD_Model_resp);
end


for Counter = 1:length(GS13_list)
    GS13_p(Counter,:)=GS13_p(Counter,:)./transpose(GS13_Model_resp);
end

for Counter = 1:length(GS13_list)
    GS13_p2(Counter,:)=GS13_p2(Counter,:)./transpose(GS13_Model_resp);
end
%% Noise curves
GS13_noise=SEI_sensor_noise('GS13meas',GS13_freq);

%% Plot

figure

for Counter=1:length(GRD_list)
    subplot(2,3,Counter)
    loglog(GRD_freq,abs(GRD_p(Counter,:)),'k','LineWidth',2)
    hold on
    loglog(GS13_freq,abs(GS13_p(Counter,:)),'c','LineWidth',2)
    hold on
    loglog(GS13_freq,abs(GS13_p2(Counter,:)),'r','LineWidth',2)
    hold on
    loglog(GS13_freq,abs(GS13_noise),'m-','LineWidth',2)
    hold on
    grid on
    xlabel('Frequency (Hz)','FontSize',14)
    ylabel('ASD (m/rt(Hz) or rad/rt(Hz))','FontSize',14)
    legend_str={GRD(Counter).name, GS13(Counter).name, GS13_2(Counter).name,'GS13 noise'};
    legend(legend_str,'interpreter','none')
end


for Counter=4:length(GS13_list)
    subplot(2,3,Counter)
   loglog(GS13_freq,abs(GS13_p(Counter,:)),'c','LineWidth',2)
    hold on
   loglog(GS13_freq,abs(GS13_p2(Counter,:)),'r','LineWidth',2)
    hold on
    loglog(GS13_freq,abs(GS13_noise),'m-','LineWidth',2)
    hold on
    grid on
    xlabel('Frequency (Hz)','FontSize',14)
    ylabel('ASD (m/rt(Hz) or rad/rt(Hz))','FontSize',14)
    legend_str2={GS13(Counter).name,GS13_2(Counter).name,'GS13 noise'};
    legend(legend_str2,'interpreter','none')
end

title(subplot(2,3,2),sprintf(['ASD - ' Chamber '\n Start time: ' num2str(start_time) '\n Duration ' num2str(duration) ]),'FontSize',18)
subplot(2,3,6)
IDfig
