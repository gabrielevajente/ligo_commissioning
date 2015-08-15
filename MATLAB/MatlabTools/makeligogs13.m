function gs13Model_f = makeligogs13(freq)

%%
antialiasing.gain = +1;              % [V/V]
                                     % AdL AA and AI Filter D070081-v2
                                     % We ignore the frequency response of
                                     % of the 3rd order 10 kHz Butterworth

adc.gain = 65536 / 40;               % [cts/V]
                                     % General Standards ADC

%% GS-13s
gs13.gain = 2200;                    % [V / (m/s)]
                                     % Main coil generator constant
                                     % Mean for all aLIGO GS-13s is
                                     % 2212.6 +/- 18.2
                      
gs13.w0 = 2*pi*1;                    % [rad/s]
                                     % Resonant frequency
                                     % Adjusted to be so after
                                     % installation of LIGO flexures
                                     % during Post-Mod. huddle test.
                      
gs13.Q = 4.5;                        % [ ]
                                     % Standard BTL "guess" with LIGO preamp
                                     % but confirmed over many many many
                                     % measurments

gs13.poles = [1 0 0 0];                          % [ ]
gs13.zeros = [1 gs13.w0/gs13.Q gs13.w0^2];     % normalized velocity response     
gs13.freqresp = tf(gs13.poles,gs13.zeros);                                

preamp.gain  = 2*20.0982;            % [V/V]
                                     % readout gain comes from (R2 + R1)/R1, 
                                     % in D050358-v1 GS-13 Pre-Amp
                                     % (The 2 comes from differential driver).
                            
readout.gain  = 2;                   % [V/V]
readout.poles = -2*pi*[50 2e3 2.2e3];% GS-13 Interface Card D0902742-v1
readout.zeros = -2*pi*10;            % (Differential Out / Differential In 
                                     % = No factor of 2)
                                     
readout.norm  = prod(readout.poles)/prod(readout.zeros);                                     
readout.freqresp = zpk(readout.zeros,readout.poles,readout.norm);

% [cts/(m/s)]
gs13Model.velocity_c = gs13.freqresp ...        % [ ]
                       * readout.freqresp ...   % [ ]
                       * gs13.gain ...          % [V/(m/s)]
                       * preamp.gain ...        % [V/V]
                       * readout.gain ...       % [V/V]
                       * antialiasing.gain ...  % [V/V]
                       * adc.gain;              % [cts/V]

gs13Model_f = squeeze(freqresp(gs13Model.velocity_c,2*pi*freq));