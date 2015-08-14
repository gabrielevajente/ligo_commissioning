%% Full lock
gps = 1109462416+13*3600+600;
dt = 600;
d = get_data({'H1:OMC-DCPD_A_OUT_DQ', 'H1:OMC-DCPD_B_OUT_DQ'}, 'raw', gps, dt);
fs = d(1).rate;
a1 = d(1).data;
b1 = d(2).data;
t0 = (1:length(d0))/fs;

np = fs/4;
[c1,f] = mscohere(a1, b1, hanning(np), np/2, np, fs);
sa1 = sqrt(pwelch(a1, hanning(np), np/2, np, fs));
sb1 = sqrt(pwelch(b1, hanning(np), np/2, np, fs));

sc1 = sa1 .* sqrt(c1);
su1 = sa1 .* sqrt(1 - c1);

%% Straight beam
gps = 1109470816;
dt = 600;
d = get_data({'H1:OMC-DCPD_A_OUT_DQ', 'H1:OMC-DCPD_B_OUT_DQ'}, 'raw', gps, dt);
fs = d(1).rate;
a2 = d(1).data;
b2 = d(2).data;
t0 = (1:length(d0))/fs;

np = fs/4;
[c2,f] = mscohere(a2, b2, hanning(np), np/2, np, fs);
sa2 = sqrt(pwelch(a2, hanning(np), np/2, np, fs));
sb2 = sqrt(pwelch(b2, hanning(np), np/2, np, fs));

sc2 = sa2 .* sqrt(c2);
su2 = sa2 .* sqrt(1 - c2);


%% Straight beam
gps = 1109563000;
dt = 600;
d = get_data({'H1:OMC-DCPD_A_OUT_DQ', 'H1:OMC-DCPD_B_OUT_DQ'}, 'raw', gps, dt);
fs = d(1).rate;
a3 = d(1).data;
b3 = d(2).data;
t0 = (1:length(d0))/fs;

np = fs/4;
[c3,f] = mscohere(a3, b3, hanning(np), np/2, np, fs);
sa3 = sqrt(pwelch(a3, hanning(np), np/2, np, fs));
sb3 = sqrt(pwelch(b3, hanning(np), np/2, np, fs));

sc3 = sa3 .* sqrt(c3);
su3 = sa3 .* sqrt(1 - c3);


