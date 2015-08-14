%% non stationary coupling approach

%% load data with SRLC noise injection
gps = 1113211711;
dt = 120 + 60;
g = GWData;
[data,t,info] = g.fetch(gps, gps+dt, {'H1:CAL-DELTAL_EXTERNAL_DQ', 'H1:LSC-SRCL_OUT_DQ'});
darm = data(:,1);
srcl = data(:,2);

aux_channels = {'H1:ASC-AS_A_RF36_I_PIT_OUT_DQ', 'H1:ASC-AS_A_RF36_I_YAW_OUT_DQ', ...
                'H1:ASC-AS_A_RF36_Q_PIT_OUT_DQ', 'H1:ASC-AS_A_RF36_Q_YAW_OUT_DQ', ...
                'H1:ASC-AS_A_RF45_I_PIT_OUT_DQ', 'H1:ASC-AS_A_RF45_I_YAW_OUT_DQ', ...
                'H1:ASC-AS_A_RF45_Q_PIT_OUT_DQ', 'H1:ASC-AS_A_RF45_Q_YAW_OUT_DQ', ...
                'H1:ASC-AS_B_RF36_I_PIT_OUT_DQ', 'H1:ASC-AS_B_RF36_I_YAW_OUT_DQ', ...
                'H1:ASC-AS_B_RF36_Q_PIT_OUT_DQ', 'H1:ASC-AS_B_RF36_Q_YAW_OUT_DQ', ...
                'H1:ASC-AS_B_RF45_I_PIT_OUT_DQ', 'H1:ASC-AS_B_RF45_I_YAW_OUT_DQ', ...
                'H1:ASC-AS_B_RF45_Q_PIT_OUT_DQ', 'H1:ASC-AS_B_RF45_Q_YAW_OUT_DQ', ...
                'H1:ASC-REFL_A_RF9_I_PIT_OUT_DQ', 'H1:ASC-REFL_A_RF9_I_YAW_OUT_DQ', ...
                'H1:ASC-REFL_A_RF9_Q_PIT_OUT_DQ', 'H1:ASC-REFL_A_RF9_Q_YAW_OUT_DQ', ...
                'H1:ASC-REFL_A_RF45_I_PIT_OUT_DQ', 'H1:ASC-REFL_A_RF45_I_YAW_OUT_DQ', ...
                'H1:ASC-REFL_A_RF45_Q_PIT_OUT_DQ', 'H1:ASC-REFL_A_RF45_Q_YAW_OUT_DQ', ...
                'H1:ASC-REFL_B_RF9_I_PIT_OUT_DQ', 'H1:ASC-REFL_B_RF9_I_YAW_OUT_DQ', ...
                'H1:ASC-REFL_B_RF9_Q_PIT_OUT_DQ', 'H1:ASC-REFL_B_RF9_Q_YAW_OUT_DQ', ...
                'H1:ASC-REFL_B_RF45_I_PIT_OUT_DQ', 'H1:ASC-REFL_B_RF45_I_YAW_OUT_DQ', ...
                'H1:ASC-REFL_B_RF45_Q_PIT_OUT_DQ', 'H1:ASC-REFL_B_RF45_Q_YAW_OUT_DQ'};
                
[d_aux,t,info] = g.fetch(gps, gps+dt, aux_channels);
darm = decimate(darm, size(darm,1) / size(d_aux,1));
srcl = decimate(srcl, size(srcl,1) / size(d_aux,1));

% minimize coherence in the 50-300 Hz region, using all aux channels
D = d_aux;
pp = zeros(size(D,2),1);
pp = fminsearch(@(pp) 1 - cohe(darm, srcl .* (1 + D * pp)), pp, optimset('display', 'iter'));

np = 2048;
[c,f] = mscohere(srcl, darm, hanning(np), np/2, np, 2048);
[c2,f] = mscohere(srcl .* (1 + D * pp), darm, hanning(np), np/2, np, 2048);

% minimize coherence in the 50-300 Hz region, using only H1:ASC-AS_A_RF45_I_YAW_OUT_DQ
D = d_aux(:,6);
pp2 = zeros(size(D,2),1);
pp2 = fminsearch(@(pp) 1 - cohe(darm, srcl .* (1 + D * pp)), pp2, optimset('display', 'iter'));

np = 2048;
[c3,f] = mscohere(srcl .* (1 + D * pp2), darm, hanning(np), np/2, np, 2048);


%% quiet time
g = GWData;
gps = 1113206116;
dt = 60*7;
[data,t,info] = g.fetch(gps, gps+dt, {'H1:CAL-DELTAL_EXTERNAL_DQ', 'H1:LSC-SRCL_OUT_DQ'});
darm0 = data(:,1);
srcl0 = data(:,2);
[data,t,info] = g.fetch(gps, gps+dt, {'H1:ASC-AS_A_RF45_I_YAW_OUT_DQ'});
asc0 = data(:,1);
darm0 = decimate(darm0, length(darm0)/length(asc0));
srcl0 = decimate(srcl0, length(srcl0)/length(asc0));

np = 2048*4;
[c,f] = mscohere(srcl0, darm0, hanning(np), np/2, np, 2048);
[c2,f] = mscohere(srcl0 .* (1 + asc0*pp2), darm0, hanning(np), np/2, np, 2048);

cal = zpk(-2*pi*[100,100,100,100], -2*pi*[1 1 1 1], 1);
cal = cal / abs(fresp(cal,0));

sd = sqrt(pwelch(darm0, hanning(np), np/2, np, 2048));
ss = sqrt(pwelch(srcl0, hanning(np), np/2, np, 2048));
sa = sqrt(pwelch(srcl0 .* (1 + asc0*pp2), hanning(np), np/2, np, 2048));