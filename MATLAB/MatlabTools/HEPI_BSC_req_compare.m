%% HEPI_BSC_req_compare.m

% Generate the BLRMS targets for HEPI on the BSC 
% BTL Jan 31, 2012
% uses the HEPI_crossbeam_motion_DOF functions

clear
%close all
%mySVN = '/home/controls/SeismicSVN/seismic/';
mySVN = '/Users/BTL/Brians_files/SeismicSVN/seismic/';


addpath([mySVN,'HAM-ISI/Common/MatlabTools']);
addpath([mySVN,'HAM-ISI/Common/MatlabTools/HEPI_motion/']);
addpath([mySVN,'Common/MatlabTools']);


%%
freq =  logspace(-2,3,1000);
HEPI_BSC_X  = HEPI_crossbeam_motion_horz(freq);
HEPI_BSC_RY = HEPI_crossbeam_motion_rX(freq);
HEPI_BSC_Z  = HEPI_crossbeam_motion_Z(freq);
HEPI_BSC_RZ = HEPI_crossbeam_motion_rZ(freq);

HAM_noise = HEPI_HAM_guess_v4(freq);

HEPI_HAM_X  = HAM_noise(:,1);
HEPI_HAM_Z  = HAM_noise(:,2);
HEPI_HAM_RY = HAM_noise(:,3);
HEPI_HAM_RZ = HAM_noise(:,4);

crap_z_z = [4e-7*3, 2e-7, 1e-9, 1e-9];
crap_z_f = [3e-2  , 2e-1,  1  , 128];
log_crap  = interp1(log10(crap_z_f),log10(crap_z_z),log10(freq));
crap_z_ASD = 10.^log_crap;

%% make motion below 1 Hz make sense

low_freq = find(freq <=1);

HEPI_BSC_X(low_freq)  = crap_z_ASD(low_freq);
HEPI_BSC_Z(low_freq)  = crap_z_ASD(low_freq);
HEPI_BSC_RY(low_freq) = crap_z_ASD(low_freq);
HEPI_BSC_RZ(low_freq) = crap_z_ASD(low_freq);

%% extend the stuff about 100 Hz to match the 100 Hz number

high_freq      = find(freq > 100);
last_real_data = find(freq <= 100, 1 ,'last');

HEPI_BSC_X(high_freq)  = HEPI_BSC_X(last_real_data);
HEPI_BSC_Z(high_freq)  = HEPI_BSC_Z(last_real_data);
HEPI_BSC_RY(high_freq) = HEPI_BSC_RY(last_real_data);
HEPI_BSC_RZ(high_freq) = HEPI_BSC_RZ(last_real_data);

%%
figure(1)
loglog(...
    freq, HEPI_BSC_X, ...
    freq, HEPI_BSC_RY, ...
    freq, HEPI_BSC_Z, ...
    freq, HEPI_BSC_RZ, ...
    'LineWidth', 2);
axis( [ 1e-2 2e2 1e-12 1e-5 ] )
title('Advanced LIGO BSC HEPI Motion Target')
xlabel('freq (Hz)')
ylabel('motion ASD (m/rtHz)')
legend('X', 'RY', 'Z', 'RZ')
grid on


figure(2)
loglog(...
    freq, HEPI_HAM_X, ...
    freq, HEPI_HAM_RY, ...
    freq, HEPI_HAM_Z, ...
    freq, HEPI_HAM_RZ, 'LineWidth', 2);
axis( [ 1e-2 2e2 1e-12 1e-5 ] )
title('Advanced LIGO HAM HEPI Motion Target')
xlabel('freq (Hz)')
ylabel('motion ASD (m/rtHz)')
legend('X', 'RY', 'Z', 'RZ')
grid on

%% counts per meter per second for the calibrated GS13s
L4C_resp_vel = 1e9 * zpk([0 0],-2*pi*[1+1i, 1-1i]/sqrt(2),1);
L4C_resp     = tf('s') * L4C_resp_vel;
STS2_resp_vel = 1e9; % accurate between 4mHz and 50 Hz
STS2_resp     = tf('s') * STS2_resp_vel;

figure(3)
bode(L4C_resp)
title('Sensor Response, in counts/meter')
legend('L-4C');

%%
L4C_resp_FR = squeeze(freqresp(L4C_resp, 2*pi* freq)).';

BSC_HEPI_L4C_X_signal  = abs(L4C_resp_FR .* HEPI_BSC_X);
BSC_HEPI_L4C_Z_signal  = abs(L4C_resp_FR .* HEPI_BSC_Z);
BSC_HEPI_L4C_RY_signal = abs(L4C_resp_FR .* HEPI_BSC_RY);
BSC_HEPI_L4C_RZ_signal = abs(L4C_resp_FR .* HEPI_BSC_RZ);

%%
figure(4)
loglog(...
    freq, BSC_HEPI_L4C_X_signal,...
    freq, BSC_HEPI_L4C_RY_signal,...
    freq, BSC_HEPI_L4C_Z_signal,...
    freq, BSC_HEPI_L4C_RZ_signal,...
    'LineWidth', 2)
title('L4C Signal (ASD) when at motion requirement')
xlabel('freq (Hz)')
ylabel('counts/rtHz')
legend('BSC - X & Y', 'BSC - RX & RY', 'BSC - Z', 'BSC - RZ',...
    'Location','NorthWest')
grid on
xlim([0.03 200])
%% RMS signal at BSC requirement

frequencies = [0.01 0.03 0.1 0.3 1 3 10 30 128]; %logspace(-2,3,1000) for fine plot
BSC_HEPI_X_rms_vec  = zeros(1,8);
BSC_HEPI_Z_rms_vec  = zeros(1,8);
BSC_HEPI_RY_rms_vec = zeros(1,8);
BSC_HEPI_RZ_rms_vec = zeros(1,8);

for i=1:length(frequencies)-1
    BSC_HEPI_X_rms_vec(i)  = intRMS_Band(BSC_HEPI_L4C_X_signal,  freq, frequencies(i), frequencies(i+1));
    BSC_HEPI_Z_rms_vec(i)  = intRMS_Band(BSC_HEPI_L4C_Z_signal,  freq, frequencies(i), frequencies(i+1));
    BSC_HEPI_RY_rms_vec(i) = intRMS_Band(BSC_HEPI_L4C_RY_signal, freq, frequencies(i), frequencies(i+1));
    BSC_HEPI_RZ_rms_vec(i) = intRMS_Band(BSC_HEPI_L4C_RZ_signal, freq, frequencies(i), frequencies(i+1));
end
%%
figure(5)

subplot(4,1,1)

bg = bar(frequencies(3:8), log10(BSC_HEPI_X_rms_vec(3:8)), 'histc');
set(gca,'XScale','log')
grid on
title('Predicted L4C signal (RMS), BSC HEPI X at aLIGO motion target')
xlabel('freq (Hz)')
ylabel('counts (rms, log scale)')


subplot(4,1,2)

bg = bar(frequencies(3:8), log10(BSC_HEPI_Z_rms_vec(3:8)), 'histc');
set(gca,'XScale','log')
grid on
title('Predicted L4C signal (RMS), BSC HEPI Z at aLIGO motion target')
xlabel('freq (Hz)')
ylabel('counts (rms, log scale)')


subplot(4,1,3)

bg = bar(frequencies(3:8), log10(BSC_HEPI_RY_rms_vec(3:8)), 'histc');
set(gca,'XScale','log')
grid on
title('Predicted L4C signal (RMS), BSC HEPI RY at aLIGO motion target')
xlabel('freq (Hz)')
ylabel('counts (rms, log scale)')


subplot(4,1,4)

bg = bar(frequencies(3:8), log10(BSC_HEPI_RZ_rms_vec(3:8)), 'histc');
set(gca,'XScale','log')
grid on
title('Predicted L4C signal (RMS), BSC HEPI RZ at aLIGO motion target')
xlabel('freq (Hz)')
ylabel('counts (rms, log scale)')

FillPage('t')
IDfig

%% output the data



disp(' ' )
disp('The final BLRMS norms (log10) are:')
disp( ' freq :  0.03-0.1  0.1-0.3    0.3-1    1-3     3-10     10-30    30-128'); 
disp([' X / Y  ',sprintf(' %8.3f',log10(BSC_HEPI_X_rms_vec(2:8)))]);
disp(['     Z  ',sprintf(' %8.3f',log10(BSC_HEPI_Z_rms_vec(2:8)))]);
disp(['rX /rY  ',sprintf(' %8.3f',log10(BSC_HEPI_RY_rms_vec(2:8)))]);
disp(['    rZ  ',sprintf(' %8.3f',log10(BSC_HEPI_RZ_rms_vec(2:8)))]);

%%
disp(' ' )
disp('The final BLRMS counts (not log 10) are:')
disp( ' freq :  0.03-0.1  0.1-0.3    0.3-1    1-3     3-10     10-30    30-128'); 
disp([' X / Y  ',sprintf(' %8.2f',BSC_HEPI_X_rms_vec(2:8))]);
disp(['     Z  ',sprintf(' %8.2f',BSC_HEPI_Z_rms_vec(2:8))]);
disp(['rX /rY  ',sprintf(' %8.2f',BSC_HEPI_RY_rms_vec(2:8))]);
disp(['    rZ  ',sprintf(' %8.2f',BSC_HEPI_RZ_rms_vec(2:8))]);


commandwindow