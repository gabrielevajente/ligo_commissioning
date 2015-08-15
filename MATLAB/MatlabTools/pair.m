function complexPair = pair(amp,phase)
% makes a complex pair for use with making poles and zeros
% amp is the amplitude of the pair, in Hz
% phase is the phase of the pair in degrees (between 0 and 90)
%
% SVN $Id: pair.m 7264 2013-06-06 23:39:05Z jeffrey.kissel@LIGO.ORG $

if phase > 90 || phase <0
    warning('Phase is not between 0 and 90 degrees.')
end
complexPair = amp.* exp([i -i]*(pi/180)*phase);
