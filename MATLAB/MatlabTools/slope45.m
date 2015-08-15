function Z = slope45(low,high,order,Gain);
 
X = (2*order-1)/((log(high)/log(low))-1);
Y = exp(log(low)/X);

if Gain < 0
    PP = 2*(0:order-1);
    ZZ = PP + 1;
else
    ZZ = 2*(0:order-1);
    PP = ZZ + 1;  
end
ZZ = Y.^(ZZ+X);
PP = Y.^(PP+X);
Z = zpk(-2*pi*ZZ,-2*pi*PP,1);