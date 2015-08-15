function return_struct = downsample_viafft_struct2(orig_struct, new_nyquist_freq)
% downsample_viafft_struct2    applies downsampleviafft to an mDV structure
% acts just like downsample_viafft_struct, but uses a bit less memory
% BTL Jan 9, 2008
%   call as 
%   return_struct = downsample_viafft_struct(orig_struct,new_nyquist_freq)
% 
% return_struct is just like the original mDV struct (orig_struct) except
% 0) THE MEAN IS REMOVED FROM THE DATA
% 1) the data is downsampled
% 2) the rate entry corresponds to the new data rate (as you would expect)
% 3) there is a new entry called orig_rate, which is the original sampling rate
%    
% No windows or detrending is applied, so the fft may get mad 
%
% BTL July 11, 2008
%
% updated on Jan 26, 2012 to save the original mean in a field called
% orig_mean

new_rate = 2 * new_nyquist_freq;

return_struct = orig_struct;
for chan = 1:length(orig_struct)
    Ts = 1/orig_struct(chan).rate;
    orig_mean                = mean(orig_struct(chan).data);
    return_data              = orig_struct(chan).data - orig_mean;
    return_struct(chan).data = downsample_viafftcutoff(return_data,Ts, new_nyquist_freq);
%    return_struct(chan).data = down_sampled_data;
    
    return_struct(chan).original_rate = orig_struct(chan).rate;
    return_struct(chan).rate          = new_rate;
    return_struct(chan).orig_mean     = orig_mean;
end



