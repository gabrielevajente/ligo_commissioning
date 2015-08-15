function sts2Model_f = maketeststandsts2(freq)

%%
antialiasing.gain = +1;              % [V/V]
                                     % AdL AA and AI Filter D070081-v2
                                     % We ignore the frequency response of
                                     % of the 3rd order 10 kHz Butterworth

adc.gain = 65536 / 40;               % [cts/V]
                                     % General Standards ADC
                                     
%%

sts2.gain = 1500;                    % [V / (m/s)]
                                     % Main coil generator constant
                                     % As stated in STS-2 Manual

sts2.w0 = 2*pi*0.0083;               % [rad/s]
                                     % Resonant frequency
                                     % As stated in STS-2 Manual

sts2.Q = 1/sqrt(2);                  % []
                                     % As stated in STS-2 Manual

sts2.poles = [1 0 0];                       % [ ]
sts2.zeros = [1 sts2.w0/sts2.Q sts2.w0^2];  % normalized velocity response
sts2.freqresp = tf(sts2.poles,sts2.zeros);

readout.gain = 10;%98.8;                 % [V/V]
                                     % Old-style LSU readout box

% [cts/(m/s)]
sts2Model.velocity_c = sts2.freqresp ...        % [ ]
                       * sts2.gain ...          % [V/(m/s)]
                       * readout.gain ...       % [V/V]
                       * antialiasing.gain ...  % [V/V]
                       * adc.gain;              % [cts/V]
                   
sts2Model_f = squeeze(freqresp(sts2Model.velocity_c,2*pi*freq));                   