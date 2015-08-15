% test the COH2 function
% BTL Oct 16, 2012

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

SUS_buildType = 'hltsopt_metal';
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

[coherence, freq] = coh2(HAM_series, pend_motion_series, Ts,9,1);

[Cxy,F]           = mscohere(HAM_series, pend_motion_series, [],[],[],1/Ts);

%%
figure
ll=semilogx(...
    freq, coherence,'b',...
    F, Cxy,'m');
set(ll,'LineWidth',1.5)
legend('coh2','mscohere')
grid on
axis([.1 100, 0 1])
title({'Coherence between the HAM-ISI table and the Pendulum mass','Warning - This plot is filled with lies'})
xlabel('freq (Hz)')
ylabel('calculated coherence')

%% make a half sine.

t_end = 100;

time1 = (0: Ts: t_end);
sig_base  = sin(2*pi*time1/t_end);

%figure
%plot(time1,sig_base)

n1 = .003 * randn(size(sig_base));
n2 = .003 * randn(size(sig_base));

sig1 = sig_base + n1;
sig2 = sig_base + n2;

figure
plot(...
    time1, sig1,...
    time1, sig2 + .1);
title('Two 10mHz sine waves with independant high freq noise')
legend('sig1','sig2 + 0.1 plot offset')
grid on
xlabel('time (sec)')
ylabel('mag (e.g. V)')
FillPage('w')
IDfig
%%
[pw, f_pw] = pwelch(sig1, [], [], [], 1/Ts);
asd_n1_pw  = sqrt(pw);

[asd_n1_asd, f_asd] = asd2(sig1, Ts);

figure
ll=loglog(...
    f_asd, asd_n1_asd, 'b',...
    f_pw,  asd_n1_pw, 'm');
set(ll,'LineWidth',1.5)
grid on
axis tight
legend('asd2','pwelch')
title('ASD of sig1')
legend('calc w/ asd2','calc w/ pwelch')
xlabel('freq (Hz)')
ylabel('ASD mag (e.g. V/rtHz)')
FillPage('w')
IDfig

%%
[coh_coh2, f_coh2] = coh2(    sig1, sig2, Ts);
[coh_msc,  f_msc]  = mscohere(sig1, sig2, [], [], [], 1/Ts);

%%
figure
ll=semilogx(...
    f_coh2, coh_coh2, 'b',...
    f_msc,  coh_msc, 'm');
set(ll,'LineWidth',1.5)
legend('coh2','mscohere-default')
grid on
axis([.01 200 0 1])
title('Coherence estimate of the noisy 10 mHz sine waves')
legend('calc with coh2', 'calc w/ mscohere')
FillPage('w')
IDfig
