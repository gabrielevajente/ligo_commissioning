gps1 = 1109629000;
gps0 = gps1 - 86400;

channels = {'H1:SUS-SR2_M3_WIT_PMON', 'H1:SUS-SR2_M3_WIT_YMON', 'H1:SUS-SRM_M3_WIT_PMON', 'H1:SUS-SRM_M3_WIT_YMON', ...
            'H1:SUS-BS_M3_OPLEV_PIT_OUTPUT', 'H1:SUS-BS_M3_OPLEV_YAW_OUTPUT', ...
            'H1:LSC-POPAIR_B_RF90_I_NORM_MON', 'H1:LSC-POPAIR_B_RF18_I_NORM_MON', ... 
            'H1:LSC-POP_A_LF_NORM_MON', 'H1:LSC-ASAIR_B_RF90_I_NORM_MON', 'H1:LSC-ASAIR_B_RF18_I_NORM_MON'};
d = get_data(channels, 'raw', gps0, 86400/2);

t = [0:length(d(1).data)-1]'/16/3600;

idx = d(8).data > 50 & ~(t> 3.12e4 & t<3.227e4);

figure()
ax(1) = subplot(211);
plot(t, d(7).data.*mask(idx))
hold all
plot(t, d(8).data.*mask(idx))
plot(t, d(9).data.*mask(idx))
plot(t, d(10).data.*mask(idx)/10)
plot(t, d(11).data.*mask(idx)*5)
xlabel('Time [h]')
ylabel('Rescaled signals [a.u.]')
legend('POPAIR\_B\_RF90', 'POPAIR\_B\_RF18', 'POP\_A\_LF', 'ASAIR\_B\_RF90', 'ASAIR\_B\_RF18')
grid
ax(2) = subplot(212);
plot(t, 10*(d(1).data.*mask(idx) - mean(d(1).data(idx))))
hold all
plot(t, 10*(d(2).data.*mask(idx) - mean(d(2).data(idx))))
plot(t, (d(3).data.*mask(idx) - mean(d(3).data(idx))))
plot(t, (d(4).data.*mask(idx) - mean(d(4).data(idx))))
plot(t, 20*(d(5).data.*mask(idx) - mean(d(5).data(idx))))
plot(t, 20*(d(6).data.*mask(idx) - mean(d(6).data(idx))))
linkaxes(ax, 'x')
legend(strrep(channels(1:6), '_', '\_'))
grid
xlabel('Time [h]')
ylabel('Rescaled signals [a.u.]')
