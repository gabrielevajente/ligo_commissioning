function [motion_spec, SRM_horz_target, SRM_vert_target] = HAM_req(freq)
% [motion_spec, SRM_horz_target, SRM_vert_target] = HAM_req(freq);
%
%HAM_req  Returns the ASD of the HAM requirement per the April 2006 review
%  this is the horizontal motion requirement at the suspension point of the
%  triple pendulum, in meters/rtHz
%
% call as 
% [motion_spec] = HAM_req(freq);
% freq is a vector of frequencies, in Hz
% motion_spec is a vector of ASD motion, in m/rtHz, at the respective freq
%
% the spec is
%  freq   ASD
% 1/f below 0.2 Hz
% 0.2 Hz     2e-7
% 0.6 Hz   6.67e-10
% 4e-10 at 1 Hz
% 1/f from 0.6 to 30
% flat above 30 Hz at 1.33e-11
% 
% BTL 4/19/07
%   
%    UPDATED April 20, 2010 by BTL
% Now also includes a 'SRM target' for the 
% signal recycling mirrors in HAMs 4 & 5 (10 & 11)
% based on T080192.
% The updated specs can be retrieved as additional output arguments, as
% [motion_spec, SRM_horizontal_target, SRM_vertical_target] = HAM_req(freq);
% the new targets are the same at and below 5 Hz, 
% at 10 Hz
% the vertical is XXX m/rtHz, and 
% the horizontal is XXX m/rtHz. 
% at 22 Hz the targets go to 1.33e-11 m/rtHz, and stay there to high freq.
%
req_freq     = [  0.002,    0.2,      0.6,      30,       1000,];
req_data     = [100*2e-7,   2e-7,  6.67e-10, 1.33e-11,  1.33e-11 ];
logreqnoise  = interp1(log10(req_freq),log10(req_data),log10(freq));
motion_spec  = 10.^logreqnoise;

SRM_vert_req_freq     = [  0.002,    0.2,      0.6,     5,     10,   20,      30,       1000,];
SRM_vert_req_data     = [100*2e-7,   2e-7,  6.67e-10, 8e-11, 4e-12, 4e-12, 1.33e-11,  1.33e-11 ];
SRM_vert_logreqnoise  = interp1(log10(SRM_vert_req_freq),...
    log10(SRM_vert_req_data),log10(freq));
SRM_vert_target  = 10.^SRM_vert_logreqnoise;

SRM_horz_req_freq     = [  0.002,    0.2,      0.6,     5,     10,    20,      30,    1000,];
SRM_horz_req_data     = [100*2e-7,   2e-7,  6.67e-10, 8e-11, 1.4e-12, 6e-12, 1.33e-11,  1.33e-11 ];
SRM_horz_logreqnoise  = interp1(log10(SRM_horz_req_freq),...
    log10(SRM_horz_req_data),log10(freq));
SRM_horz_target  = 10.^SRM_horz_logreqnoise;



