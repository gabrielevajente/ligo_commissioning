% param = comb_TF_exc(param)
%   generate an excitation and return the modified param struct for later
%   use with comb_TF_get
%
% param struct must contain at least
%   exc_chan - excitation channel
%   exc_rate - excitation channel data rate
%   exc_data - excitation signal (single repetition)
%   num_skip - number of repetitions to ramp on and off excitation
%   num_reps - number of repetitions to of constant excitation
%
%
%  Modified 8/6/10 to include actuator saturation field  RKM
%
%


function param = comb_TF_exc(param)

  % run the excitation (in the foreground)
  [exc_start, run_time] = awgstream(param.exc_chan, param.exc_rate, 0, ...
    param.exc_data(:), param.num_reps, param.num_skip, false);

  % add some info to the param struct
  num_points = numel(param.exc_data);
  param.exc_period = num_points / param.exc_rate;
  param.exc_start = exc_start;
  param.exc_end = exc_start + run_time;
  return