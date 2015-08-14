% Starting time and duration
gpsb = 1109830000;
dt = 600;
% list of channels: the first one is the power, the others are the ASC signals
%power_channel = 'H1:LSC-ASAIR_B_RF90_I_ERR_DQ';
%power_channel = 'H1:LSC-ASAIR_A_LF_OUT_DQ';
%power_channel = 'H1:LSC-POPAIR_B_LF_OUT_DQ';
power_channel = 'H1:LSC-TR_X_NORM_INMON';
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
channels = [power_channel, aux_channels];
% read data
d = get_data(channels, 'raw', gpsb, dt);
% output sampling frequency
fsout = 4;
% decimate
power = decimate(d(1).data, d(1).rate / fsout);
a = zeros(fsout*dt, numel(d)-1);
for i=2:numel(d)
    a(:,i-1) = decimate(d(i).data, d(i).rate/fsout);
end
t = (1:length(power))/fsout;

%% Least square fit with all channels all together
A = zeros(fsout*dt, numel(d)-1);
for i=1:size(a,2)
    A(:,i) = a(:,i) / max(abs(a(:,i)));
end

% use the channels and their squared values
X = [A, A.^2];
% add a constant
X(:, end+1) = 1;

% compute fit
c0 = zeros(size(X,2),1);
idx = t>0;  % just in case you want to fit to only a part of the data
c = fminunc(@(c) mean(abs(power(idx) - X(idx,:)*c).^2), c0, optimset('display', 'iter', 'maxfunevals', 1e6, 'maxiter', 10000));

% plot result
figure()
plot(t, power, 'b-', t, X*c, 'r-', 'LineWidth', 2)
xlabel('Time [s]')
ylabel(strrep(power_channel, '_', '\_'))
legend('Data', 'Fit')
grid


%% Least square fit with channel ranking
power = power - mean(power);

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
        res = power - X(:, idx(1:k-1)) * p(1:k-1);
    else
        % first iteration, just fit everything
        res = power;
    end
    % find the best additional channel to minimize the residual
    for i=1:nsig
        if ~any(idx == i)   % check if this signal has already been used
            % store the coefficient and the residual error
            c(i) = fminsearch(@(p) mean(abs(res - X(:,i)*p).^2), 0, optimset('display', 'off'));
            err(i) = mean(abs(res - X(:,i)*c(i)).^2); 
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
plot(t, power, 'b')
hold all
plot(t, X(:,idx)*p, 'r')
title(strrep(power_channel, '_', '\_'))
xlabel('Time [s]')
legend('Measured', 'Reconstructed')

% compute the incremental error reduction
ierr = mean(power.^2);
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

