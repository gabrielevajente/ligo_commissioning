%% Read data
gps = 1109322016;
dt = 3600;
d = get_data({'H1:CAL-DELTAL_EXTERNAL_DQ', 'H1:LSC-MICH_IN1_DQ', 'H1:LSC-PRCL_IN1_DQ', 'H1:LSC-SRCL_IN1_DQ'}, 'raw', gps, dt);

fs = d(1).rate;
d0 = d(1).data;
t0 = (1:length(d0))/fs;
m0 = d(2).data;
p0 = d(3).data;
s0 = d(4).data;

d0 = decimate(d0, 8);
m0 = decimate(m0, 8);
p0 = decimate(p0, 8);
s0 = decimate(s0, 8);
fs = fs/8;

np = fs/4;
noverlap = np/2;
naver = 4;
[C,T,F] = cohegram(d0, s0, np, noverlap, naver, fs);
pcolor(T, F, C); shading flat; colorbar; caxis([0,1])

