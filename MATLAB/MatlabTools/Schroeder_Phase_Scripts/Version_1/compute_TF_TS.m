% [result, resp_data, exc_data] = ...
%   compute_TF(param, resp_data, exc_data)
%
%   compute transfer functions from a given excitation to
%   a collection of response channels
%
% param struct must contain
%   data_rate - data rate for readback and response channels
%   num_fft - length of FFT
%   num_skip - number of FFTs to skip before measuring TF
%   detrend_order - order of detrending polynomial
%                  (0 = mean, 1 = linear, etc)
%   resp_range - saturation level for each resp channel (N x 1, optional)
%
% result struct will contain
%   num - number of TFs measured ( = number of resp channels = N)
%   max - maximum value for each channel (N x 1 vector)
%   min - minimum value for each channel (N x 1 vector)
%   mean - mean value for each channel (N x 1 vector)
%   rms - RMS, after detrending, for each channel (N x 1 vector)
%   num_sat - number of saturations in each channel (N x 1 vector)
%   f - frequency vector for transfer functions and coherence (Nf x 1)
%   tf - transfer functions (Nf x N)
%   coh - coherences (Nf x N)
%   pow_exc - power spectrum of excitation (Nf x 1)
%
% Example:
%
% % generate some signals
% fs = 512;
% fRes = 0.33;
% exc_sig = get_comb_timeseries(fs, fRes, 10, 1, 40);
%
% [b, a] = ellip(4, 10, 20, 20 / fs, 'low');
% resp_sig = filter(b, a, exc_sig + 0.3 * randn(size(exc_sig)));
%
% % make parameter struct
% param.num_fft = 2 * round(fs / (2 * fRes));
% param.num_skip = 0;
% param.resp_range = 0.2;
% param.data_rate = fs;
%
% % compute the transfer function, and plot the magnitude
% [result, resp_data, exc_data] = compute_TF(param, resp_sig, exc_sig);
% loglog(result.f, abs(result.tf))

%%%%%%%%%%%%%%
% A note on windowing:
% It seems that for different windows, different amounts
% of overlap are good.  The defaults seem good, or one could
% use a variety of windows... see "help windows".
%
% The blackman window seems good, but appears to require a high
% overlap of about 75%.


function [result, resp_data, exc_data] = compute_TF(param, resp_data, exc_data,loop_num)

% numbers of things
num_resp = size(resp_data, 2);
num_points = size(resp_data, 1);

num_fft = param.num_fft(loop_num);
num_freq = round(0.50001+(param.fMax - param.fMin)/param.fRes);             %num_fft / 2 + 1;

n0 = param.num_skip * num_fft + 1; % first data point for FFTs


% check the arguments
if isfield(param, 'resp_range')   %saturation level
  if numel(param.resp_range) == 1
    param.resp_range = ones(num_resp, 1) * param.resp_range;
  elseif numel(param.resp_range) ~= num_resp
    disp(sprintf('num_resp = %d, numel(resp_range) = %d', ...
      num_resp, numel(param.resp_range)));
    error('resp_range not the same length as resp_chan_list');
  end
end

% initialize result struct
result.param = param;
result.num = num_resp;
result.max = zeros(num_resp, 1);
result.min = zeros(num_resp, 1);
result.mean = zeros(num_resp, 1);
result.rms = zeros(num_resp, 1);
result.num_sat = zeros(num_resp, 1);
result.Coarse_act_sat =zeros(num_resp, 1);%need to initalize these
result.Fine_act_sat =  zeros(num_resp, 1);
    

result.f = zeros(num_freq, 1);
result.tf = zeros(num_freq, num_resp);
result.coh = zeros(num_freq, num_resp);
%result.pow_exc = zeros(num_freq, 1);  %comment out 9/12/08 RKM

%%save time series excitation and responses
% result.ts_exc = exc_data:
% result.ts_data = resp_data;
   
% prepare for detrending and windowing
[filt_b, filt_a] = butter(2, 6 / num_fft, 'high');

win_data = hanning(num_fft);
%num_overlap = round(0.75 * num_fft);
%win_data = [];
num_overlap = [];
  current_exc_data_rate = param.exc_rate;
% detrend excitation and compute power spectrum
%a very inefficient way to get the frequency vector
try
  
if param.exc_rate > param.data_rate(loop_num)  %down sample excitation
   if param.exc_rate/param.data_rate(loop_num) == round(param.exc_rate/param.data_rate(loop_num))
     downsample = param.exc_rate/param.data_rate(loop_num);
    % exc_data =decimate(exc_data,downsample);
     
     exc_data =decimate(exc_data,downsample,512,'fir');
     current_exc_data_rate = param.exc_rate/downsample;
     
   %  [z p k]=cheby1(8,.05,2*pi*0.8*param.data_rate(loop_num),'s');
   % Chebytchev_Filters=zpk(z,p,k);
   else
     error('Not set up to do non-integer sample ratios between drive and sensor')
   end
     
   elseif param.exc_rate < param.data_rate(loop_num)  %down sample sensor data
       if param.data_rate(loop_num)/param.exc_rate == round(param.data_rate(loop_num)/param.exc_rate)
             temp_data = resp_data;
             clear resp_data
             for nn = 1:num_resp
                downsample = param.data_rate(loop_num)/ param.exc_rate;
                resp_data(:,nn) = decimate(temp_data(:,nn) ,downsample,512,'fir');
              
             end
       else 
              error('Not set up to do non-integer sample ratios between drive and sensor')
       end    
end
catch whathappened
        error_message=whathappened;
        disp(error_message.message);
    error('downsample screw up');
end


exc_data = my_detrend(exc_data, filt_b, filt_a);
%[pow_exc, result.f] = pwelch(exc_data(n0:end), ...
%    win_data, num_overlap, num_fft, param.exc_rate);
%clear pow_exc
 
%replace pwelch with  8/2010 RKM
f = 0:param.fRes:current_exc_data_rate/2; 
  
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% loop through each response channel
for n = 1:num_resp
  % basic statistics
  result.max(n) = max(resp_data(:, n));
  result.min(n) = min(resp_data(:, n));
  result.mean(n) = mean(resp_data(:, n));
  
  % saturation count
  if isfield(param, 'resp_range')
    result.num_sat(n) = sum(abs(resp_data(:, n)) > param.resp_range(n));
  end
  
  % detrend
  resp_data(:, n) = my_detrend(resp_data(:, n), filt_b, filt_a);

  % remaning rms
  result.rms(n) = sqrt(mean(resp_data(:, n).^2));
  
  % transfer function and coherence
    [tf(:, n) Freq_temp]  = tfestimate(exc_data(n0:end), resp_data(n0:end, n), ...
    win_data, num_overlap, num_fft, current_exc_data_rate);

    %if param.exc_rate > param.data_rate(loop_num)
        % Try to undo the decimation filters
        %Chebytchev_Filters_resp=squeeze(freqresp(Chebytchev_Filters,2*pi*Freq_temp));
        %Correction=1./abs(Chebytchev_Filters_resp).^2;
        %tf(:, n)=tf(:, n).*Correction;
   % end
    
%comment out the power spectra of the signal, don't really need to store this  9/12/08 RKM
  %[result.pow_spec(:,n), f2]  = pwelch(resp_data(n0:end, n), ...  %get ride of result.f2, don't need to store this
  %  win_data, num_overlap, num_fft, param.data_rate);
  
  coh(:, n) = mscohere(exc_data(n0:end), resp_data(n0:end, n), ...
    win_data, num_overlap, num_fft, current_exc_data_rate);
  
  if param.fMax <= current_exc_data_rate/2 %is drive frequency less then the nyquist frequency (after possible downsampling)
      nTF = find(f >= param.fMin & f <= param.fMax);      
  else
      nTF = find(f >= param.fMin & f <=param.data_rate(loop_num)/2);
  end

  result.f(1:length(nTF))  = f(nTF);  
   
  result.tf(1:length(nTF),n)  = tf(nTF,n);
  result.coh(1:length(nTF),n)= coh(nTF,n);
     %proably want to tack on a bunch of zeros here when the drive
     %frequency is greater then the sensor nyquist frrequency so that the
     %frequency vectors all match
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%8/20/08 removed polyfit (detrend) due to out of memory errors
function x = my_detrend(x, filt_b, filt_a)

  % disable bad scale warning (doesn't hurt)
  w_prev = warning('off', 'MATLAB:polyfit:RepeatedPointsOrRescale');

  % do polynomial fit
  xfit = (1:numel(x))' - 1;
  if numel(x) < 1e4
    pfit = polyfit(xfit, x, 2); 
  elseif numel(x) < 1e5
    pfit = polyfit(xfit(1:10:end), x(1:10:end), 2); 
  elseif numel(x) < 1e6
    pfit = polyfit(xfit(1:100:end), x(1:100:end), 2); 
  elseif numel(x) < 1e7
    pfit = polyfit(xfit(1:1000:end), x(1:1000:end), 2); 
  else
    pfit = polyfit(xfit(1:1E4:end), x(1:1E4:end), 2); 
  end
  pfit(end) = x(1);   % force first point match

  % filter data, with polynomial removed
  x = x - polyval(pfit, xfit);
  x = filter(filt_b, filt_a, x);
   
  % reset warning state
  warning(w_prev);
  