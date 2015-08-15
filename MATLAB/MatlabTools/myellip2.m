function [out1,out2]=myellip(freq,order,ripple,stopDB)%myellip creates a low-pass elliptic filter with useful input parameters% sys=myellip(freq,order,ripple,stopDB)%   returns the transfer function for an elliptical filter%   with unity gain, knee at 'freq', with 'order' poles%   ripple DBs of ripple in the passband, and a%   stopband which is stopDB DBs down. %   Brian Lantz, see also myhpellip%% if called with two output args, returns numerator and denominator of tf, as% [num,den]=myellip(freq,order,ripple,stopDB)%% $Id: myellip2.m 7211 2013-05-29 14:30:07Z jeffrey.kissel@LIGO.ORG $% modified BTL Jan 5,2000 to return a system, not a numerator/ denominator[ellZ, ellP, K]=ellip(order,ripple,stopDB,1,'s');ellZsc=2*pi*freq*ellZ;ellPsc=2*pi*freq*ellP;diff=length(ellP)-length(ellZ);gain=(2*pi*freq)^diff;if nargout==1	out1=zpk(ellZsc,ellPsc, K*gain);else	[out1,out2]=zp2tf(ellZsc,ellPsc, K*gain);end