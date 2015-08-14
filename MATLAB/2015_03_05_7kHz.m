%% Full lock
gps = 1109513051; %1109498951;
dt = 600;
data = get_data({'H1:CAL-DELTAL_EXTERNAL_DQ', 'H1:PSL-ISS_SECONDLOOP_SUM14_REL_OUT_DQ', 'H1:IMC-F_OUT_DQ'}, 'raw', gps, dt);
fs = data(1).rate;
d = data(1).data;
iss = data(2).data;
imc = data(3).data;
t0 = (1:length(d0))/fs;

np = 10*fs;
[sp,fr] = pwelch(d, hanning(np), np/2, np, fs);
sp = sqrt(sp);

%% Full lock
gps = 1109498951;
dt = 600;
d = get_data({'H1:CAL-DELTAL_EXTERNAL_DQ'}, 'raw', gps, dt);
fs = d(1).rate;
d = d.data;
t0 = (1:length(d0))/fs;

np = 10*fs;
[sp2,fr] = pwelch(d, hanning(np), np/2, np, fs);
sp2 = sqrt(sp2);loglog(fr, sp, fr, spi, fr, sp .* sqrt(c))

[spi,fr] = pwelch(iss, hanning(np), np/2, np, fs);
spi = sqrt(spi);

np = 10*fs;
[c1,fr] = mscohere(d, iss, hanning(np), np/2, np, fs);
[c2,fr] = mscohere(d, imc, hanning(np), np/2, np, fs);

np = fs;
[S,F,T] = spectrogram(d, hanning(np), np/2, np, fs);
[Si,F,T] = spectrogram(iss, hanning(np), np/2, np, fs);
[Sm,F,T] = spectrogram(imc, hanning(np), np/2, np, fs);

[C,T,F] = cohegram(d, iss, np, np/2, 5, fs);

np = fs;
[sp,fr] = pwelch(d, hanning(np), np/2, np, fs);
sp2 = sqrt(sp2);
[spi,fr] = pwelch(iss, hanning(np), np/2, np, fs);
spi = sqrt(spi);
[c,fr] = mscohere(d, iss, hanning(np), np/2, np, fs);


loglog(fr, sp, fr, spi, fr, sp .* sqrt(c))
