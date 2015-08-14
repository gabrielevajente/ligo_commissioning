% load data from two periods
gps0 = 1108532186;
gps1 = 1108717926;

d0 = get_data('H1:LSC-DARM_IN1_DQ', 'raw', gps0, 600);
d1 = get_data('H1:LSC-DARM_IN1_DQ', 'raw', gps1, 600);

% make spectrograms
np = 16384;
[S0,F0,T0] = spectrogram(d0.data, hanning(np), np/2, np, 16384);
[S1,F1,T1] = spectrogram(d1.data, hanning(np), np/2, np, 16384);


%% compute BLRMS
gps = 1108717926;
dt = 600;

d = get_data('H1:LSC-DARM_IN1_DQ', 'raw', gps, dt);
fs = d.rate;
d = d.data;

d = decimate(d, 8);
fs = fs/8;

bands = [20, 50; ...
        100, 300];
outfs = 16;
    
nbands = size(bands, 1);

blrms = zeros(dt*outfs, nbands);
for i=1:nbands
    [B,A] = butter(4, bands(i,:)/(fs/2), 'bandpass');
    x = filtfilt(B, A, d);
    x = x.^2;
    [B,A] = butter(4, outfs/(fs/2), 'low');
    x = filtfilt(B,A, x);
    blrms(:,i) = x(1:fs/outfs:end);
end

blrms = blrms(outfs:end-outfs,:);
t = (1:size(blrms,1))/outfs;

%% 
% aux_channels = {'H1:ASC-AS_A_RF36_I_PIT_OUT_DQ', 'H1:ASC-AS_A_RF36_I_YAW_OUT_DQ', ...
%                 'H1:ASC-AS_B_RF36_I_PIT_OUT_DQ', 'H1:ASC-AS_B_RF36_I_YAW_OUT_DQ'};
%aux_channels = {'H1:SUS-SRM_M3_WIT_P_DQ', 'H1:SUS-SRM_M3_WIT_Y_DQ'}

d_aux = get_data(aux_channels, 'raw', gps, dt);
aux = zeros(dt * outfs, numel(d_aux));
for i=1:numel(d_aux)
    [B,A] = butter(4, outfs/d_aux(i).rate, 'low');
    x = filtfilt(B,A, d_aux(i).data);
    aux(:,i) = x(1:d_aux(i).rate/outfs:end);
    aux(:,i) = aux(:,i) - mean(aux(:,i));
    aux(:,i) = aux(:,i) / max(abs(aux(:,i)));
end
aux = aux(outfs:end-outfs,:);

figure
ax(1) = subplot(211);
%plot(t, blrms(:,1) / 3e-18, 'b', t, blrms(:,2) / 1e-22, 'r')
plot(t, blrms(:,2) / 1e-21, 'r')
legend(arrayfun(@(i) sprintf('Band %d - %d Hz', bands(i,1), bands(i,2)), 2, 'UniformOutput', false))
ylim([-0.1, 4])
ylabel('BLRMS [a.u.]')
ax(2) = subplot(212);
plot(t, aux)
legend(strrep(aux_channels, '_', '\_'))
linkaxes(ax, 'x')
ylabel('Signal [a.u.]')
xlabel('Time [s]')

% least square fit
A = aux ./ repmat(max(abs(aux)), [size(aux,1),1]);
B = blrms ./ repmat(max(abs(blrms)), [size(blrms,1),1]);

X = [A, A.^2];
X(:, end+1) = 1;

b = 2;
p0 = zeros(size(X,2),1);
idx = t>0;
p = fminsearch(@(p) mean(abs(B(idx,b) - X(idx,:)*p)), p0, optimset('display', 'iter'));

figure()
plot(t, B(:,b), 'b', t, X*p, 'r')
ylim([0, 0.3])
xlabel('Time [s]')
ylabel('BLRMS [a.u.]')
legend('Data', 'Fit')
grid
