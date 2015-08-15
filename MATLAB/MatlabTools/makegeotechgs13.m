function gs13Model_f = makegeotechgs13(freq)

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
                                     
gs13.Q = 4.5;%1                          % []
                                     % JSK Guess

                                     % gs13.Q = 4.5;                          % []
%                                        % From makeligogs13
                                     
gs13.poles = [1 0 0];                          % [ ]
gs13.zeros = [1 gs13.w0/gs13.Q gs13.w0^2];     % normalized velocity response     
gs13.freqresp = -tf(gs13.poles,gs13.zeros);     % '-' sign added to match phase response (CR)                           
                            
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
                       * readout.gain ...       % [V/V]
                       * antialiasing.gain ...  % [V/V]
                       * adc.gain;              % [cts/V]

gs13Model_f = squeeze(freqresp(gs13Model.velocity_c,2*pi*freq));