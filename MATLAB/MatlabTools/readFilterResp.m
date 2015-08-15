function h = readFilterResp(filename,bank,modules,f)
%% H = READFILTERRESP(FILENAME,BANK,MODULES,F)
% h = readFilterResp(filename,bank,modules,f) generates a frequency response, at frequencies f [Hz], for the filters contained in a foton file. 
% The filename should contain the full path, any number of modules (from 1 to 10) can be input (as a vector) with the result being their product. 
%
% e.g. h = readFilterResp('/opt/rtcds/llo/l1/chans/L1ISIHAM2.txt','HAM2_ISO_X',1,f); 
% OR
% h = readFilterResp('/opt/rtcds/llo/l1/chans/L1ISIHAM2.txt','HAM2_ISO_X',[1 10],f);

pfilt = readFilterFile(filename);

ts = 1/pfilt.RATE.fs;

h = 1;

for ix = 1:length(modules)
    sos = pfilt.(bank)(modules(ix)).soscoef;
    [z,p,k] = sos2zp(sos);

    h = h .* squeeze(freqresp(zpk(z,p,k,ts),2*pi*f));
end
