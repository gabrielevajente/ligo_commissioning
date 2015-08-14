%% Read data
gps = 1109289616+8*3600 - 300;%1109411450;
dt = 7200; %3600;
d = get_data('H1:CAL-DELTAL_EXTERNAL_DQ', 'raw', gps, dt);
fs = d.rate;
d0 = d.data;
t0 = (1:length(d0))/fs;


%% Compute BLRMS

% decimate down the signal
d0 = decimate(d0, 8);
fs = fs/8;

bands = [290, 310; ...
         780, 920]; % frequency band
outfs = 4;          % output sampling frequency
    
% compute the BLRMS
nbands = size(bands, 1);
blrms = zeros(dt*outfs, nbands);
for i=1:nbands
    % band pass
    [B,A] = butter(6, bands(i,:)/(fs/2), 'bandpass');
    x = filtfilt(B, A, d0);
    % square
    x = x.^2;
    % low pass
    [B,A] = butter(4, outfs/(fs/2), 'low');
    x = filtfilt(B,A, x);
    % decimate
    blrms(:,i) = x(1:fs/outfs:end);
end
% get rid of the initial and final transients
blrms = blrms(2*outfs:end-2*outfs,:);
t = (1:size(blrms,1))/outfs;

% fit exponential decay plus background
fun = @(p,t) max(p(1) + p(2)*t, p(3));
p0 = [-27 -0.01, -38];
p = lsqcurvefit(fun, p0, t', log(abs(blrms(:,1))), [], [], optimset('display', 'iter'));

% fit exponential decay plus background
fun = @(p,t) max(p(1) + p(2)*t, p(3));
p0 = [-27 -0.01, -38];
p = lsqcurvefit(fun, p0, t', log(abs(blrms(:,2))), [], [], optimset('display', 'iter'));
