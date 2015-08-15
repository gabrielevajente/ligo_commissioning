function [downsampled_timeseries,downsample_ratio] = downsample_viafftcutoff(input_timeseries,sample_time, new_max_freq)
%downsample_viafftcutoff  downsamples a data set by removing all high freq data
%  [downsampled_timeseries,downsample_ratio] = downsample_viafftcutoff(input_timeseries,sample_time, new_max_freq)
%
%  input_timeseries is the original timeseries.
% sample_time   time between samples in original timeseries, e.g. 1/2048
% new_max_freq  in Hz, max freq to keep. 
% 
% the data will be downsampled by original_max_freq/new_max_freq.
% this ratio is returned as downsample_ratio
% the original_max_freq is (1/sample_time) / 2 
%   (e.g. 1028 Hz in our example)
%
% so if you try
%
%  [small_data,downsample_ratio] = downsample_BTL(big_data, 1/2048, 128)
% then the small_data time series will have freq info only below 128 Hz,
% downsample_ratio will be 10, and the length of small_data 
% will be 1/10 the length of the original data set.

n_points_orig = length(input_timeseries);

data_size     = size(input_timeseries);
if data_size(1) == 1  % it is a row vector
    input_timeseries = input_timeseries';
    flipped_dim = true;
else
    flipped_dim = false;
end


original_max_freq    = (1/sample_time)/2;  % nyquist freq of orig data
downsample_ratio_raw = original_max_freq/new_max_freq;
downsample_ratio     = floor(downsample_ratio_raw);

if downsample_ratio ~= downsample_ratio_raw
    disp(' ')
    disp('WARNING: the new max freq must be an integer dividor')
    disp(['  of the nyquist freq, (',num2str(original_max_freq),' Hz)'])
    new_max_freq = original_max_freq / downsample_ratio;
    disp(['  reseting new_max_freq to ',num2str(new_max_freq)]);
end

final_timeseries_length_raw = n_points_orig/downsample_ratio;

if floor(final_timeseries_length_raw) ~= final_timeseries_length_raw
    points_to_drop = n_points_orig - downsample_ratio*floor(final_timeseries_length_raw);
    points_to_keep = n_points_orig - points_to_drop;  % number, not an vector
    
    disp(' ')
    disp('WARNING:  the downsampling rate you have is not ')
    disp('  a factor of the length of the time series.')
    disp('  The time series will be truncated')
    disp(['  The last ',num2str(points_to_drop),' points will be dropped from the series'])
    disp(['  So we will only use ',num2str(points_to_keep),' of the original ',num2str(n_points_orig),' points']);
    disp(' ')
    % note that the max freq is set by the sample rate, and not by the span
    % so these rounding operations for the max_freq and the points_to_keep
    % are not iterative;
 
    timeseries_to_process = input_timeseries(1:points_to_keep);
    n_points = points_to_keep;
else
    timeseries_to_process = input_timeseries;
    n_points = n_points_orig;
end

duration      = sample_time * n_points;  % number of sec of  data
dF            = 1/duration;

index_keeppoints   = floor(new_max_freq/dF + 1);  % add 1 because first freq is 0 Hz.
inputdata_raw_fft  = fft(timeseries_to_process);

data_lowfreq_onesided_fft = inputdata_raw_fft(1:index_keeppoints);
data_lowfreq_fft = [data_lowfreq_onesided_fft(1:end-1);0; ...
    conj(data_lowfreq_onesided_fft(end-1:-1:2))]; 
% set the 128 Hz component to 0
% the complex part is very small
downsampled_timeseries = ifft(data_lowfreq_fft)/downsample_ratio;

if flipped_dim == true
    downsampled_timeseries = downsampled_timeseries';
end








