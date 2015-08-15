function [motion_spec, diff_spec, old_spec, stage1_motion_target] = BSC_req(freq)
%BSC_req  Returns the ASD of the BSC requirement per the Sept 2009 review.
%  
%  WARNING: as of Nov 2009, the new spec has not been approved 
%       above 5 Hz!
%
%  matches HAM below 0.2 Hz
%  relaxes the 1999 spec at 10 Hz
%  has a differential curve for freq's below 0.4 Hz.
%  this is the horizontal motion requirement 
% at the stage 2 optical table in meters/rtHz
%
% call as 
% [motion_spec, diff_spec] = BSC_req(freq);
% freq is a vector of frequencies, in Hz
% motion_spec and diff_spec are vectors of ASD motion, in m/rtHz, at the respective freq
% if called with one output:
% [motion_spec] = BSC_req(freq);
% then it just returns the absolute motion spec.
%
%
% the spec is
%   freq           ASD
% .010 to 0.2 Hz   1/f
%  0.2 Hz         2e-7
%   1 Hz         1e-11
%   5 Hz         8e-13
%  10 Hz         2e-12
%  15 Hz         2e-13
%  40 Hz           3e-14
%  flat above 40 Hz at 3e-14 (typically we should be well below this)
%
%
%   original curve in E990303-03 was
%   freq (Hz)    motion ASD (m/rtHz)
%  0.1 - 0.2     2e-7
%   .2 - 1        power law, straight line loglog plot
%    1 Hz        1e-11 
%    10 Hz       2e-13
%    30 Hz       3e-14
% above 30 Hz    flat at 3e-14 (typically, we should be well below this)
% this gives the following interesting points
%   .4 Hz    2.8098e-9, 1.5 * 2.8 = 4.2
%    5 Hz    6.4e-13
%
% this can also be called with an optional 
% third output argument, old_spec, which will return the original specs.
% e.g.
%
% [motion_spec, diff_spec, old_spec] = BSC_req(freq);
%
% BTL Sept 23, 2009
%
%
% on March 19, 2010, BTL added a suggested stage 1 electronics spec.
% which is 2X better at low freq, at 5 x worse at 1 Hz.
% and matching the L4C noise at 50 Hz
% this is returned as the optional 4th argument (this is getting silly...)
%
% Then BTL changed this to a cut at a stage 1 motion target , March 2011
% 
% [motion_spec, diff_spec, old_spec, stage1_motion_target] = BSC_req(freq);

req_freq     = [0.001,   0.01,  0.2,   1,     5     10,    15,     40,    1000];
req_data     = [10*4e-6, 4e-6, 2e-7, 1e-11, 6e-13, 2e-12, 2e-13,  3e-14,  3e-14 ];

st1_data     = [2e-6, 1e-7, 5e-11, 3e-12, 1e-11, 1e-12, 15e-14,  15e-14 ];

logreqnoise  = interp1(log10(req_freq),log10(req_data),log10(freq));
motion_spec  = 10.^logreqnoise;

% differential spec
diff_freq    = [ 0.01      0.2,   0.4];
diff_data    = [20*3e-7,   3e-7,  4.2e-9];

logdiffnoise = interp1(log10(diff_freq),log10(diff_data),log10(freq));
diff_spec  = 10.^logdiffnoise;

% and the original E990303-03 curve
old_req_freq     = [0.1,  0.2,    1,    30,    1000,];
old_req_data     = [2e-7, 2e-7, 1e-11  3e-14,  3e-14 ];

logoldreqnoise  = interp1(log10(old_req_freq),log10(old_req_data),log10(freq));
old_spec  = 10.^logoldreqnoise;

% and the stage 1 electronics spec
%req_freq     = [0.01,  0.2,   1,     5     10,    15,     50,    1000,];
%req_data     = [4e-6, 2e-7, 1e-11, 6e-13, 2e-12, 2e-13,  3e-14,  3e-14 ];

% the 100 Hz data is from SEI_sensor_noise.m and the 1000 Hz data is 1/f lower 
stg1_freq     = [0.01,  0.2,   .7,   10,      100,    1000];
stg1_data     = [4e-6, 2e-7, 1e-10, 1e-10,   1e-11,  1e-11];  
% 1 hz from HAM exp (1-2 e-10) and ETF exp (.5 -1 e-10)

logst1noise = interp1(log10(stg1_freq),log10(stg1_data),log10(freq));
stage1_motion_target  = 10.^logst1noise;




