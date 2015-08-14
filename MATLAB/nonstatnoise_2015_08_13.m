g = GWData;
channel = {'H1:CAL-DELTAL_EXTERNAL_DQ'};
aux_channels = {'H1:ASC-DHARD_P_OUT_DQ', 'H1:ASC-DHARD_Y_OUT_DQ', ...
                'H1:ASC-CHARD_P_OUT_DQ', 'H1:ASC-CHARD_Y_OUT_DQ', ...
                'H1:SUS-ETMX_L3_OPLEV_PIT_OUT_DQ', 'H1:SUS-ETMX_L3_OPLEV_YAW_OUT_DQ', ...
                'H1:SUS-ETMY_L3_OPLEV_PIT_OUT_DQ', 'H1:SUS-ETMY_L3_OPLEV_YAW_OUT_DQ', ...
                'H1:SUS-ITMX_L3_OPLEV_PIT_OUT_DQ', 'H1:SUS-ITMX_L3_OPLEV_YAW_OUT_DQ', ...
                'H1:SUS-ITMY_L3_OPLEV_PIT_OUT_DQ', 'H1:SUS-ITMY_L3_OPLEV_YAW_OUT_DQ', ...
                'H1:SUS-BS_M3_OPLEV_PIT_OUT_DQ', 'H1:SUS-BS_M3_OPLEV_YAW_OUT_DQ', ...
                'H1:SUS-PRM_M3_WIT_P_DQ', 'H1:SUS-PRM_M3_WIT_Y_DQ', ...
                'H1:SUS-SRM_M3_WIT_P_DQ', 'H1:SUS-SRM_M3_WIT_Y_DQ', ...
                'H1:SUS-PR2_M3_WIT_P_DQ', 'H1:SUS-PR2_M3_WIT_Y_DQ', ...
                'H1:SUS-SR2_M3_WIT_P_DQ', 'H1:SUS-SR2_M3_WIT_Y_DQ', ...
                'H1:SUS-PR3_M3_WIT_P_DQ', 'H1:SUS-PR3_M3_WIT_Y_DQ', ...
                'H1:SUS-SR3_M3_WIT_P_DQ', 'H1:SUS-SR3_M3_WIT_Y_DQ', ...
               };
       
data = g.fetch(1123483447, 1123483447+1200, channel);
aux = g.fetch(1123483447, 1123483447+1200, aux_channels);

cali = zpk(-2*pi*[100 100 100 100 100], -2*pi*[1 1 1 1 1], 1);
cali.k = cali.k / abs(fresp(cali, 0));

fs = 16384;
np = fs*10;
[sp,fr] = pwelch(data, hanning(np), np/2, np, fs);
sp = sqrt(sp);
calib = abs(fresp(cali, fr));

fs2 = 512;
data2 = decimate(data, fs/fs2);
np2 = fs2*1;
[S,F,T] = spectrogram(data2, hanning(np2), np2/2, np2, fs2);
C = repmat(abs(fresp(cali, F)), [1, size(S,2)]);
S = abs(S) .* C;

np2 = fs2 * 5;
[c_dhp,fr2] = mscohere(data2, aux(:,1), hanning(np2), np2/2, np2, fs2);
c_dhy = mscohere(data2, aux(:,2), hanning(np2), np2/2, np2, fs2);
c_chp = mscohere(data2, aux(:,3), hanning(np2), np2/2, np2, fs2);
c_chy = mscohere(data2, aux(:,4), hanning(np2), np2/2, np2, fs2);

semilogx(fr2, c_dhp, fr2, c_dhy, fr2, c_chp, fr2, c_chy, 'LineWidth', 2)
legend('DHARD PIT', 'DHARD YAW', 'CHARD PIT', 'CHARD YAW')
xlabel('Frequency [Hz]')
ylabel('Coherence')
grid


[Cp,T,F] = cohegram(data2, aux(:,3), np2, np2/2, 5, fs2);
[Cy,T,F] = cohegram(data2, aux(:,4), np2, np2/2, 5, fs2);

subplot(211)
plotSpectrogram(T,F, Cp)
xlabel('Time [s]')
ylabel('Frequency [Hz]')
title('Coherence CHARD PIT')
colorbar
subplot(212)
plotSpectrogram(T,F, Cy)
xlabel('Time [s]')
ylabel('Frequency [Hz]')
title('Coherence CHARD YAW')
colorbar

sp_dhp = sqrt(pwelch(aux(:,1), hanning(np2), np2/2, np2, fs2));
sp_dhy = sqrt(pwelch(aux(:,2), hanning(np2), np2/2, np2, fs2));
sp_chp = sqrt(pwelch(aux(:,3), hanning(np2), np2/2, np2, fs2));
sp_chy = sqrt(pwelch(aux(:,4), hanning(np2), np2/2, np2, fs2));


fnotch = [35.9, 36.7, 41, 60];
e = data2;
for i=1:numel(fnotch)
    num = [1, 2*pi*fnotch(i)/10000, (2*pi*fnotch(i))^2];
    den = [1, 2*pi*fnotch(i)/100, (2*pi*fnotch(i))^2];
    [b,a] = bilinear(num, den, fs2, fnotch(i));
    e = filtfilt(b, a, e);
end

[b,a] = butter(4, [20, 50]/(fs2/2), 'bandpass');
ee = filtfilt(b, a, e);
ee = ee.^2;
[b, a] = butter(4, .3/(fs2/2), 'low');
ee = filtfilt(b, a, ee);
tt = (0:length(ee)-1)/fs2;

clear A
for i=1:size(aux,2)
    A(:,i) = detrend(filtfilt(b, a, aux(:,i)), 'linear');
end

ee = ee(fs2*25:end-fs2*25);
tt = tt(fs2*25:end-fs2*25);
A  = A(fs2*25:end-fs2*25,:);

B = ee/max(ee);

       
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

% compute fit
pp = (X.'*X) \ X.' * B;
 
%plot result
figure()
plot(tt, B, 'b', tt, X*pp, 'r', 'LineWidth', 2)
xlabel('Time [s]')
ylabel('BLRMS [a.u.]')
legend('Data', 'Fit')
grid

nsig = size(X,2);       % number of auxiliary channels
idx = zeros(nsig,1);    % this will contain the index of the best channels
p = zeros(nsig,1);      % and this will contain the corresponding parameter
for k=1:nsig
    % compute the signal to be fitted
    if k>1
        % this is the residual so far
        res = B - X(:, idx(1:k-1)) * p(1:k-1);
    else
        % first iteration, just fit everything
        res = B;
    end
    % find the best additional channel to minimize the residual
    for i=1:nsig
        if ~any(idx == i)   % check if this signal has already been used
            % store the coefficient and the residual error
            %c(i) = fminsearch(@(p) mean(abs(res - X(:,i)*p).^2), 0, optimset('display', 'off'));
            c(i) = (X(:,i).'*X(:,i)) \ X(:,i).' * res;
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
plot(tt, B, 'b')
hold all
plot(tt, X(:,idx)*p, 'r')
xlabel('Time [s]')
legend('Measured', 'Reconstructed')

% compute the incremental error reduction
ierr = mean(B.^2);
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



