% test the TFE2 function
% BTL Oct 29, 2012

clear
close all

disp(['running ',mfilename,' on ',date])
my_colors;

%%

SEI_repo_path = '/Users/BTL/Brians_files/SeismicSVN/seismic/';
time_series_path = [SEI_repo_path,'HAM-ISI/Stanford/DAC_noise_model'];
addpath(time_series_path)

SUS_repo_path = '/Users/BTL/Brians_files/SUS_SVN_common/';
addpath([SUS_repo_path, 'Common/MatlabTools/TripleModel_Production']);


% make a fake time series from a known ASD
Ts = 1/400; % sampling time
span = 250;  % length of the time series

[time_HAM, freq_HAM, HAM_asd, HAM_series] = GenerateTimeSeries(@HAM_req, Ts, span);


figure
subplot(211);
ll=loglog(freq_HAM, HAM_asd);
set(ll(1),'LineWidth',1.5,'Color',orange)
title('ASD of the HAM spec')
xlabel('freq (Hz)')
ylabel('ASD (m/rtHz)')
axis tight
grid on

subplot(212)
ll=plot(time_HAM, HAM_series);
set(ll,'LineWidth',1.5,'Color',orange)
title('simulated time series of HAM table motion')
xlabel('time (sec)')
ylabel('meters')
axis tight
grid on
FillPage('t')
IDfig


%% make a fake triple pendulum response, then put it on top of the HAM-ISI

SUS_buildType = 'hstsopt_metal';
%[tripleModel,in,out,pend] = generate_Triple_Model_Production(freq_HAM, SUS_buildType);

svnDir = '/Users/BTL/Brians_files/SUS_SVN_common/';
isDamped = false;
plotFlag = false;

[tripleModel,in,out,pend] = generate_Triple_Model_Production(...
    freq_HAM, SUS_buildType,svnDir,plotFlag,isDamped);

triple_pend_L_SS = tripleModel.ss(out.m3.disp.L, in.gnd.disp.L);
triple_pend_L_FR = squeeze(tripleModel.f(out.m3.disp.L, in.gnd.disp.L,:));

%%
figure
subplot(211);
ll=loglog(freq_HAM, abs(triple_pend_L_FR));
set(ll(1),'LineWidth',1.5)
title('freq resp of triple: gnd-L to m3-L')
xlabel('freq (Hz)')
ylabel('ASD (m/rtHz)')
axis([.1 10 1e-4 1e3])
grid on

subplot(212)
ll=semilogx(freq_HAM, 180/pi*angle(triple_pend_L_FR));
set(ll,'LineWidth',1.5)
xlabel('freq (Hz)')
ylabel('phase (deg)')
axis([.1 10 -185 185])
grid on
FillPage('t')
IDfig

%% simulate the time series of the pendulum from ISI table motion

pend_motion_series = lsim(triple_pend_L_SS, HAM_series, time_HAM);

%%

figure
subplot(211);
ll=plot(time_HAM, HAM_series);
set(ll,'LineWidth',2,'Color',orange)
title('simulated time series of HAM table motion')
xlabel('time (sec)')
ylabel('meters')
axis tight
grid on

subplot(212)
ll=plot(time_HAM, pend_motion_series,'b');
set(ll,'LineWidth',2)
title('simulated time series of pendulum mass')
xlabel('time (sec)')
ylabel('meters')
axis tight
grid on
FillPage('t')
IDfig

%%

[HAM_asd2, freq_asd2] = asd2(HAM_series,         Ts, 9, 1, @hann);
[SUS_asd2, ~]         = asd2(pend_motion_series, Ts, 9, 1, @hann);


%%  plots
figure
ll=loglog(...
    freq_asd2, HAM_asd2,'b',...
    freq_asd2, SUS_asd2,'k');
set(ll(1),'LineWidth',1.5,'Color',orange);
set(ll(2),'LineWidth',1.5,'Color','b');
title('ASD of the HAM spec')
legend('HAM req','SUS pend motion')
xlabel('freq (Hz)')
ylabel('ASD (m/rtHz)')
axis([1e-2, 100, 1e-13, 2e-6])
grid on
IDfig
FillPage('w')

%% 

[tf_estimate, freq] = tfe2(HAM_series, pend_motion_series, Ts,9,1);

[Txy,F]           = tfestimate(HAM_series, pend_motion_series, [],[],[],1/Ts);

nfft = floor(length(HAM_series)* (1/9));
winwin = hanning(nfft,'periodic');
[Txy2,F2]          = tfestimate(HAM_series, pend_motion_series, winwin , floor(nfft/2),nfft ,1/Ts);

%%
figure
subplot(211)
ll=loglog(...
    freq_HAM, abs(triple_pend_L_FR), 'r',...
    freq, abs(tf_estimate),'b',...
    F2, abs(Txy2),'m');
set(ll(1),'LineWidth',3,'Color',[.7 0 0 ])
set(ll(2),'LineWidth',2)
set(ll(3),'LineWidth',1.5)
legend('per the model','tfe2','tfestimate')
grid on
axis([.1 20, 1e-5 1000])
title('Transfer function of the triple Pendulum mass')
xlabel('freq (Hz)')
ylabel('magnitude (m/m)')

subplot(212)
ll=semilogx(...
    freq_HAM, 180/pi*unwrap(angle(triple_pend_L_FR)), 'r',...
    freq, 180/pi*unwrap(angle(tf_estimate)),'b',...
    F2,   180/pi*unwrap(angle(Txy2)),'m');
set(ll(1),'LineWidth',3,'Color',[.7 0 0 ])
set(ll(2),'LineWidth',2)
set(ll(3),'LineWidth',1.5)
legend('per the model','tfe2','tfestimate')
grid on
axis([.1 20, -600 10])
xlabel('freq (Hz)')
ylabel('phase(degrees)')

FillPage('t')
IDfig
