function [sys]=notch(f0,Q,atten);
%NOTCH builds a bogus notch filter
%[sys]=notch(f0,Q,attenuation);
%f0 is the center freq, Q and atten control the width and depth
%
% see notch2 for the old version
%
% Brian Lantz Jan 23, 2003

top=1/Q;
bottom=atten/Q;

nhf=[1/(2*pi*f0)^2 2*top/(2*pi*f0) 1]; 
dhf=[1/(2*pi*f0)^2 2*bottom/(2*pi*f0) 1];
num=nhf;
den=dhf;
sys = tf(num,den);
