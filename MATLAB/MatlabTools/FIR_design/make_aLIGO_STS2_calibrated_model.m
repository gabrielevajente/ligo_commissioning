% make a model of the STS2 readout after the input filter 
clear; close all

STS2_calibrated_velocity_response = 1e9 * zpk([0 0],-2*pi*0.00833*[1+1i, 1-1i]/sqrt(2),1);
% instrument response in V/(m/s), or V*s/m if you think that way.
figure
bode(STS2_calibrated_velocity_response)
title('Calibrated velocity resp of the STS-2, in counts/(m/s)')

%%
STS2_calibrated_position_response = zpk('s') * STS2_calibrated_velocity_response;
% instrument response in V/m
figure
bode(STS2_calibrated_position_response)
title('displacement resp of the base STS-2, in V/m')

%%


STS2_note = ['Response of the aLIGO floor and witness STS2 sensor, AFTER CALIBRATION, in counts/meter, generated by ',mfilename,' on ',date,' BTL'];
% save aLIGO_calibrated_STS2_sensor_20120112 STS2_note STS2_calibrated_position_response 