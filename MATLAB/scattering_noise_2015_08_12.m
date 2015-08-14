conn = nds2.connection('nds.ligo-wa.caltech.edu', 31200);
channels = {'H1:CAL-DELTAL_EXTERNAL_DQ', ...
            'H1:SUS-ITMX_M0_DAMP_L_IN1_DQ', ...
            'H1:SUS-ITMX_M0_DAMP_P_IN1_DQ', ...
            'H1:SUS-ITMX_M0_DAMP_Y_IN1_DQ', ...
            'H1:SUS-ITMY_M0_DAMP_L_IN1_DQ', ...
            'H1:SUS-ITMY_M0_DAMP_P_IN1_DQ', ...
            'H1:SUS-ITMY_M0_DAMP_Y_IN1_DQ', ...            '
            'H1:SUS-ETMX_M0_DAMP_L_IN1_DQ', ...
            'H1:SUS-ETMX_M0_DAMP_P_IN1_DQ', ...
            'H1:SUS-ETMX_M0_DAMP_Y_IN1_DQ', ...
            'H1:SUS-ETMY_M0_DAMP_L_IN1_DQ', ...
            'H1:SUS-ETMY_M0_DAMP_P_IN1_DQ', ...
            'H1:SUS-ETMY_M0_DAMP_Y_IN1_DQ', ...        
            'H1:SUS-OM1_M1_DAMP_L_IN1_DQ', ...
            'H1:SUS-OM1_M1_DAMP_P_IN1_DQ', ...
            'H1:SUS-OM1_M1_DAMP_Y_IN1_DQ', ...
            'H1:SUS-OM2_M1_DAMP_L_IN1_DQ', ...
            'H1:SUS-OM2_M1_DAMP_P_IN1_DQ', ...
            'H1:SUS-OM2_M1_DAMP_Y_IN1_DQ', ...
            'H1:SUS-OM3_M1_DAMP_L_IN1_DQ', ...
            'H1:SUS-OM3_M1_DAMP_P_IN1_DQ', ...
            'H1:SUS-OM3_M1_DAMP_Y_IN1_DQ', ...
            'H1:SUS-OMC_M1_DAMP_L_IN1_DQ', ...
            'H1:SUS-OMC_M1_DAMP_P_IN1_DQ', ...
            'H1:SUS-OMC_M1_DAMP_Y_IN1_DQ', ...      
            'H1:SUS-SRM_M1_DAMP_L_IN1_DQ', ...
            'H1:SUS-SRM_M1_DAMP_P_IN1_DQ', ...
            'H1:SUS-SRM_M1_DAMP_Y_IN1_DQ', ...
            'H1:SUS-SR2_M1_DAMP_L_IN1_DQ', ...
            'H1:SUS-SR2_M1_DAMP_P_IN1_DQ', ...
            'H1:SUS-SR2_M1_DAMP_Y_IN1_DQ', ...
            'H1:SUS-SR3_M1_DAMP_L_IN1_DQ', ...
            'H1:SUS-SR3_M1_DAMP_P_IN1_DQ', ...
            'H1:SUS-SR3_M1_DAMP_Y_IN1_DQ', ...
            'H1:SUS-BS_M1_DAMP_L_IN1_DQ', ...
            'H1:SUS-BS_M1_DAMP_P_IN1_DQ', ...
            'H1:SUS-BS_M1_DAMP_Y_IN1_DQ', ...
            'H1:SUS-PRM_M1_DAMP_L_IN1_DQ', ...
            'H1:SUS-PRM_M1_DAMP_P_IN1_DQ', ...
            'H1:SUS-PRM_M1_DAMP_Y_IN1_DQ', ...
            'H1:SUS-PR2_M1_DAMP_L_IN1_DQ', ...
            'H1:SUS-PR2_M1_DAMP_P_IN1_DQ', ...
            'H1:SUS-PR2_M1_DAMP_Y_IN1_DQ', ...
            'H1:SUS-PR3_M1_DAMP_L_IN1_DQ', ...
            'H1:SUS-PR3_M1_DAMP_P_IN1_DQ', ...
            'H1:SUS-PR3_M1_DAMP_Y_IN1_DQ', ...
            };
        
       
data1 = conn.fetch(1123422219, 1123422219+1500, channels);

e = double(data1(1).getData());
fs = 16384;
fs2 = 256;
t = (0:data1(2).getLength()-1)/fs2;

% compute BLRMS
[B,A] = butter(4, [20, 120]/(fs/2), 'bandpass');
ee = filter(B, A, e);
ee = ee.^2;
ee = decimate(ee, fs/fs2);
[B,A] = butter(4, 0.1/(fs2/2), 'low');
ee = filtfilt(B, A, ee);

% get rid of initial and final filter transients
t = t(fs2*30:end-fs2*30);
ee = ee(fs2*30:end-fs2*30);

% process aux channels
aux = zeros(data1(2).getLength(), numel(data1)-1);
% decimate them as the BLRMS
rate = 1/t(2);
for i=2:numel(data1)
    % low pass
    [B,A] = butter(4, 0.1/(fs2/2), 'low');
    aux(:,i-1) = filtfilt(B,A, double(data1(i).getData()));
    aux(:,i-1) = detrend(aux(:,i-1), 'linear');
end
% get rid of the initial and final transients
aux = aux(fs2*30:end-30*fs2,:);

A = aux;    % leave room here for additional rescaling or detrending if needed
B = ee/max(ee);

aux_channels = channels(2:end)';
        
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
plot(t, B, 'b', t, X*pp, 'r', 'LineWidth', 2)
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
plot(t, B, 'b')
hold all
plot(t, X(:,idx)*p, 'r')
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


