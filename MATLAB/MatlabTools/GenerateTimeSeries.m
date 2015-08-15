function [time, freq, amp_spec, time_series] = GenerateTimeSeries(freqToASD, dt, tFinal)
% GenerateTimeSeries: returns a time series given a time spacing & final time
%
% Usage: [time, freq, amp_spec, time_series] = GenerateTimeSeries(freqToASD, dt, tFinal)
% where freqtoASD is a function handle.  The function asd = freqtoASD(freq)
% should accept a vector argument freq and return a vector result asd, the
% amplitude spectral density. dt is the time between data pts and tFinal is
% the requested length of the time series.  tFinal must be a multiple of
% dt. The time series is assumed to start at t=0 and end at t=(tFinal-dt).
% Outputs are:
%   time         -  a vector of times with spacing dt,
%   freq         -  a vector of frequencies used to make the time series
%   amp_spec     -  a vector of amplitude spectral density (good for debugging)
%   time_series  -  The generated time series, same size at time
%
% Example:
%   [time, freq, gnd_asd, gnd_series] = GenerateTimeSeries(@Ligo2GroundMotionL, 1/2048, 100);
%
% will return the 100 sec long simulated ground motion time series with
% 1/2048 sec time spacing using the Livingston ground ASD along with the
% ASD of the ground motion and the input frequency vector for the ASD.  The
% time output variable is ignored.
%
% To continue the example - could use these outputs to make 2 plots
% loglog(freq, gnd_asd) - check that the ASD is what you are expecting
%    and
% plot(time, gnd_series)  - to see the simulated ground motion
%
%  The idea behind the function is pretty simple - 
%  1) use the function pointer to make an ASD vs. freq.
%  2) Make the ASD look like the FFT of a time series by:
%   2a) adding a random phase to each element of the ASD, 
%   2b) making it double sided
%  3) The time series is the inverse FFT of the result of step 2.
%    note: this series is perfectly periodic 
%  4) Slide the time series around so that you start at a zero crossing
%
% Because of its FFT nature, the time series has a few special characteristics: 
%   * the time series is perfectly periodic, 
%   * the freq spacing of the ASD is 1/ tFinal
%   * the max freq (Nyquist freq) of the ASD is (1/2) * (1/dT)
%   * If there are low freq's for which the ASD function is not defined we must create them. 
%     - We just copy the lowest defined amplitude value down to DC
%   * because we pick random phases each time, every time series will be
%       different
%
% BTL and Ruslan Kurdyumov

% Author: Ruslan Kurdyumov (lifted from Brian Lantz)
% Date: June 30, 2011
% 6/30/11: Turned into function (RK)
% 7/5/11: Added function handle capability (RK)
% 7/6/11: Added asd vector to function outputs (RK)

%% make a fancy time series
% model the ground at LLO, but put in some zeros to monitor the background
% noise introduced by the model.

% use the time params from above

%time = (0:dt:tFinal-dt)';
time = linspace(0, tFinal, tFinal/dt);
dF = 1/tFinal;
max_freq = (1/2) * (1/dt);

freq = (0:dF:max_freq);  % but don't repeat the top and bottom in the set for ifft

amp_spec = freqToASD(freq);

% if any of the lower freq's are NaN, replace them with the first value
first_data_index = find(isfinite(amp_spec),1,'first');
first_data       = amp_spec(first_data_index);
amp_spec(1:first_data_index)  = first_data;

%band0_index = find(freq<.1);
%amp_spec(band0_index) = 5e-7;   % I just made this up. It's not totally crazy


%% make the asd into a 2 sided fft
angles = 2*pi*rand(size(amp_spec));
angles(1) = 0;
angles(end) = 0;

half_fft = amp_spec.*cos(angles) + 1i*amp_spec.*sin(angles);

full_fft = [half_fft, conj(half_fft(end-1:-1:2))];
%%

fft2asd_scale = sqrt(dF) * length(time) /sqrt(2);  % from the defn of ASD

time_series_raw = fft2asd_scale *  ifft(full_fft)';

%% try a time shift, instead...
% find the first zero crossing...
sign_diff = diff(sign(time_series_raw));
start_index = find(sign_diff ~= 0,1,'first');

time_series  = [time_series_raw(start_index+1:end); time_series_raw(1:start_index)];
