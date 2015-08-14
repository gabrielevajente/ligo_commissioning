%% load quiet data
g = GWData;
gps = 1113206116;
dt = 60*7;
[data,t,info] = g.fetch(gps, gps+dt, {'H1:CAL-DELTAL_EXTERNAL_DQ', 'H1:LSC-SRCL_OUT_DQ'});
darm0 = data(:,1);
srcl0 = data(:,2);

%% load data with SRLC noise injection
gps = 1113211711;
dt = 120 + 60;
g = GWData;
[data,t,info] = g.fetch(gps, gps+dt, {'H1:CAL-DELTAL_EXTERNAL_DQ', 'H1:LSC-SRCL_OUT_DQ'});
darm = data(:,1);
srcl = data(:,2);

%% spectrogram, cohegram and tfgram
np = 16384;
[S,F,T] = spectrogram(darm, hanning(np), np/2, np, 16384);
plotSpectrogram(T,F,log10(abs(S)))
ylim([0 400])
caxis([-7, -2])

[C,T,F] = cohegram(darm, srcl, np, 3/4*np, 8, 16384);
plotSpectrogram(T,F,C)
ylim([0 400])

[TF,T,F] = tfgram(srcl, darm, np, 3/4*np, 8, 16384);
subplot(211)
plotSpectrogram(T,F,log10(abs(TF)))
caxis([-12, -9])
ylim([0 400])
title('Abs')
subplot(212)
plotSpectrogram(T,F,angle(TF))
ylim([0 400])
title('Phase')

% plot spectrogram and cohegram together
figure()
subplot(211)
plotSpectrogram(T,F,log10(abs(S)))
ylim([0 400])
subplot(212)
plotSpectrogram(T,F,C)
ylim([0 400])

%% animation of SRCL coupling
figure()
for i=1:size(TF,2)
    subplot(211)
    loglog(F, abs(TF(:,i)))
    title(sprintf('Time %.2f s', T(i)))
    xlim([1, 1000])
    ylim([1e-13, 1e-9])
    grid
    subplot(212)
    semilogx(F, angle(TF(:,i)))
    xlim([1, 1000])
    grid
    pause(T(2)-T(1))
end

%% create animated GIF file
h = figure();
subplot(211)
loglog(F, abs(TF(:,1)))
title(sprintf('Time %.2f s', T(1)))
xlim([1, 1000])
ylim([1e-13, 1e-9])
grid
subplot(212)
semilogx(F, angle(TF(:,1)))
xlim([1, 1000])
grid

f = getframe(h);
[im,map] = rgb2ind(f.cdata,256,'nodither');
im(1,1,1,20) = 0;

for i=2:size(TF,2)
    subplot(211)
    loglog(F, abs(TF(:,i)))
    title(sprintf('Time %.2f s', T(i)))
    xlim([1, 1000])
    ylim([1e-13, 1e-9])
    grid
    subplot(212)
    semilogx(F, angle(TF(:,i)))
    xlim([1, 1000])
    grid
    
    f = getframe(h);
    im(:,:,1,i) = rgb2ind(f.cdata,map,'nodither');
end

imwrite(im,map,'animation.gif','DelayTime',0.25,'LoopCount',inf)


%% Compute BLRMS
darm2048 = decimate(darm, 16384/2048);
srcl2048 = decimate(srcl, 16384/2048);
fs = 2048;
bands = [50, 100]; % frequency band
outfs = 8;         % output sampling frequency
    
nbands = size(bands, 1);
blrms = zeros(dt*outfs, nbands);
for i=1:nbands
    % band pass
    [B,A] = butter(4, bands(i,:)/(fs/2), 'bandpass');
    x = filtfilt(B, A, darm2048);
    % square
    x = x.^2;
    % low pass
    [B,A] = butter(4, outfs/(fs/2), 'low');
    x = filtfilt(B,A, x);
    % decimate
    blrms(:,i) = x(1:fs/outfs:end);
end
% get rid of the initial and final transients
blrms = blrms(outfs:end-outfs,:);
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
                'H1:ASC-REFL_B_RF45_Q_PIT_OUT_DQ', 'H1:ASC-REFL_B_RF45_Q_YAW_OUT_DQ'};
                
[d_aux,t,info] = g.fetch(gps, gps+dt, aux_channels);
aux = zeros(dt * outfs, size(d_aux,2));
% decimate them as the BLRMS
rate = 1/t(2);
for i=1:size(d_aux,2)
    % low pass
    [B,A] = butter(4, outfs/rate, 'low');
    x = filtfilt(B,A, d_aux(:,i));
    % decimate
    aux(:,i) = x(1:rate/outfs:end);
    % remove mean
    aux(:,i) = aux(:,i) - mean(aux(:,i));
    % rescale
    aux(:,i) = aux(:,i) / max(abs(aux(:,i)));
end
% get rid of the initial and final transients
aux = aux(outfs:end-outfs,:);
t = (1:size(blrms,1))/outfs;

%% Least square fit with all channels together
A = aux;    % leave room here for additional rescaling or detrending if needed
B = blrms ./ repmat(max(abs(blrms)), [size(blrms,1),1]); % normalize

% use the channels and their squared values
X = [A, A.^2];
% add a constant
X(:, end+1) = 1;
 
% compute fit
b = 1;  % this select which band to use, if multiple
p0 = zeros(size(X,2),1);
idx = abs(B(:,b)) < 0.15 & B>0;
error = @(p) mean((B(idx,b) - X(idx,:)*p).^2);
pp = (X(idx,:).'*X(idx,:)) \ X(idx,:).' * B(idx,b);

 
%plot result
figure()
plot(t, B(:,b), 'b', t, X*pp, 'r')
%ylim([0, 0.1])
xlabel('Time [s]')
ylabel('BLRMS [a.u.]')
legend('Data', 'Fit')
grid



%% Fit TF variation
idx = F>83 & F<103;
tft = mean(TF(idx,:));
figure()
plot(T, real(tft), T, imag(tft))

% resample aux channels
clear aux
for i=1:size(d_aux,2)
    % low pass
    [B,A] = butter(4, outfs/rate, 'low');
    x = filtfilt(B,A, d_aux(:,i));
    % decimate
    aux(:,i) = x(1:rate/outfs:end);
end
aux = aux(outfs:end-outfs,:);
t = (1:size(aux,1))/outfs;

tft2 = interp1(T, tft, t)';

% use the channels and their squared values
X = [aux, aux.^2];
% add a constant
X(:, end+1) = 1;
 
% compute fit
p0 = zeros(size(X,2),1);
pp = (X.'*X) \ X.' * real(tft2);

 
%plot result
figure()
plot(t, real(tft2), 'b', t, X*pp, 'r', t, real(tft2) - X*pp , 'g')
%ylim([0, 0.1])
xlabel('Time [s]')
ylabel('BLRMS [a.u.]')
legend('Data', 'Fit', 'Residual')
grid


%% Least square fit with channel ranking
B = real(tft2) / max(abs(real(tft2)));
A = aux;

% build the list of all auxiliary channels
X = zeros(size(A,1), 2*size(A,2)+1);
for i=1:size(A,2)
    % add each channel together with its squared values
    X(:,i) = A(:,i) - mean(A(:,i));
    X(:,i) = X(:,i) / max(abs(X(:,i)));
    % and save the names for future reference
    cname{i} = strrep(aux_channels{i}, '_', '\_');
end
% at the end, add also a constant
X(:,end) = 1;
cname{size(X,2)} = '1';
 
nsig = size(X,2);       % number of auxiliary channels
niter = nsig;
idx = zeros(niter,1);    % this will contain the index of the best channels
p = zeros(niter,1);      % and this will contain tehe corresponding parameter
for k=1:niter
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
plot(t, B, 'b')
hold all
plot(t, X(:,idx)*p, 'r')
title(sprintf('Band %d - %d Hz', bands(b,1), bands(b,2)))
xlabel('Time [s]')
legend('Measured', 'Reconstructed')

 
% compute the incremental error reduction
ierr = sum(B.^2);
derr = -diff([ierr, minerr]);   % this computes the reduction in the residual obtained when adding each channel
[derr, ix] = sort(derr);        % sort them in ascending order
idxs = idx(ix);
% and plot it
figure()
barh(1:length(minerr), derr)
xlim([0, 1.3*max(derr(idxs~=niter))])
ylim([0, length(minerr)+1])
set(gca, 'YTick', 1:length(minerr), 'YTickLabel',  cname(idxs))

figure()
plot(t, real(tft2), 'b', t, -1.755e-9*aux(:,3) + 5.965e-10, 'r')
xlabel('Time [s]')
ylabel('DARM/SRCL @ 100 Hz')
legend('Measured', 'Fit with ETMY OPLEV PIT')
grid


%% Try coherence with convolved signal
np = 2048;
[c,f] = mscohere(darm2048, srcl2048, hanning(np), np/2, np, 2048);

as = interp1(t, aux(:,6), (1:length(srcl2048))'/2048);
srcl_as = srcl2048 .* (4.31e-14*as + 9.041e-11);

[cc,f] = mscohere(darm2048(~isnan(as)), srcl_as(~isnan(as)), hanning(np), np/2, np, 2048);
[tt,f] = tfestimate(srcl_as(~isnan(as)), darm2048(~isnan(as)), hanning(np), np/2, np, 2048);


figure()
semilogx(f, c, f, cc)
xlabel('Frequency [Hz]')
ylabel('Coherence')
legend('DARM / SRCL', 'DARM / (improved SRCL)')
grid
