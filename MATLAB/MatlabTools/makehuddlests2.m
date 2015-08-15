function stsModel_f = makehuddlests2(freq)

genConst = 2 * 750; % V/(m/s) - Standard STS-2 generator constant

w0 = 2 * pi * 0.0083; %rad/s - 8.3 mHz Natural Frequency

readoutGain = 98.8; % V/V - Blue LSU STS-2 Readout Chassis 

switchGain = 10; % V/V - Switchable gain stage (x1, x10, or x100)

sts2Num = genConst * [0 0];

sts2Den = w0 * [1+i 1-i]/sqrt(2); % Critically damped pendula

STS2_model_velocity = zpk(sts2Num,sts2Den,1);

stsModel_f = squeeze(freqresp(STS2_model_velocity,freq*2*pi));