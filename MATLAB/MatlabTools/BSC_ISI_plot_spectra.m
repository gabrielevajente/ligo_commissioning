

function BSC_ISI_plot_spectra(IFO,Chamber,time,duration)


%%Adding sus projection matrix%%%
addpath('/opt/rtcds/userapps/trunk/isc/common/projections/')

load ISI2SUS_projection_file.mat

EUL2CART = ISI2SUSprojections.(lower(IFO)).(lower(Chamber)).CART2EUL;


BSC2 =strcmp(Chamber,'BS');

%% Data list

GRD_list={[IFO ':HPI-' Chamber '_STSINF_B_X_IN1_DQ'], ...
           [IFO ':HPI-' Chamber '_STSINF_B_Y_IN1_DQ'], ...
           [IFO ':HPI-' Chamber '_STSINF_B_Z_IN1_DQ'], ...
            };

T240_list={[IFO ':ISI-' Chamber '_ST1_BLND_X_T240_CUR_IN1_DQ'], ...
           [IFO ':ISI-' Chamber '_ST1_BLND_Y_T240_CUR_IN1_DQ'], ...
           [IFO ':ISI-' Chamber '_ST1_BLND_RZ_T240_CUR_IN1_DQ'], ...
           [IFO ':ISI-' Chamber '_ST1_BLND_Z_T240_CUR_IN1_DQ'], ...
           [IFO ':ISI-' Chamber '_ST1_BLND_RX_T240_CUR_IN1_DQ'], ...
           [IFO ':ISI-' Chamber '_ST1_BLND_RY_T240_CUR_IN1_DQ'], ...
            };

GS13_list={[IFO ':ISI-' Chamber '_ST2_BLND_X_GS13_CUR_IN1_DQ'], ...
    [IFO ':ISI-' Chamber '_ST2_BLND_Y_GS13_CUR_IN1_DQ'], ...
    [IFO ':ISI-' Chamber '_ST2_BLND_RZ_GS13_CUR_IN1_DQ'], ...
    [IFO ':ISI-' Chamber '_ST2_BLND_Z_GS13_CUR_IN1_DQ'], ...
    [IFO ':ISI-' Chamber '_ST2_BLND_RX_GS13_CUR_IN1_DQ'], ...
    [IFO ':ISI-' Chamber '_ST2_BLND_RY_GS13_CUR_IN1_DQ'], ...
    };


if BSC2
    level = 'M3';
else
    level = 'L3';
end

OPLEV_list={[IFO ':SUS-' Chamber '_' level '_OPLEV_PIT_OUT_DQ'], ...
    [IFO ':SUS-' Chamber '_' level '_OPLEV_YAW_OUT_DQ'], ...
    };



if BSC2
    level = 'M1';
else
    level = 'M0';
end

ISI_WIT_list={[IFO ':SUS-' Chamber '_' level '_ISIWIT_L_DQ'],...
    [IFO ':SUS-' Chamber '_' level '_ISIWIT_T_DQ'],...
    [IFO ':SUS-' Chamber '_' level '_ISIWIT_V_DQ'],...
    [IFO ':SUS-' Chamber '_' level '_ISIWIT_R_DQ'],...
    [IFO ':SUS-' Chamber '_' level '_ISIWIT_P_DQ'],...
    [IFO ':SUS-' Chamber '_' level '_ISIWIT_Y_DQ'],...
    };


GRD=get_data(GRD_list,'raw',time,duration);
T240=get_data(T240_list,'raw',time,duration);
GS13=get_data(GS13_list,'raw',time,duration);
OPLEV=get_data(OPLEV_list,'raw',time,duration);
ISI_WIT=get_data(ISI_WIT_list,'raw',time,duration);


for Counter = 1:length(GRD_list)
    GRD(Counter).data=GRD(Counter).data./40/1500/1638.4;
end

for Counter = 1:length(T240_list)
    T240(Counter).data=T240(Counter).data.*1e-9;
end


for Counter = 1:length(GS13_list)
    GS13(Counter).data=GS13(Counter).data.*1e-9;
end

for Counter = 1:length(OPLEV_list)
    OPLEV(Counter).data=OPLEV(Counter).data.*1e-6;
end

for Counter = 1:length(ISI_WIT_list);
    ISI_WIT(Counter).data=ISI_WIT(Counter).data*1e-9;
end

%% Power spectra

for Counter=1:length(GRD_list)
    [GRD_p(Counter,:), GRD_freq] = asd2(GRD(Counter).data, 1/GRD(Counter).rate, 9, 3, @hann);
end

for Counter=1:length(T240_list)
    [T240_p(Counter,:), T240_freq] = asd2(T240(Counter).data, 1/T240(Counter).rate, 9, 3, @hann);
end

for Counter=1:length(GS13_list)
    [GS13_p(Counter,:), GS13_freq] = asd2(GS13(Counter).data, 1/GS13(Counter).rate, 9, 3, @hann);
end

for Counter=1:length(OPLEV_list)
    [OPLEV_p(Counter,:), OPLEV_freq] = asd2(OPLEV(Counter).data, 1/OPLEV(Counter).rate, 9, 3, @hann);
end

for Counter=1:length(ISI_WIT_list);
    [ISI_WIT_p(Counter,:), ISI_WIT_freq] = asd2(ISI_WIT(Counter).data, 1/ISI_WIT(Counter).rate , 9, 3, @hann);
end

% for Counter=1:length(ISI_WIT_list);
%     [ISI_WIT_p(Counter,:), ISI_WIT_freq] = coh2(ISI_WIT(Counter).data, 1/ISI_WIT(Counter).rate , 9, 3, @hann);
% end



%%%%

% for iDOF = 1:6
%     longcomp(iDOF).asd = EUL2CART(1,iDOF) * T240_p(iDOF,:);
% end

for Counter=1:length(GS13_list)
    [longcomp_p(Counter,:), ] =  asd2(EUL2CART(1,Counter)*GS13(Counter).data, 1/GS13(Counter).rate, 9, 3, @hann);
end


%% Calibration
w_0=2*pi; Q=1; GS13_num=[1 0 0 0]; GS13_den=[1 w_0/Q w_0^2];
GS13_Model=tf(GS13_num,GS13_den);

w_0=2*pi*0.004; Q=1/sqrt(2); T240_num=[1 0 0 0]; T240_den=[1 w_0/Q w_0^2];
T240_Model=tf(T240_num,T240_den);

STS_Model = 1/zpk([0 0 0],-2*pi*[pair(0.008,45)],1);

GRD_Model_resp=squeeze(freqresp(STS_Model,2*pi*GRD_freq));
T240_Model_resp=squeeze(freqresp(T240_Model,2*pi*T240_freq));
GS13_Model_resp=squeeze(freqresp(GS13_Model,2*pi*GS13_freq));
ISI_WIT_Model_resp=squeeze(freqresp(GS13_Model,2*pi*ISI_WIT_freq));




%% Calibrated power spectra

for Counter = 1:length(GRD_list)
    GRD_p(Counter,:)=GRD_p(Counter,:).*transpose(GRD_Model_resp);
end

for Counter = 1:length(T240_list)
    T240_p(Counter,:)=T240_p(Counter,:)./transpose(T240_Model_resp);
end

for Counter = 1:length(GS13_list)
    GS13_p(Counter,:)=GS13_p(Counter,:)./transpose(GS13_Model_resp);
end



%% Int RMS
for Counter = 1:length(OPLEV_list)
    OPLEV_rms(Counter,:)=intRMS(OPLEV_p(Counter,:),OPLEV_freq);
end

%% Noise curves
T240_noise=SEI_sensor_noise('T240meas',T240_freq);
GS13_noise=SEI_sensor_noise('GS13meas',GS13_freq);

    figure
    
    for Counter=1:length(GS13_list)
        subplot(2,3,Counter)
        loglog(T240_freq,abs(T240_p(Counter,:)),'LineWidth',2)
        hold on
        loglog(GS13_freq,abs(GS13_p(Counter,:)),'color',[0.5 1 0],'LineWidth',2)
        hold on
        loglog(T240_freq,abs(T240_noise),'r--','LineWidth',2)
        hold on
        loglog(GS13_freq,abs(GS13_noise),'m--','LineWidth',2)
        hold on
        grid on
        v=axis;
        axis([0.015 200 1e-15 1e-3])
        set(gca,'XTick',10.^(-2:2),'YTick',10.^(-15:-3))
        xlabel('Frequency (Hz)')
        ylabel('ASD [m/rtHz]')
        legend_str={T240(Counter).name,GS13(Counter).name,'T240 noise','GS13 noise','Ground'};
        legend(legend_str,'interpreter','none')
    end
    for Counter=1:2
        subplot(2,3,Counter)
        loglog(GRD_freq,abs(GRD_p(Counter,:)),'k','LineWidth',2)
        hold on
        legend_str={T240(Counter).name,GS13(Counter).name,'T240 noise','GS13 noise','Ground'};
        legend(legend_str,'interpreter','none')
    end
    for Counter=3
        subplot(2,3,Counter+1)
        loglog(GRD_freq,abs(GRD_p(Counter,:)),'k','LineWidth',2)
        hold on
        legend_str={T240(Counter+1).name,GS13(Counter+1).name,'T240 noise','GS13 noise','Ground'};
        legend(legend_str,'interpreter','none')
    end


figure
for Counter=1:length(OPLEV_list)
    subplot(2,1,Counter)
    loglog(OPLEV_freq,abs(OPLEV_p(Counter,:)),'k','LineWidth',2)
    hold on
    loglog(OPLEV_freq,abs(OPLEV_rms(Counter,:)),'b-','LineWidth',2)
    hold on
    grid on
    if Counter==1
        legend('PITCH','PITCH (RMS)')
    else
        legend('YAW','YAW (RMS)')
    end
end


figure

for iDOF = 1:6
    longcomp(iDOF).asd = abs(EUL2CART(1,iDOF) * GS13_p(iDOF,:));
end


    ll=loglog(GS13_freq,[longcomp(1).asd;...
                          longcomp(2).asd;...
                          longcomp(3).asd;...
                          longcomp(4).asd;...
                          longcomp(5).asd;...
                          longcomp(6).asd],...
               ISI_WIT_freq,abs(ISI_WIT_p(1,:)));
    grid on
    v=axis;
    axis([0.015 200 1e-15 1e-4])
    set(gca,'XTick',10.^(-2:2),'YTick',10.^(-15:-4))
    xlabel('Frequency (Hz)')
    ylabel('ASD [m/rtHz]')
    set(ll,'LineWidth',3)
    set(ll(7),'LineWidth',4.0,'LineStyle','--')
    legend(['X * ' num2str(EUL2CART(1,1),3) ' [m/m]'],...
           ['Y * ' num2str(EUL2CART(1,2),3) ' [m/m]'],...
           ['RZ * ' num2str(EUL2CART(1,3),3) ' [m/rad]'],...
           ['Z * ' num2str(EUL2CART(1,4),3) ' [m/m]'],...
           ['RX * ' num2str(EUL2CART(1,5),3) ' [m/rad]'],...
           ['RY * ' num2str(EUL2CART(1,6),3) ' [m/rad]'],...
           'L','interpreter','none')
    
    
    for Counter=1:length(GS13_list)
        figure
        loglog(T240_freq,abs(T240_p(Counter,:))*1e9,'LineWidth',2)
        hold on
        loglog(GS13_freq,abs(GS13_p(Counter,:))*1e9,'color',[0.5 1 0],'LineWidth',2)
        hold on
        loglog(T240_freq,abs(T240_noise)*1e9,'r--','LineWidth',2)
        hold on
        loglog(GS13_freq,abs(GS13_noise)*1e9,'m--','LineWidth',2)
        hold on
        if Counter ==1
            loglog(GRD_freq,abs(GRD_p(Counter,:))*1e9,'k','LineWidth',2)
            hold on
        end
        if Counter ==2
            loglog(GRD_freq,abs(GRD_p(Counter,:))*1e9,'k','LineWidth',2)
            hold on
        end
        if Counter ==4
            loglog(GRD_freq,abs(GRD_p(Counter-1,:))*1e9,'k','LineWidth',2)
            hold on
        end
        grid on
        v=axis;
        axis([0.015 200 1e-6 1e5])
        set(gca,'XTick',10.^(-2:2),'YTick',10.^(-6:5))
        xlabel('Frequency (Hz)')
        ylabel('ASD [(nm/s)/rtHz]')
        legend_str={T240(Counter).name,GS13(Counter).name,'T240 noise','GS13 noise','Ground'};
        legend(legend_str,'interpreter','none')
    end
%     for Counter=1:2
%         subplot(2,3,Counter)
%         loglog(GRD_freq,abs(GRD_p(Counter,:)),'k','LineWidth',2)
%         hold on
%         legend_str={T240(Counter).name,GS13(Counter).name,'T240 noise','GS13 noise','Ground'};
%         legend(legend_str,'interpreter','none')
%     end
%     for Counter=3
%         subplot(2,3,Counter+1)
%         loglog(GRD_freq,abs(GRD_p(Counter,:)),'k','LineWidth',2)
%         hold on
%         legend_str={T240(Counter+1).name,GS13(Counter+1).name,'T240 noise','GS13 noise','Ground'};
%         legend(legend_str,'interpreter','none')
%     end
       
      
       

end








