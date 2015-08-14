%% compute BLRMS
gps = 1108717926;
dt = 600;

d = get_data('H1:LSC-DARM_IN1_DQ', 'raw', gps, dt);
fs = d.rate;
d0 = d.data;
t0 = (1:length(d0))/fs;

d = decimate(d0, 8);
fs = fs/8;

bands = [35, 55];
outfs = 16;
    
nbands = size(bands, 1);

blrms = zeros(dt*outfs, nbands);
for i=1:nbands
    [B,A] = butter(4, bands(i,:)/(fs/2), 'bandpass');
    x = filtfilt(B, A, d);
    x = x.^2;
    [B,A] = butter(4, outfs/(fs/2), 'low');
    x = filtfilt(B,A, x);
    blrms(:,i) = x(1:fs/outfs:end);
end

blrms = blrms(outfs:end-outfs,:);
t = (1:size(blrms,1))/outfs;

%% 
aux_channels = {'H1:SUS-BS_M2_MASTER_OUT_UR_DQ', 'H1:SUS-BS_M2_MASTER_OUT_UL_DQ', 'H1:SUS-BS_M2_MASTER_OUT_LR_DQ', 'H1:SUS-BS_M2_MASTER_OUT_LL_DQ', ...
                'H1:SUS-ETMX_L3_MASTER_OUT_UR_DQ', 'H1:SUS-ETMX_L3_MASTER_OUT_UL_DQ', 'H1:SUS-ETMX_L3_MASTER_OUT_LR_DQ', 'H1:SUS-ETMX_L3_MASTER_OUT_LL_DQ', ...
                'H1:SUS-ETMX_L2_MASTER_OUT_UR_DQ', 'H1:SUS-ETMX_L2_MASTER_OUT_UL_DQ', 'H1:SUS-ETMX_L2_MASTER_OUT_LR_DQ', 'H1:SUS-ETMX_L2_MASTER_OUT_LL_DQ', ...
                'H1:SUS-ETMX_L1_MASTER_OUT_UR_DQ', 'H1:SUS-ETMX_L1_MASTER_OUT_UL_DQ', 'H1:SUS-ETMX_L1_MASTER_OUT_LR_DQ', 'H1:SUS-ETMX_L1_MASTER_OUT_LL_DQ', ...
                'H1:SUS-ETMY_L2_MASTER_OUT_UR_DQ', 'H1:SUS-ETMY_L2_MASTER_OUT_UL_DQ', 'H1:SUS-ETMY_L2_MASTER_OUT_LR_DQ', 'H1:SUS-ETMY_L2_MASTER_OUT_LL_DQ', ...
                'H1:SUS-SRM_M2_MASTER_OUT_UR_DQ', 'H1:SUS-SRM_M2_MASTER_OUT_UL_DQ', 'H1:SUS-SRM_M2_MASTER_OUT_LR_DQ', 'H1:SUS-SRM_M2_MASTER_OUT_LL_DQ', ...
                'H1:SUS-PRM_M2_MASTER_OUT_UR_DQ', 'H1:SUS-PRM_M2_MASTER_OUT_UL_DQ', 'H1:SUS-PRM_M2_MASTER_OUT_LR_DQ', 'H1:SUS-PRM_M2_MASTER_OUT_LL_DQ', ...
                'H1:SUS-SRM_M3_MASTER_OUT_UR_DQ', 'H1:SUS-SRM_M3_MASTER_OUT_UL_DQ', 'H1:SUS-SRM_M3_MASTER_OUT_LR_DQ', 'H1:SUS-SRM_M3_MASTER_OUT_LL_DQ', ...
                'H1:SUS-PRM_M3_MASTER_OUT_UR_DQ', 'H1:SUS-PRM_M3_MASTER_OUT_UL_DQ', 'H1:SUS-PRM_M3_MASTER_OUT_LR_DQ', 'H1:SUS-PRM_M3_MASTER_OUT_LL_DQ', ...
                'H1:SUS-MC2_M3_MASTER_OUT_UR_DQ', 'H1:SUS-MC2_M3_MASTER_OUT_UL_DQ', 'H1:SUS-MC2_M3_MASTER_OUT_LR_DQ', 'H1:SUS-MC2_M3_MASTER_OUT_LL_DQ', ...
                'H1:SUS-MC2_M2_MASTER_OUT_UR_DQ', 'H1:SUS-MC2_M2_MASTER_OUT_UL_DQ', 'H1:SUS-MC2_M2_MASTER_OUT_LR_DQ', 'H1:SUS-MC2_M2_MASTER_OUT_LL_DQ', ...
                'H1:SUS-MC2_M1_MASTER_OUT_LF_DQ', 'H1:SUS-MC2_M1_MASTER_OUT_RT_DQ', 'H1:SUS-MC2_M1_MASTER_OUT_SD_DQ', 'H1:SUS-MC2_M1_MASTER_OUT_T1_DQ', ...
                'H1:SUS-MC2_M1_MASTER_OUT_T2_DQ', 'H1:SUS-MC2_M1_MASTER_OUT_T3_DQ', 'H1:IMC-F_OUT_DQ'};
                
d_aux = get_data(aux_channels, 'raw', gps, dt);
aux = zeros(dt * outfs, numel(d_aux));
for i=1:numel(d_aux)
    [B,A] = butter(4, outfs/d_aux(i).rate, 'low');
    x = filtfilt(B,A, d_aux(i).data);
    aux(:,i) = x(1:d_aux(i).rate/outfs:end);
end
aux = aux(outfs:end-outfs,:);

% find glitches
idx = blrms> 5e-20;

figure()
for i=1:size(aux, 2)
    subplot(211)
    plot(t, aux(:,i), t(idx), aux(idx,i), 'ro')
    title(strrep(aux_channels{i}, '_', '\_'))
    subplot(212)
    [n1,x1] = hist(aux(:,i), 100);
    [n2,x2] = hist(aux(idx,i), x1);
    plot(x1, n1/sum(n1), x2, n2/sum(n2))
    pause
end
