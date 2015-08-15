% test the ASD2 function
% BTL Sept 27, 2012


clear
close all

disp(['running ',mfilename,' on ',date])
my_colors;

%%

repo_path = '/Users/BTL/Brians_files/SeismicSVN/seismic/';
time_series_path = [repo_path,'HAM-ISI/Stanford/DAC_noise_model'];
addpath(time_series_path)

% make a fake time series from a known ASD
Ts = 1/100; % sampling time
span = 500;  % length of the time series

[time_HAM, freq_HAM, HAM_asd, HAM_series] = GenerateTimeSeries(@HAM_req, Ts, span);


figure
subplot(211);
ll=loglog(freq_HAM, HAM_asd);
set(ll(1),'LineWidth',2,'Color',orange)
title('ASD of the HAM spec')
xlabel('freq (Hz)')
ylabel('ASD (m/rtHz)')
axis tight
grid on

subplot(212)
ll=plot(time_HAM, HAM_series);
set(ll,'LineWidth',2)
title('simulated time series of HAM table motion')
xlabel('time (sec)')
ylabel('meters')
axis tight
grid on
FillPage('t')
IDfig

%%

[HAM_asd2_1avg, freq_asd2_1] = asd2(HAM_series, Ts, 1, 1, @hann);
[HAM_asd2_9avg, freq_asd2_9] = asd2(HAM_series, Ts, 9, 1, @hann);



%% compare to pwelch
len_welch = length(HAM_series);
wel_win = hanning(len_welch);
wel_overlap = 0;

[P_welch_HAM, F_welch_HAM] = pwelch(HAM_series, [], [], [], 1/Ts);
%[P_welch_HAM, F_welch_HAM] = pwelch(HAM_series, wel_win , wel_overlap, len_welch, 1/Ts);

ASD_welch = sqrt(P_welch_HAM);

%%  plots
figure
ll=loglog(...
    freq_asd2_1, HAM_asd2_1avg,'b',...
    freq_asd2_9, HAM_asd2_9avg,'k',...
    F_welch_HAM, ASD_welch,'r',...
    freq_HAM, HAM_asd, 'm');
set(ll(2),'LineWidth',2);
set(ll(3),'LineWidth',2)
set(ll(4),'LineWidth',1.5,'Color',orange)
title('ASD of the HAM spec')
legend('asd2, one avg','asd2, 9 averages (default)' , 'pwelch (default inputs)','original')
xlabel('freq (Hz)')
ylabel('ASD (m/rtHz)')
axis([1e-3, 100, 1e-12, 2e-5])
grid on
IDfig
FillPage('w')

%%  new tests added March 5, 2013 by BTL for window options

% make some sinewaves
BW = 9/span; % bin width for this test
sw_3 = 1e-7 * sqrt(2) * sqrt(BW) * sin(2*pi*3 * time_HAM');
sw_3p3 = 2e-7 * sqrt(2) * sqrt(BW) * sin(2*pi*3.3 * time_HAM');
HAM_series_w_sines = HAM_series + sw_3 + sw_3p3;

% test 1a and 2b should be identical
[HAM_asd2_test1a, freq_test] = asd2(HAM_series_w_sines, Ts, 9, 1, @hann);
[HAM_asd2_test1b, ~]         = asd2(HAM_series_w_sines, Ts, 9, 1, @hann,'periodic');

test_diff_1 = HAM_asd2_test1a - HAM_asd2_test1b;
disp('The biggest difference is ')
disp(max(abs(test_diff_1)))

[HAM_asd2_test2a, ~] = asd2(HAM_series_w_sines, Ts, 9, 1, @tukeywin, 0.2);
[HAM_asd2_test2b, ~] = asd2(HAM_series_w_sines, Ts, 9, 1, @tukeywin, 0.5);

[HAM_asd2_test3, ~] = asd2(HAM_series_w_sines, Ts, 9, 1, @taylorwin, 5, -50);
% yick! taylor doesn't go to 0 at the ends,
% and the high freq stuff is crap!
% but, the asd2 function will take 2 arguments.


[P_welch_HAM_test, F_welch_HAM_test] = pwelch(HAM_series_w_sines, [], [], [], 1/Ts);
A_welch_HAM_test = sqrt(P_welch_HAM_test);
%%
figure
ll = loglog(...
    freq_test, HAM_asd2_test1a, 'b',...
    freq_test, HAM_asd2_test2b, 'g',...
    freq_test, HAM_asd2_test2a, 'r',...
    freq_HAM, HAM_asd, 'm');

set(ll,'LineWidth',1.5);
set(ll(4),'LineWidth',1,'Color',orange)

legend('Periodic Hanning window',...
    'Tukey at 0.5', 'Tukey at 0.2',...
    'HAM req')

grid on
FillPage('w')
IDfig

figure
ll = semilogy(...
    freq_test, HAM_asd2_test1a, 'b-x',...
    freq_test, HAM_asd2_test2b, 'g-x',...
    freq_test, HAM_asd2_test2a, 'r-x',...
    freq_HAM, HAM_asd, 'm');

set(ll,'LineWidth',1.5);
set(ll(4),'LineWidth',1,'Color',orange)

axis([2.8, 3.5, 3e-11, 5e-7])
legend('Periodic Hanning window',...
    'Tukey at 0.5', 'Tukey at 0.2',...
    'HAM req','Location','north')

grid on
FillPage('w')
IDfig

%%
figure
ll = semilogy(...
    F_welch_HAM_test, A_welch_HAM_test, 'm-x', ...
    freq_test, HAM_asd2_test1a, 'b-x',...
    freq_test, HAM_asd2_test2b, 'g-x',...
    freq_test, HAM_asd2_test2a, 'r-x',...
    freq_HAM, HAM_asd, 'm');

set(ll,'LineWidth',1.5);
set(ll(5),'LineWidth',1,'Color',orange)

axis([2.8, 3.5, 3e-11, 5e-7])
legend('PWelch w defaults','Periodic Hanning window',...
    'Tukey at 0.5', 'Tukey at 0.2',...
    'HAM req','Location','north')

grid on
FillPage('w')
IDfig
