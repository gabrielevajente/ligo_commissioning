function [T240_filter, L4C_filter] = blend_T240_L4C_111012(plot_flag)
%blend_T240_L4C_111012  makes a filter to combine the L4C and the T240;
% [T240_filter, L4C_filter] = blend_T240_L4C_111012;
% T240_filter and L4C_filter are zpk, continuous time filters
% designed to combine (blend) the T240 and the L4C.
% 
% This is only PART of the final complementary filter.
% the complementary filters are 
% CPS_filter
% Inertial_filter * T240_filter
% Inertial_filter * L4C_filter
%
% this complementary filter pair is designed to give good performance 
% for the specified noise of the T240
%
% to make all the design plots
% call as:
%   [T240_filter, L4C_filter] = blend_T240_L4C_111012(plot_flag) 
% where plot_flag is true to make plots or false to hide the plots
%  eg [a,b] = blend_T240_L4C_111012(true)
% (the plots are hidden by default)
%
% Brian Lantz, Oct 12, 2011.

if ~exist('plot_flag','var')
    plot_flag = false;
end

if ~islogical(plot_flag)
    plot_flag = true;
    disp('Warning, the plot_flag should be a logical, ie true')
end

% blend the L4C and the T240

%clear
%close all

purple    = [0.5    0  0.8];
lt_purple = [.65 0 1];
green     = [0 0.7 0];
lt_green  = [.2 1 .2];


%disp([' running ',mfilename, ' on ',date])

%%

freq = logspace(-2,3, 1000)';
w    = 2*pi*freq;

L4C_noise       = SEI_sensor_noise('L4C',     freq);
T240_noise_meas = SEI_sensor_noise('T240meas',freq);
T240_noise_spec = SEI_sensor_noise('T240spec',freq);

%%
if plot_flag == true

    figure
    ll=loglog(...
        freq, L4C_noise,...
        freq, T240_noise_meas,...
        freq, T240_noise_spec);
    set(ll,'LineWidth',2)
    set(ll(1),'Color',green);
    set(ll(2),'Color',purple);
    set(ll(3),'Color',lt_purple);
    title('Instrument Noise Floor')
    xlabel('freq (Hz)')
    ylabel('inst noise ASD (m/\surd(Hz))')
    grid on
    axis([.01 200 1e-13 1e-7])
    FillPage('w')
    IDfig
    legend('L-4C','T240 measured','T240 spec')
end

%% make up a blend
% first, make some targets.
L4C_max1 = T240_noise_meas ./ L4C_noise;  % make the hardest one
L4C_max2 = T240_noise_spec ./ L4C_noise;  % make the hardest one

T240_max1 = L4C_noise ./ T240_noise_meas; % make the hardest one
T240_max2 = L4C_noise ./ T240_noise_spec; % make the hardest one

%% 

if 0 % don't plot this here, anymore

figure
ll = loglog(...
    freq, L4C_max1,'g',...
    freq, L4C_max2,'g',...
    freq, T240_max1,'b',...
    freq, T240_max2,'b');
grid on
set(ll,'LineWidth',2);
set(ll(1),'Color',green);
set(ll(2),'Color',lt_green);

set(ll(3),'Color',purple);
set(ll(4),'Color',lt_purple);

axis([1e-2 1e2 1e-3 10])
xlabel('freq (Hz)')
ylabel('max filter mag')

legend('L4C limit w/ meas T240','L4C limit w/ T240 spec',...
    'T240 limit w/ meas T240', 'T240 limit w/ T240 spec','Location','SouthEast')
FillPage('w')
IDfig

end
%% try some filters

f0 = 2;

L4C_proto  = zpk(-2*pi*[0 0 0], -2*pi*[f0/1.14, (f0/4)*[1+1i, 1-1i]/sqrt(2)], 1); % big Highpass
%L4C_proto  = zpk(-2*pi*[0], -2*pi*[f0], 1); % gentle Highpass

T240_proto = zpk([],-2*pi*[1.14*f0], 2*pi*1.14*f0); % gentle lowpass

L4C_temp  =  L4C_proto / (L4C_proto + T240_proto);
T240_temp = T240_proto / (L4C_proto + T240_proto);

L4C_filter  = minreal(L4C_temp);
T240_filter = minreal(T240_temp);

L4C_filter_FR  = squeeze(freqresp( L4C_filter,w));
T240_filter_FR = squeeze(freqresp(T240_filter,w));

%%
if plot_flag == true
    figure
    bode(L4C_proto, T240_proto, L4C_filter, T240_filter)
end

%% 
if plot_flag == true
    figure
    ll = loglog(...
        freq, L4C_max1,'g--',...
        freq, L4C_max2,'g--',...
        freq, T240_max1,'b--',...
        freq, T240_max2,'b--',...
        freq, abs(L4C_filter_FR), 'g',...
        freq, abs(T240_filter_FR),'b');
    grid on
    set(ll,'LineWidth',2);
    set(ll(1),'Color',green);
    set(ll(2),'Color',lt_green);
    
    set(ll(3),'Color',purple);
    set(ll(4),'Color',lt_purple);
    
    set(ll(5),'Color',green);
    set(ll(6),'Color',purple);
    
    
    axis([1e-2 1e2 1e-3 10])
    xlabel('freq (Hz)')
    ylabel('max filter mag')
    
    legend('L4C limit w/ meas T240','L4C limit w/ T240 spec',...
        'T240 limit w/ meas T240', 'T240 limit w/ T240 spec',...
        'L4C filter','T240 filter', ...
        'Location','SouthEast')
    FillPage('w')
    IDfig
end

%%

st1_inert_noise_meas = sqrt((L4C_noise .* abs(L4C_filter_FR)).^2 + (T240_noise_meas .* abs(T240_filter_FR)).^2);
st1_inert_noise_spec = sqrt((L4C_noise .* abs(L4C_filter_FR)).^2 + (T240_noise_spec .* abs(T240_filter_FR)).^2);

if plot_flag == true
    figure
    ll=loglog(...
        freq, L4C_noise,...
        freq, T240_noise_meas,...
        freq, T240_noise_spec,...
        freq, st1_inert_noise_meas,'m',...
        freq, st1_inert_noise_spec,'m');
    set(ll,'LineWidth',2)
    set(ll(1),'Color',green);
    set(ll(2),'Color',purple);
    set(ll(3),'Color',lt_purple);
    set(ll(3),'Color',lt_purple);
    
    title('Instrument Noise Floor')
    xlabel('freq (Hz)')
    ylabel('inst noise ASD (m/\surd(Hz))')
    grid on
    axis([.01 200 1e-13 1e-7])
    FillPage('w')
    IDfig
    legend('L-4C','T240 measured','T240 spec')
    
end
