%% read data
gps = 1108981336;
dt = 7200;

% IMC F is calibrated in kHz
% CAL_DELTAL is in meters, but with a whitening: gain 1 @ DC, 5 zeros at 1
% Hz and 5 poles at 100 Hz
d = get_data({'H1:CAL-DELTAL_EXTERNAL_DQ', 'H1:IMC-F_OUT_DQ', 'H1:LSC-REFL_SERVO_ERR_OUT_DQ'}, 'raw', gps, dt);
fs0 = d(1).rate;
d0 = d(1).data;
c0 = 1e3*d(2).data; % calibrate in Hz
e0 = d(3).data;

%% Compute transfer functions
np = fs0 * 8;
[cc,f] = mscohere(c0, d0, hanning(np), np/2, np, fs0);
[tc,f] = tfestimate(c0, d0, hanning(np), np/2, np, fs0);
[ce,f] = mscohere(e0, d0, hanning(np), np/2, np, fs0);
[te,f] = tfestimate(e0, d0, hanning(np), np/2, np, fs0);

%% Keep only points with good coherence
idxc = cc>0.7 & f>1000 & ~(f>2400 & f<2500);
idxe = ce>0.7 & f>100 & ~(f>2400 & f<2500);

%% compensation for DARM signal whitening
sys = zpk(2*pi*[1,1,1,1,1], 2*pi*[100,100,100,100,100], 1e10);

%% build transfer functions
fe = f(idxe);
fc = f(idxc);
Te = 6e8*te(idxe)./(1j*f(idxe)) ./ fresp(sys, fe);
Tc = tc(idxc) ./ fresp(sys, fc);

ax(1) = subplot(211);
loglog(fe, abs(Te), 'ro', fc, abs(Tc), 'bo')
ylabel('Abs. of DARM / FREQ [m/Hz]')
xlabel('Frequency [Hz]')
legend('Inferred from DARM/ERR', 'Direct measurement from DARM/CORR' )
grid
ax(2) = subplot(212);
semilogx(fe, angle(Te), 'ro', fc, angle(Tc), 'bo')
ylabel('Phase of DARM / FREQ [rad]')
xlabel('Frequency [Hz]')
grid

