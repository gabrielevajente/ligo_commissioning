function discreteNotch = discretenotch_080327(centerFrequency, depth, width, sampleTime)
% DISCRETENOTCH_080327 creates a discrete time notch filter
%
% discreteNotch = discretenotch_080327(centerFrequency, depth, width, sampleTime)
% 
% DISCRETENOTCH_080327(centerFrequency, depth, width, sampleTime) creates a
% discrete time notch filter with a given center frequency, depth, and with
% for a period of sampleTime.
%
% $Id: discretenotch_080327.m 125 2008-07-31 15:49:03Z seismic $

continuousNotch = notch_110403_local(centerFrequency, depth, width);
discreteNotch   = zpk(c2d(continuousNotch,sampleTime,'matched'));


function notch_tf=notch_110403_local(notch_freq,depth,lamda)
% copy of notch_110403, creates a continous notch filter.

w=notch_freq*2*pi;
notch_tf=tf([1 w*lamda*2 w^2],[1 w*lamda*depth*2 w^2]);
