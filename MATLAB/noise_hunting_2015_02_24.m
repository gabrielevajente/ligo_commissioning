%% compute BLRMS
gps = 1108717926 + 100;
dt = 500;

d = get_data('H1:LSC-DARM_IN1_DQ', 'raw', gps, dt);
fs0 = d.rate;
d0 = d.data;
t0 = (1:length(d0))/fs0;

d = decimate(d0, 8);
fs = fs0/8;

bands = [35, 55];
outfs = 16;
    
nbands = size(bands, 1);

blrms = zeros(dt*outfs, nbands);
for i=1:nbands
    [B,A] = butter(2, bands(i,:)/(fs/2), 'bandpass');
    x = filtfilt(B, A, d);
    x = x.^2;
    [B,A] = butter(4, outfs/(fs/2), 'low');
    x = filtfilt(B,A, x);
    blrms(:,i) = x(1:fs/outfs:end);
end

blrms = blrms(outfs:end-outfs,:);
t = (1:size(blrms,1))/outfs;

%% 
aux_channels = {'H1:SUS-SRM_M3_WIT_P_DQ', 'H1:SUS-SRM_M3_WIT_Y_DQ', 'H1:SUS-PRM_M3_WIT_P_DQ', 'H1:SUS-PRM_M3_WIT_Y_DQ', ...
                'H1:SUS-SR3_M3_WIT_P_DQ', 'H1:SUS-SR3_M3_WIT_Y_DQ', 'H1:SUS-PR3_M3_WIT_P_DQ', 'H1:SUS-PR3_M3_WIT_Y_DQ', ...
                'H1:SUS-SR2_M3_WIT_P_DQ', 'H1:SUS-SR2_M3_WIT_Y_DQ', 'H1:SUS-PR2_M3_WIT_P_DQ', 'H1:SUS-PR2_M3_WIT_Y_DQ', ...};
                'H1:SUS-ITMX_L3_OPLEV_PIT_OUT_DQ', 'H1:SUS-ITMX_L3_OPLEV_YAW_OUT_DQ', 'H1:SUS-ITMY_L3_OPLEV_PIT_OUT_DQ', 'H1:SUS-ITMY_L3_OPLEV_YAW_OUT_DQ', ...
                'H1:SUS-ETMX_L3_OPLEV_PIT_OUT_DQ', 'H1:SUS-ETMX_L3_OPLEV_YAW_OUT_DQ', 'H1:SUS-ETMY_L3_OPLEV_PIT_OUT_DQ', 'H1:SUS-ETMY_L3_OPLEV_YAW_OUT_DQ', ...
                'H1:SUS-BS_M3_OPLEV_PIT_OUT_DQ', 'H1:SUS-BS_M3_OPLEV_YAW_OUT_DQ'};
aux_channels = {'H1:ASC-AS_A_DC_PIT_OUT_DQ','H1:ASC-AS_A_DC_YAW_OUT_DQ', 'H1:ASC-AS_A_RF36_I_PIT_OUT_DQ', 'H1:ASC-AS_A_RF36_I_YAW_OUT_DQ', ...
                'H1:ASC-AS_A_RF45_I_PIT_OUT_DQ', 'H1:ASC-AS_A_RF45_I_YAW_OUT_DQ', 'H1:ASC-AS_A_RF36_Q_PIT_OUT_DQ', 'H1:ASC-AS_A_RF36_Q_YAW_OUT_DQ', ...
                'H1:ASC-AS_A_RF45_Q_PIT_OUT_DQ', 'H1:ASC-AS_A_RF45_Q_YAW_OUT_DQ', ...
                'H1:ASC-AS_B_DC_PIT_OUT_DQ','H1:ASC-AS_B_DC_YAW_OUT_DQ', 'H1:ASC-AS_B_RF36_I_PIT_OUT_DQ', 'H1:ASC-AS_B_RF36_I_YAW_OUT_DQ', ...
                'H1:ASC-AS_B_RF45_I_PIT_OUT_DQ', 'H1:ASC-AS_B_RF45_I_YAW_OUT_DQ', 'H1:ASC-AS_B_RF36_Q_PIT_OUT_DQ', 'H1:ASC-AS_B_RF36_Q_YAW_OUT_DQ', ...
                'H1:ASC-AS_B_RF45_Q_PIT_OUT_DQ', 'H1:ASC-AS_B_RF45_Q_YAW_OUT_DQ', ...
                'H1:ASC-POP_A_PIT_OUT_DQ', 'H1:ASC-POP_A_YAW_OUT_DQ', 'H1:ASC-POP_B_PIT_OUT_DQ', 'H1:ASC-POP_B_YAW_OUT_DQ', ...
                'H1:ASC-REFL_A_DC_PIT_OUT_DQ','H1:ASC-REFL_A_DC_YAW_OUT_DQ', 'H1:ASC-REFL_A_RF9_I_PIT_OUT_DQ', 'H1:ASC-REFL_A_RF9_I_YAW_OUT_DQ', ...
                'H1:ASC-REFL_A_RF45_I_PIT_OUT_DQ', 'H1:ASC-REFL_A_RF45_I_YAW_OUT_DQ', 'H1:ASC-REFL_A_RF9_Q_PIT_OUT_DQ', 'H1:ASC-REFL_A_RF9_Q_YAW_OUT_DQ', ...
                'H1:ASC-REFL_A_RF45_Q_PIT_OUT_DQ', 'H1:ASC-REFL_A_RF45_Q_YAW_OUT_DQ', ...
                'H1:ASC-REFL_B_DC_PIT_OUT_DQ','H1:ASC-REFL_B_DC_YAW_OUT_DQ', 'H1:ASC-REFL_B_RF9_I_PIT_OUT_DQ', 'H1:ASC-REFL_B_RF9_I_YAW_OUT_DQ', ...
                'H1:ASC-REFL_B_RF45_I_PIT_OUT_DQ', 'H1:ASC-REFL_B_RF45_I_YAW_OUT_DQ', 'H1:ASC-REFL_B_RF9_Q_PIT_OUT_DQ', 'H1:ASC-REFL_B_RF9_Q_YAW_OUT_DQ', ...
                'H1:ASC-REFL_B_RF45_Q_PIT_OUT_DQ', 'H1:ASC-REFL_B_RF45_Q_YAW_OUT_DQ', ...
                'H1:ASC-X_TR_A_PIT_OUT_DQ', 'H1:ASC-X_TR_A_YAW_OUT_DQ', 'H1:ASC-X_TR_B_PIT_OUT_DQ', 'H1:ASC-X_TR_B_YAW_OUT_DQ', ...
                'H1:ASC-Y_TR_A_PIT_OUT_DQ', 'H1:ASC-Y_TR_A_YAW_OUT_DQ', 'H1:ASC-Y_TR_B_PIT_OUT_DQ', 'H1:ASC-Y_TR_B_YAW_OUT_DQ'};
    
d_aux = get_data(aux_channels, 'raw', gps, dt);
aux = zeros(dt * outfs, numel(d_aux));
for i=1:numel(d_aux)
    [B,A] = butter(4, outfs/d_aux(i).rate, 'low');
    x = filtfilt(B,A, d_aux(i).data);
    aux(:,i) = x(1:d_aux(i).rate/outfs:end);
    aux(:,i) = aux(:,i) - mean(aux(:,i));
    aux(:,i) = aux(:,i) / max(abs(aux(:,i)));
end
aux = aux(outfs:end-outfs,:);

% find glitches
idx = blrms> 3e-20;

figure()
for i=1:size(aux, 2)
    subplot(211)
    plot(t, aux(:,i), t(idx), aux(idx,i), 'ro')
    title(strrep(aux_channels{i}, '_', '\_'))
    subplot(212)
    [n1,x1] = hist(aux(:,i), 100);
    [n2,x2] = hist(aux(idx,i), x1);
    plot(x1, n1/sum(n1), 'b', x2, n2/sum(n2), 'r')
    pause
end



% least square fit
A = aux ./ repmat(max(abs(aux)), [size(aux,1),1]);
B = blrms ./ repmat(max(abs(blrms)), [size(blrms,1),1]);

X = [A, A.^2];
X(:, end+1) = 1;

p0 = zeros(size(X,2),1);
p = fminunc(@(p) mean(abs(B - X*p)), p0, optimset('display', 'iter', 'maxfunevals', 1e6));

figure()
plot(t, B, 'b', t, X*p, 'r')
xlabel('Time [s]')
ylabel('BLRMS [a.u.]')
legend('Data', 'Fit')
grid
