% The function gets data using 'get_data', decimates it using 'downsample_viafftcutoff', and computes the ASD using 'asd2'
%
% channels: channel name of the data to be processed
%
% start_time,duration: self explicit parameters used for get_data
%
% Fs, the new sampling frequency (after decimation)
%
% n_avg, number of averages to be used in asd2


function [Coh_Decimated,Freq] = get_decim_and_Coh_data(channel1,channel2,start_time,duration,Fs,n_avg)
 
temp1 = get_data(channel1,'raw',start_time,duration);
temp2 = get_data(channel2,'raw',start_time,duration);

Time_series1 = downsample_viafftcutoff(temp1.data,1/temp1.rate, Fs/2);
Time_series2 = downsample_viafftcutoff(temp2.data,1/temp2.rate, Fs/2);

% Other downsampling methods tested:
% temp = downsample(detrend(temp.data),temp.rate/Fs);  
% temp = decimate(detrend(temp.data),temp.rate/Fs,'FIR');  
% temp = decimate(detrend(temp.data),temp.rate/Fs,6); 
% downsample_viafftcutoff works the best (see SEI log 157)

[Coh_Decimated,Freq] = coh2(Time_series1,Time_series2,1/Fs,n_avg,2);