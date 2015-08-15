function [result,g]= conjug(freq,angle)

z=2*pi*freq*exp(j*angle*pi/180);
result= [-z -conj(z)];
g=abs(result(1))^2;