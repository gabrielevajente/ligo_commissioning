function gs13Model_f = makeligogs13(freq)

genConst = 2231;        % Generator Constant (V/(m/s))
                        % Mean of first batch of 100 (+/- 0.5%)
w0 = 2*pi*1;            % Resonant Frequency (rads/s)

Rc = 9083;              % Coil Resistance
                        % Mean of first batch of 100 (+/- 0.6%)
Rd = 845000;             % Damping resistance
                        % Should be 845 kOhms, according to Radd1
                        % on D050358-01-C (LIGO-D050358-v1)
        
b0 = .1;               % Open Circuit Damping
                        % Mean of first batch of 100 (+/- 2.5%)
bc = 1.1*Rc/(Rc+Rd);    % Damping from external resistor

bt = b0 + bc;           % total damping

Q   = 1/(2*bt);

gs13Num = (Rd/(Rc+Rd)) * genConst * [1 0 0];
gs13Den = [1 w0/Q w0^2];

preampGain = 40.2; % volts out/ volts in, low gain channel
                   % readout gain comes from (953+49.9)/49.9,
                   % (R2 + R1)/R1, in D050358 GS-13 Pre-Amp
                            
readout_gain = 1; % V / ct
                  % As reported at the top of the time series ascii file

GS13_model_velocity = tf(gs13Num,gs13Den) * preampGain * readout_gain; % cnts / (meter / sec)
GS13_position_response = GS13_model_velocity * tf([1 0],[1]);

gs13Model_f = squeeze(freqresp(GS13_model_velocity,freq*2*pi));

% figure;
% bode(GS13_model_velocity);
% title('GS13 velocity response in cnts / (m/secs)')
% legend('Manufacter Response * readout gain')
% grid on
% 
% figure;
% bode(GS13_position_response);
% title('GS13 displacement response in cnts / m')
% legend('Velocity Response * tf([1 0], 1)')
% grid on