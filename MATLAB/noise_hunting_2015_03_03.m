%% Read data
gps = 1109411450;
dt = 3600;
d = get_data('H1:CAL-DELTAL_EXTERNAL_DQ', 'raw', gps, dt);
fs = d.rate;
d0 = d.data;
t0 = (1:length(d0))/fs;


%% Compute BLRMS

% decimate down the signal
d0 = decimate(d0, 8);
fs = fs/8;

% here we notch out some lines
fnotch = [120, 180];
qpole = [50, 100];
qzero = [100000, 100000];
for i=1:numel(fnotch)
    num = [1, 2*pi*fnotch(i)/qzero(i), (2*pi*fnotch(i))^2];
    den = [1, 2*pi*fnotch(i)/qpole(i), (2*pi*fnotch(i))^2];
    [B,A] = bilinear(num, den, fs, fnotch(i));
    d0 = filtfilt(B,A, d0);
end


bands = [100, 200]; % frequency band
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

%% Read auxiliary channels 

% aux_channels = {'H1:SUS-ETMX_L3_OPLEV_PIT_OUT_DQ', 'H1:SUS-ETMX_L3_OPLEV_YAW_OUT_DQ', ...
%                 'H1:SUS-ETMY_L3_OPLEV_PIT_OUT_DQ', 'H1:SUS-ETMY_L3_OPLEV_YAW_OUT_DQ', ...
%                 'H1:SUS-ITMX_L3_OPLEV_PIT_OUT_DQ', 'H1:SUS-ITMX_L3_OPLEV_YAW_OUT_DQ', ...
%                 'H1:SUS-ITMY_L3_OPLEV_PIT_OUT_DQ', 'H1:SUS-ITMY_L3_OPLEV_YAW_OUT_DQ', ...
%                 'H1:SUS-BS_M3_OPLEV_PIT_OUT_DQ',   'H1:SUS-BS_M3_OPLEV_YAW_OUT_DQ', ...
%                 'H1:SUS-SRM_M3_WIT_P_DQ',          'H1:SUS-SRM_M3_WIT_Y_DQ', ...
%                 'H1:SUS-SR2_M3_WIT_P_DQ',          'H1:SUS-SR2_M3_WIT_Y_DQ', ...
%                 'H1:SUS-SR3_M3_WIT_P_DQ',          'H1:SUS-SR3_M3_WIT_Y_DQ', ...
%                 'H1:SUS-PRM_M3_WIT_P_DQ',          'H1:SUS-PRM_M3_WIT_Y_DQ', ...
%                 'H1:SUS-PR2_M3_WIT_P_DQ',          'H1:SUS-PR2_M3_WIT_Y_DQ', ...
%                 'H1:SUS-PR3_M3_WIT_P_DQ',          'H1:SUS-PR3_M3_WIT_Y_DQ'};
aux_channels = {'H1:ASC-AS_A_RF36_I_PIT_OUT_DQ', 'H1:ASC-AS_A_RF36_I_YAW_OUT_DQ', ...
                'H1:ASC-AS_A_RF36_Q_PIT_OUT_DQ', 'H1:ASC-AS_A_RF36_Q_YAW_OUT_DQ', ...
                'H1:ASC-AS_A_RF45_I_PIT_OUT_DQ', 'H1:ASC-AS_A_RF45_I_YAW_OUT_DQ', ...
                'H1:ASC-AS_A_RF45_Q_PIT_OUT_DQ', 'H1:ASC-AS_A_RF45_Q_YAW_OUT_DQ', ...
                'H1:ASC-AS_B_RF36_I_PIT_OUT_DQ', 'H1:ASC-AS_B_RF36_I_YAW_OUT_DQ', ...
                'H1:ASC-AS_B_RF36_Q_PIT_OUT_DQ', 'H1:ASC-AS_B_RF36_Q_YAW_OUT_DQ', ...
                'H1:ASC-AS_B_RF45_I_PIT_OUT_DQ', 'H1:ASC-AS_B_RF45_I_YAW_OUT_DQ', ...
                'H1:ASC-AS_B_RF45_Q_PIT_OUT_DQ', 'H1:ASC-AS_B_RF45_Q_YAW_OUT_DQ', ...
                'H1:ASC-REFL_A_RF9_I_PIT_OUT_DQ', 'H1:ASC-REFL_A_RF9_I_YAW_OUT_DQ', ...
                'H1:ASC-REFL_A_RF9_Q_PIT_OUT_DQ', 'H1:ASC-REFL_A_RF9_Q_YAW_OUT_DQ', ...
                'H1:ASC-REFL_A_RF45_I_PIT_OUT_DQ', 'H1:ASC-REFL_A_RF45_I_YAW_OUT_DQ', ...
                'H1:ASC-REFL_A_RF45_Q_PIT_OUT_DQ', 'H1:ASC-REFL_A_RF45_Q_YAW_OUT_DQ', ...
                'H1:ASC-REFL_B_RF9_I_PIT_OUT_DQ', 'H1:ASC-REFL_B_RF9_I_YAW_OUT_DQ', ...
                'H1:ASC-REFL_B_RF9_Q_PIT_OUT_DQ', 'H1:ASC-REFL_B_RF9_Q_YAW_OUT_DQ', ...
                'H1:ASC-REFL_B_RF45_I_PIT_OUT_DQ', 'H1:ASC-REFL_B_RF45_I_YAW_OUT_DQ', ...
                'H1:ASC-REFL_B_RF45_Q_PIT_OUT_DQ', 'H1:ASC-REFL_B_RF45_Q_YAW_OUT_DQ', ...
                'H1:ASC-REFL_A_DC_PIT_OUT_DQ','H1:ASC-REFL_A_DC_YAW_OUT_DQ', ...
                'H1:ASC-REFL_B_DC_PIT_OUT_DQ','H1:ASC-REFL_B_DC_YAW_OUT_DQ', ...
                'H1:ASC-AS_A_DC_PIT_OUT_DQ','H1:ASC-AS_A_DC_YAW_OUT_DQ', ...
                'H1:ASC-AS_B_DC_PIT_OUT_DQ','H1:ASC-AS_B_DC_YAW_OUT_DQ', ...
                'H1:ASC-POP_A_PIT_OUT_DQ','H1:ASC-POP_A_YAW_OUT_DQ', ...
                'H1:ASC-POP_B_PIT_OUT_DQ','H1:ASC-POP_B_YAW_OUT_DQ'};
              
d_aux = get_data(aux_channels, 'raw', gps, dt);
aux = zeros(dt * outfs, numel(d_aux));
% decimate them as the BLRMS
for i=1:numel(d_aux)
    % low pass
    [B,A] = butter(4, outfs/d_aux(i).rate, 'low');
    x = filtfilt(B,A, d_aux(i).data);
    % decimate
    aux(:,i) = x(1:d_aux(i).rate/outfs:end);
    % remove mean
    aux(:,i) = aux(:,i) - mean(aux(:,i));
    % rescale
    aux(:,i) = aux(:,i) / max(abs(aux(:,i)));
end
% get rid of the initial and final transients
aux = aux(2*outfs:end-2*outfs,:);

%% Plot BLRMS and aux channels (not much of an useful figure...)
figure
ax(1) = subplot(211);
plot(t, blrms(:,1) / 1e-14, 'r')
legend(arrayfun(@(i) sprintf('Band %d - %d Hz', bands(i,1), bands(i,2)), 1, 'UniformOutput', false))
ylabel('BLRMS [a.u.]')
ax(2) = subplot(212);
plot(t, aux)
legend(strrep(aux_channels, '_', '\_'))
linkaxes(ax, 'x')
ylabel('Signal [a.u.]')
xlabel('Time [s]')

%% Least square fit with all channels all together
A = aux;    % leave room here for additional rescaling or detrending if needed
B = blrms ./ repmat(max(abs(blrms)), [size(blrms,1),1]); % normalize

% use the channels and their squared values
X = [A, A.^2];
% add a constant
X(:, end+1) = 1;

% compute fit
b = 1;  % this select whihc band to use, if multiple
p0 = zeros(size(X,2),1);
idx = t>0;  % just in case you want to fit to only a part of the data
p = fminunc(@(p) mean(abs(abs(B(idx,b)) - X(idx,:)*p)), p0, optimset('display', 'iter'));

% plot result
figure()
plot(t, B(:,b), 'b', t, X*p, 'r')
xlabel('Time [s]')
ylabel('BLRMS [a.u.]')
legend('Data', 'Fit')
grid


%% Least square fit with channel ranking
b = 1;  % this selects which band you want to analyze

% build the list of all auxiliary channels
X = zeros(size(A,1), 2*size(A,2)+1);
for i=1:size(A,2)
    % add each channel together with its squared values
    X(:,2*i-1) = A(:,i);
    X(:,2*i) = A(:,i).^2;
    % and save the names for future reference
    cname{2*i-1} = aux_channels{i};
    cname{2*i} = [aux_channels{i}, '^2'];
end
% at the end, add also a constant
X(:,end) = 1;
cname{size(X,2)} = '1';


nsig = size(X,2);       % number of auxiliary channels
idx = zeros(nsig,1);    % this will contain the index of the best channels
p = zeros(nsig,1);      % and this will contain tehe corresponding parameter
for k=1:nsig
    % compute the signal to be fitted
    if k>1
        % this is the residual so far
        res = abs(B(:,b)) - X(:, idx(1:k-1)) * p(1:k-1);
    else
        % first iteration, just fit everything
        res = abs(B(:,b));
    end
    % find the best additional channel to minimize the residual
    for i=1:nsig
        if ~any(idx == i)   % check if this signal has already been used
            % store the coefficient and the residual error
            c(i) = fminsearch(@(p) mean(abs(res - X(:,i)*p)), 0, optimset('display', 'off'));
            err(i) = mean(abs(res - X(:,i)*c(i))); 
        else
            % already used, just skip it
            c(i) = 0;
            err(i) = Inf;
        end
    end
    % the best is the one with minimum residual error, save the index and
    % the coefficient
    [minerr(k), idx(k)] = min(err);
    p(k) = c(idx(k));
    fprintf(2, '%d) Best channel = %d (%s) \t\t new residual = %f\n', k, idx(k), cname{idx(k)}, minerr(k));
end

% plot the fit result
figure()
plot(t, B(:,b), 'b')
hold all
plot(t, X(:,idx)*p, 'r')
title(sprintf('Band %d - %d Hz', bands(b,1), bands(b,2)))
xlabel('Time [s]')
legend('Measured', 'Reconstructed')

% compute the incremental error reduction
ierr = sum(blrms(:,b).^2);
derr = -diff([ierr, minerr]);   % this computes the reduction in the residual obtained when adding each channel
[derr, ix] = sort(derr);        % sort them in ascending order
idxs = idx(ix);
% and plot it
figure()
barh(1:length(minerr), derr)
xlim([0, 1.3*max(derr(idxs~=nsig))])
ylim([0, length(minerr)+1])
set(gca, 'YTick', 1:length(minerr), 'YTickLabel',  cname(idxs))
xlabel('Residual error reduction')
