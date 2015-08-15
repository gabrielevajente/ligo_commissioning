%%
function [filtered_timeseries] = filter_bandpass(input_timeseries,sample_time,freq_low,freq_high,freq_of_interest)

n_points = length(input_timeseries);

duration      = sample_time * n_points;  % number of sec of  data
dF            = 1/duration;

fftdata = fft(input_timeseries);
index_keeppoints_low   = floor(freq_low/dF)+1;  % add 1 because first freq is 0 Hz. 
index_keeppoints_high   = ceil(freq_high/dF)+1;

fftdata(1:index_keeppoints_low) = 0;
fftdata(end-(index_keeppoints_low-2):end) = 0;
fftdata(index_keeppoints_high:end-(index_keeppoints_high-2)) = 0;

filtered_timeseries = ifft(fftdata);

%%