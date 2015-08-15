function l4cModel_f = makesercell4c(freq)


%%
antialiasing.gain = +1;              % [V/V]
                                     % AdL AA and AI Filter D070081-v2
                                     % We ignore the frequency response of
                                     % of the 3rd order 10 kHz Butterworth

adc.gain = 65536 / 40;               % [cts/V]
                                     % General Standards ADC
%%                                     
 
l4c.gain = 275;                      % [V / (m/s)]
                                     % Main coil generator constant
                      
l4c.w0 = 2*pi*1;                     % [rad/s]
                                     % Resonant frequency
                                     % Adjusted to be so after
                                     % installation of LIGO flexures
                                     % during Post-Mod. huddle test.
                                     % Question from MV: are these old
                                     % comments from GS-13 Modding?
                      
l4c.Q = 2;                           % [ ]
                                     % Standard BTL "guess" with LIGO preamp
                                     % but confirmed over many many many
                                     % measurements                         

l4c.poles = [1 0 0];                          % [ ]
l4c.zeros = [1 l4c.w0/l4c.Q l4c.w0^2];        % normalized velocity response     
l4c.freqresp = tf(l4c.poles,l4c.zeros);                                

preamp.gain = 44;  %FIX ME!!! Via D1001575
                            
readout.gain  = 2;                   % [V/V]
readout.poles = -2*pi*[50 2e3 2.2e3];% GS-13 Interface Card D0902742-v1
readout.zeros = -2*pi*10;            % (Differential Out / Differential In 
                                     % = No factor of 2)
                                     
readout.norm  = prod(readout.poles)/prod(readout.zeros);                                     
readout.freqresp = zpk(readout.zeros,readout.poles,readout.norm);                                     
                                     
l4cModel.velocity_c = l4c.freqresp ...        % [ ]
                       * readout.freqresp ...   % [ ]
                       * l4c.gain ...          % [V/(m/s)]
                       * preamp.gain ...        % [V/V]
                       * readout.gain ...       % [V/V]
                       * antialiasing.gain ...  % [V/V]
                       * adc.gain;              % [cts/V]

l4cModel_f = squeeze(freqresp(l4cModel.velocity_c,freq*2*pi));