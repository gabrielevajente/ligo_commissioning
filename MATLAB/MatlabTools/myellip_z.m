function [out1,out2]=myellip_z(freq,order,ripple,stopDB,zQ)%MYELLIP_Z creates a derated low-pass elliptic filter with useful input parameters%%  use myellip_z2%% sys=myellip_z(freq,order,ripple,stopDB,zQ)%   except the zeros are lower Q%   returns the transfer function for an elliptical filter%   with unity gain, knee at 'freq', with 'order' poles%   ripple DBs of ripple in the passband, and a%   stopband which is stopDB DBs down. %   Brian Lantz, see also myhpellip%  only runs with 2nd or 3rd order elliptics%% the zeros are computed as% Zfreq*[1 + zQ*i, 1 - zQ*i]/sqrt(1+zQ^2)% if called with two output args, returns numerator and denominator of tf, as% [num,den]=myellip(freq,order,ripple,stopDB,zQ)% zQ=10 works pretty well%% $Id: myellip_z.m 7211 2013-05-29 14:30:07Z jeffrey.kissel@LIGO.ORG $% modified BTL Jan 5,2000 to return a system, not a numerator/ denominatorif ( (order<2) | (order>3) )	sprintf('ellip_z only works for order 2 and 3')	if nargout==1		out1=myellip(freq,order,ripple,stopDB);	else		[out1,out2]=myellip(freq,order,ripple,stopDB);	end	returnelse[ellZ, ellP, K]=ellip(order,ripple,stopDB,1,'s');Zsc=-abs(2*pi*freq*ellZ(1));    % freq of the zeroellZsc=Zsc*[1 + zQ*i, 1 - zQ*i]/sqrt(1+zQ^2);ellPsc=2*pi*freq*ellP;diff=length(ellP)-length(ellZ);gain=(2*pi*freq)^diff;if nargout==1	out1=zpk(ellZsc,ellPsc, K*gain);else	[out1,out2]=zp2tf(ellZsc,ellPsc, K*gain);endend