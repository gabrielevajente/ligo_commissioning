% The function gets data using 'get_data', decimates it using 'downsample_viafftcutoff', and computes the ASD using 'asd2'
%
% channels: channel name of the data to be processed
%
% start_time,duration: self explicit parameters used for get_data
%
% Fs, the new sampling frequency (after decimation)
%
% n_avg, number of averages to be used in asd2


function [ASD_Decimated, Freq, Time_series] = get_decim_and_ASD_data(channels,start_time,duration,Fs,n_avg)
 
temp = get_data(channels,'raw',start_time,duration);

Time_series = downsample_viafftcutoff(temp.data,1/temp.rate, Fs/2);

% Other downsampling methods tested:
% temp = downsample(detrend(temp.data),temp.rate/Fs);  
% temp = decimate(detrend(temp.data),temp.rate/Fs,'FIR');  
% temp = decimate(detrend(temp.data),temp.rate/Fs,6); 
% downsample_viafftcutoff works the best (see SEI log 157)

[ASD_Decimated,Freq] = asd2(Time_series,1/Fs,n_avg,2);