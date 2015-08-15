%temporary l4c model
%in velocity units!!
function [respout, L4Cmodel] = l4cmodel(f,direction)
 
if nargin == 1
    direction = 'V';
else
    direction = upper(direction);
end


if strmatch('V',direction)
    cornerfreq = 0.95;
    angler = 75.5;
elseif  strmatch('H',direction)
    cornerfreq = 1.25;
    angler = 75.5;
else
    disp('Unknown L4C option')
    keyboard
end
L4Cmodel =  zpk([0 0],-2*pi*cornerfreq*exp(i*[1 -1]*(pi*angler/180)),1);        %goes to 1 for f >> 1Hz
L4Cmodel = 2.7*L4Cmodel/abs(freqresp(L4Cmodel,2*pi*10));   %now in Volts/centimeter/second

respout = squeeze(freqresp(L4Cmodel,2*pi*f));

%model from corwin
%if 1 == 0
%sens = 276.38/100;  %cm/sec
%
%i = sqrt(-1);
%wn = 2*pi*1; % 1 Hz geophone
%zz = .3;  %I made this up
%l4c_sys = tf([1 0 0 0],conv([1 2*zz*wn wn^2],[1 700])); % add a pole at 700 Hz for the inductor roll off
%l4c_sys = tf([1 0 0],conv([1 2*zz*wn wn^2],[1])); % add a pole at 700 Hz
%for the inductor roll off 
%freq = logspace(-1,1,1000);w = 2*pi*freq;
%l4c_sys_jw = squeeze(freqresp(l4c_sys,w));
%f_comp = 5; %Hz
%index = max(find(freq<f_comp));  % find the freq at f_comp
%gain_L4C =  (sens  )/abs(l4c_sys_jw(index));

%sys = l4c_sys*gain_L4C;

%bode(L4Cmodel/sys)
%end