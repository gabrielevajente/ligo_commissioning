function [z,p,k,name] = readFilterzpk(filename,bank,module)
%% [z,p,k] = readFilterzpk(filename,bank,module)
% i.e. [z,p,k] = readFilterzpk('/opt/rtcds/llo/l1/chans/L1ISIHAM2.txt','HAM2_ISO_X',1);
% Can take more than one module as the input, argument should be a space
% delimited vector, i.e. readFilterzpk('/opt/rtcds/llo/l1/chans/L1ISIHAM2.txt','HAM2_ISO_X',[1 3 5]);
% which will return the product of the 1st, 3rd, and 5th filter module

if nargout < 4
    name = [];
end

pfilt = readFilterFile(filename);

z = [];
p = [];
k = 1;

for ix = 1:length(module)
    sos = pfilt.(bank)(module(ix)).soscoef;
    [zd,pd,kd] = sos2zp(sos);
    
    ts = 1/pfilt.(bank)(module(ix)).fs;
    
    sysc = d2c(zpk(zd,pd,kd,ts),'tustin');
    [zz,pp,kk] = zpkdata(sysc,'v');

    z = [z; zz];
    p = [p; pp];
    k = k*kk;
    name = pfilt.(bank)(module(ix)).name;
end