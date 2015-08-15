function [out1, out2] = mycheby1(freq,order,ripple)
% [out1, out2] = mycheby1(freq,order,ripple)
%
% mycheby1 creates a chebyshev low pass filter with useful input
% parameters.
%
% If called with two outputs as shown, out1 and out2 are the numerator and
% denominator of the transfer function, otherwise (i.e. just one output) it
% returns a zpk system.
%
% Jeff Kissel, Jan 2013
% (but copied mostly from myellip by Brian Lantz.)

[z,p,k]=cheby1(order,ripple,1,'s');
chebyZ = 2*pi*freq*z;
chebyP = 2*pi*freq*p;
diff=length(chebyP)-length(chebyZ);
gain=(2*pi*freq)^diff;

if nargout==1
	out1=zpk(chebyZ,chebyP, k*gain);
else
	[out1,out2]=zp2tf(chebyZ,chebyP, k*gain);
end