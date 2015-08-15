%% HAM_BSC_req_compare.m

% Compare the requirement for the HAM and BSC

clear
%close all
addpath /home/controls/SeismicSVN/seismic/HAM-ISI/Common/MatlabTools
addpath /home/controls/SeismicSVN/seismic/Common/MatlabTools
addpath /home/controls/SeismicSVN/seismic/BSC-ISI/Common/Calibration_BSC_ISI/

%%
freq =  logspace(-2,3,10000);
[good_vibrations sideways_vibrations upways_vibrations] = HAM_req(freq);
better_vibrations = BSC_req(freq);

figure(1)
subplot(1,2,1)
loglog(freq, good_vibrations, freq, sideways_vibrations, freq, upways_vibrations, freq, better_vibrations, 'LineWidth', 2)
axis( [ 1e-2 1e3 1e-14 1e-5 ] )
title('Advanced LIGO Seismic Platform Motion Requirement')
xlabel('freq (Hz)')
ylabel('motion ASD (m/rtHz)')
legend('HAM236/BSCST1', 'HAM45(h)', 'HAM45(v)', 'BSCST2')
grid on

% counts per meter for the calibrated GS13s
GS13_resp = 1e9 * tf('s') * zpk([0 0],-2*pi*[1+1i, 1-1i]/sqrt(2), (2*pi*1)^2);
T240_resp = 1e9 * tf('s'); % Accurate only between 4 mHz and 50 Hz
ST1_BLND_resp = 1e9 * tf(1); % Accurate above 30mHz to high frequency

figure(2)
bode(GS13_resp, T240_resp, ST1_BLND_resp)
title('Sensor Response, in counts/meter')
legend('GS-13', 'T240', 'ST1 BLEND');

GS13_resp_FR = squeeze(freqresp(GS13_resp, 2*pi* freq)).';
T240_resp_FR = squeeze(freqresp(T240_resp, 2*pi* freq)).';
%ST1_BLND_resp_FR = squeeze(freqresp(ST1_BLND_resp, 2*pi* freq)).';

HAM236_GS13_signal = abs(GS13_resp_FR .* good_vibrations);
HAM45H_GS13_signal = abs(GS13_resp_FR .* sideways_vibrations);
HAM45V_GS13_signal = abs(GS13_resp_FR .* upways_vibrations);
BSCST1_T240_signal = abs(T240_resp_FR .* good_vibrations);
%BSCST1_BLND_signal = abs(ST1_BLND_resp_FR .* good_vibrations);
BSCST2_GS13_signal = abs(GS13_resp_FR .* better_vibrations);

figure(1)
subplot(1,2,2)
loglog(freq, HAM236_GS13_signal, freq, HAM45H_GS13_signal, freq, HAM45V_GS13_signal, freq, BSCST1_T240_signal, freq, BSCST2_GS13_signal, 'LineWidth', 2)
title('Signal (ASD) when at motion requirement')
xlabel('freq (Hz)')
ylabel('counts/rtHz')
legend('HAM236', 'HAM45(h)', 'HAM45(v)', 'BSCST1 T240', 'BSCST2')
grid on

%% RMS signal at BSC requirement

frequencies = [0.01 0.03 0.1 0.3 1 3 10 30 100]; %logspace(-2,3,1000) for fine plot
HAM236_rms_vec = zeros(1,8);
HAM45H_rms_vec = zeros(1,8);
HAM45V_rms_vec = zeros(1,8);
BSCST1_T240_rms_vec = zeros(1,8);
BSCST1_BLND_rms_vec = zeros(1,8);
BSCST2_rms_vec = zeros(1,8);

for i=1:length(frequencies)-1
    HAM236_rms_vec(i) = intRMS_Band(HAM236_GS13_signal, freq, frequencies(i), frequencies(i+1));
    HAM45H_rms_vec(i) = intRMS_Band(HAM45H_GS13_signal, freq, frequencies(i), frequencies(i+1));
    HAM45V_rms_vec(i) = intRMS_Band(HAM45V_GS13_signal, freq, frequencies(i), frequencies(i+1));
    BSCST1_T240_rms_vec(i) = intRMS_Band(BSCST1_T240_signal, freq, frequencies(i), frequencies(i+1));
    BSCST1_BLND_rms_vec(i) = intRMS_Band(BSCST1_BLND_signal, freq, frequencies(i), frequencies(i+1));
    BSCST2_rms_vec(i) = intRMS_Band(BSCST2_GS13_signal, freq, frequencies(i), frequencies(i+1));  
end

figure(3)
subplot(3,2,1)

bg = bar(frequencies(2:8), log10(HAM236_rms_vec(2:8)), 'histc');
set(gca,'XScale','log')
grid on
title('Predicted GS13 signal (RMS) when HAM236 is at aLIGO motion requirement')
xlabel('freq (Hz)')
ylabel('counts (rms, log scale)')

subplot(3,2,2)

bg = bar(frequencies(2:8), log10(BSCST2_rms_vec(2:8)), 'histc');
set(gca,'XScale','log')
axis( [1e-2 1e2 0 3.5] )
grid on
title('Predicted GS13 signal (RMS) when platform BSCST2 is at aLIGO motion requirement')
xlabel('freq (Hz)')
ylabel('counts (rms, log scale)')

subplot(3,2,3)

bg = bar(frequencies(2:8), log10(HAM45H_rms_vec(2:8)), 'histc');
set(gca,'XScale','log')
grid on
title('Predicted GS13 signal (RMS) when HAM45 (horizontal) is at aLIGO motion requirement')
xlabel('freq (Hz)')
ylabel('counts (rms, log scale)')

subplot(3,2,4)

bg = bar(frequencies(2:8), log10(HAM45V_rms_vec(2:8)), 'histc');
set(gca,'XScale','log')
grid on
title('Predicted GS13 signal (RMS) when HAM45 (vertical) is at aLIGO motion requirement')
xlabel('freq (Hz)')
ylabel('counts (rms, log scale)')

subplot(3,2,5)

bg = bar(frequencies(2:8), log10(BSCST1_T240_rms_vec(2:8)), 'histc');
set(gca,'XScale','log')
axis( [1e-2 1e2 0 3.5] )
grid on
title('Predicted T240 signal (RMS) when BSCST1 (vertical) is at HAM236 motion requirement')
xlabel('freq (Hz)')
ylabel('counts (rms, log scale)')

%{
subplot(3,2,6)

bg = bar(frequencies(2:8), log10(BSCST1_BLND_rms_vec(2:8)), 'histc');
set(gca,'XScale','log')
axis( [1e-2 1e2 0 3.5] )
grid on
title('Predicted BLND signal (RMS) when BSCST1 (vertical) is at HAM236 motion requirement')
xlabel('freq (Hz)')
ylabel('counts (rms, log scale)')
%}
