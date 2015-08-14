%% IMC pitch
gpsb = 1109796196 - 60;
gpse = 1109796743 + 60;
channels = {'H1:SUS-MC1_M3_WIT_P_DQ', 'H1:SUS-MC2_M3_WIT_P_DQ', 'H1:SUS-MC3_M3_WIT_P_DQ', 'H1:IMC-PZT_PIT_OUT_DQ', ...
            'H1:IMC-WFS_A_I_PIT_OUT_DQ', 'H1:IMC-WFS_B_I_PIT_OUT_DQ', 'H1:IMC-WFS_A_DC_PIT_OUT_DQ', 'H1:IMC-WFS_B_DC_PIT_OUT_DQ', ...
            'H1:IMC-MC2_TRANS_PIT_OUT_DQ', 'H1:IMC-IM4_TRANS_PIT_OUT_DQ', ...
            'H1:PSL-ISS_SECONDLOOP_SUM14_REL_OUT_DQ', 'H1:PSL-ISS_SECONDLOOP_SUM58_REL_OUT_DQ'};
d = get_data(channels, 'raw', gpsb, gpse-gpsb);

save imc_pitch.mat d

%% IMC yaw
gpsb = 1109796832 - 60;
gpse = 1109797379 + 60;
channels = {'H1:SUS-MC1_M3_WIT_Y_DQ', 'H1:SUS-MC2_M3_WIT_Y_DQ', 'H1:SUS-MC3_M3_WIT_Y_DQ', 'H1:IMC-PZT_YAW_OUT_DQ', ...
            'H1:IMC-WFS_A_I_YAW_OUT_DQ', 'H1:IMC-WFS_B_I_YAW_OUT_DQ', 'H1:IMC-WFS_A_DC_YAW_OUT_DQ', 'H1:IMC-WFS_B_DC_YAW_OUT_DQ', ...
            'H1:IMC-MC2_TRANS_YAW_OUT_DQ', 'H1:IMC-IM4_TRANS_YAW_OUT_DQ', ...
            'H1:PSL-ISS_SECONDLOOP_SUM14_REL_OUT_DQ', 'H1:PSL-ISS_SECONDLOOP_SUM58_REL_OUT_DQ'};
d = get_data(channels, 'raw', gpsb, gpse-gpsb);

save imc_yaw.mat d

x = load('downsampling_filter256.txt');
fr = x(:,1);
t = x(:,2) + 1j*x(:,3);

