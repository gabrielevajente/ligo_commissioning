function t240Model_f = maketrillium240(freq)

%%
antialiasing.gain = +1;              % [V/V]


adc.gain = 65536 / 40;               % [cts/V]
                                     % General Standards ADC
                                     
                                     
%% Trillium 240s

t240.gain = 1196.5;                    % [V / (m/s)]
                                     % T240 Manufacturer's Document
                                     % 1196.5 (V*s/m)
              
                      
t240.w0 = 2*pi*0.004;               % T240 Manufacturer's Document
                                    % [rad/s]
                                     
                                     
t240.Q = 1;                          % 

%t240.zeros = -2*pi*[0 0 -108 -161];
%t240.poles = -2*pi*[-0.01815+0.01799i -0.01815-0.01799i -173 -196+231i -196-231i -732+1415i -732-1415i ];                                    
%[-0.01815+0.01799i -173 -196+231i -732+1415i ];
% normalized velocity response     
t240.poles = [1 0 0];                          % [ ]
t240.zeros = [1 t240.w0/t240.Q t240.w0^2];     % normalized velocity response     

t240.freqresp = tf(t240.poles,t240.zeros);                                
      
readout.gain  = 96;%13;                % [V/V]
readout.poles = -2*pi*[];           % T240 Interface Card D1000749
readout.zeros = -2*pi*[];            % (Differential Out / Differential In 
                                     % = No factor of 2)    
                                                    
readout.norm  = prod(readout.poles)/prod(readout.zeros);                                     
readout.freqresp = zpk(readout.zeros,readout.poles,readout.norm);

% [cts/(m/s)]
t240Model.velocity_c = t240.freqresp ...        % [ ]
                       * readout.freqresp ...   % [ ]
                       * t240.gain ...          % [V/(m/s)]
                       * readout.gain ...       % [V/V]
                       * antialiasing.gain ...  % [V/V]
                       * adc.gain;              % [cts/V]

t240Model_f = squeeze(freqresp(t240Model.velocity_c,2*pi*freq));