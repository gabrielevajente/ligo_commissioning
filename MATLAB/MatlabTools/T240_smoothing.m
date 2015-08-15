% play with the T240 response


clear
close all
%%
% This is the spec for the T240

spec_k = 2.316e9; % from the manual
spec_gain = 1196.5;

% this is in units of V/(m/s);
response_zpk_mps_spec = spec_gain * zpk([0 0 -108 -161], ...
    [-0.01815 + 0.01799i, -0.01815 - 0.01799i, -173, ...
    -196 + 231i, -196 - 231i, -732 + 1415i,  -732 - 1415i], spec_k) ;


flatten_zeros = [-173, -196 + 231i, -196 - 231i];
flatten_poles = [-108, -161, -2*pi*100*[1+1i, 1-1i]/sqrt(2)];
flatten_gain  = prod(abs(flatten_poles)) / prod(abs(flatten_zeros));
flatten_HF = zpk(flatten_zeros, flatten_poles, flatten_gain);

figure
bode(flatten_HF)

response_zpk_mps_smoothed = minreal(response_zpk_mps_spec * flatten_HF);

disp(' ')
disp('the smoothed resp is :')
disp(response_zpk_mps_smoothed)
disp(' ')

figure
bode(response_zpk_mps_spec, response_zpk_mps_spec * flatten_HF)