%% HAM_ISI_plot_spectra_compare_all
% Sept 18, 2014 - SB
% plot the calibrated Ground and GS13 spectra (m/rt(Hz) or rad/rt(Hz))
%
% HAM_ISI_plot_spectra_compare_all(IFO,Chamber,start_time,duration)

function HAM_ISI_plot_spectra_compare_all(IFO,Cham_List,start_time,duration)


%% Data list
 Cham_List(1)
GRD_list={[IFO ':HPI-' char(Cham_List(1)) '_STSINF_B_X_IN1_DQ'], ...
           [IFO ':HPI-' char(Cham_List(1)) '_STSINF_B_Y_IN1_DQ'], ...
           [IFO ':HPI-' char(Cham_List(1)) '_STSINF_B_Z_IN1_DQ'], ...
            };
GRD_list        
for cham = 1:length(Cham_List)
    cham
    Cham_List(cham)
GS13_list(cham,1) =  {[IFO ':ISI-' char(Cham_List(cham)) '_BLND_GS13X_IN1_DQ']};
GS13_list(cham,2) =  {[IFO ':ISI-' char(Cham_List(cham)) '_BLND_GS13Y_IN1_DQ']};
GS13_list(cham,3) =  {[IFO ':ISI-' char(Cham_List(cham)) '_BLND_GS13Z_IN1_DQ']};
GS13_list(cham,4) =  {[IFO ':ISI-' char(Cham_List(cham)) '_BLND_GS13RX_IN1_DQ']};
GS13_list(cham,5) =  {[IFO ':ISI-' char(Cham_List(cham)) '_BLND_GS13RY_IN1_DQ']};
GS13_list(cham,6) =  {[IFO ':ISI-' char(Cham_List(cham)) '_BLND_GS13RZ_IN1_DQ']};
GS13_list                  
end
GRD=get_data(GRD_list,'raw',start_time,duration);
for cham = 1:length(Cham_List)
GS13(cham,:)=get_data(GS13_list(cham,:),'raw',start_time,duration);
end
%% Put time series in meters/radians

for Counter = 1:length(GRD_list)
    GRD(Counter).data=GRD(Counter).data./40/1500/1638.4;
end

length(GS13_list)
for Counter = 1:length(GS13_list)
    GS13(Counter).data=GS13(Counter).data.*1e-9;
end

%% Power spectra calculation

for Counter=1:length(GRD_list)
    [GRD_p(Counter,:), GRD_freq] = asd2(GRD(Counter).data, 1/GRD(Counter).rate, 9, 3, @hann);
end

for Counter=1:length(GS13_list)
    [GS13_p(Counter,:), GS13_freq] = asd2(GS13(Counter).data, 1/GS13(Counter).rate, 9, 3, @hann);
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

%% Noise curves
GS13_noise=SEI_sensor_noise('GS13meas',GS13_freq);

%% Plot
symb = ['k','b','g','r','c','m','y'];symbc=0;
for dof = 1:3
figure(dof)
    symbc=symbc+1;
    loglog(GRD_freq,abs(GRD_p(dof,:)),symb(symbc),'LineWidth',2)
    hold on
    legend_str={GRD(dof).name};
    for Counter=1:length(Cham_List)    
        symbc=symbc+1;
        loglog(GS13_freq,abs(GS13_p(Counter,:)),symb(symbc),'LineWidth',2)
        legend_str={legend_str{:},GS13(Counter).name}
    end
    symbc=symbc+1;
    loglog(GS13_freq,abs(GS13_noise),symb(symbc),'LineWidth',2)
    legend_str={legend_str{:},'GS13 noise'}
    grid on
    xlabel('Frequency (Hz)','FontSize',14)
    ylabel('ASD (m/rt(Hz) or rad/rt(Hz))','FontSize',14)
%     legend_str={GRD(Counter).name, GS13(Counter).name,'GS13 noise'};

    legend(legend_str,'interpreter','none')
    hold off
    clear legend_str
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
