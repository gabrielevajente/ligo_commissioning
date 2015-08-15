% result = comb_TF_get(param, isVerbose)
%   measure transfer functions from
%   the excitation to a collection of response channels
%   (see also comb_TF_exc)
%
% param struct must contain at least
%   exc_start - excitation start GPS
%   exc_period - length of excitation signal (seconds)
%   num_reps - number of repetitions to use for TF
%   num_skip - number of repetitions to skip before measuring TF
%   readback_chan - excitation readback channel
%   resp_chan_list - list of response channels (N x 1 cell array)
%   resp_range - saturation level for each resp channel (N x 1 vector)
%   data_rate - readback and resp channel data rate
%
% result struct will contain
%   param - the argument struct
%   exc_start - excitation start time
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

function result = comb_TF_get(param, isVerbose)


  % load data and compute results
  result = get_long_comb_TF_TS(param, isVerbose);

  % add some info to the result struct
  %result.exc_start = param.exc_start;
  %result.param = param;

  result.weight = ones(size(result.num_sat));
  
end