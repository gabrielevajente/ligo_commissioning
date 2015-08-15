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
Ts = 1/200; % sampling time
span = 400;  % length of the time series

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
isDamped = true;
plotFlag = false;

[tripleModel,in,out,pend] = generate_Triple_Model_Production(...
    freq_HAM, SUS_buildType,svnDir,plotFlag,isDamped);

triple_pend_undampedL_SS = tripleModel.ss(tripleModel.out.m3.disp.L, tripleModel.in.gnd.disp.L);
triple_pend_undampedL_FR = squeeze(...
    tripleModel.f(tripleModel.out.m3.disp.L, tripleModel.in.gnd.disp.L,:));

triple_pend_DampedL_SS = ...
    tripleModel.dampedss(tripleModel.dampedout.m3.disp.L, tripleModel.dampedin.gnd.disp.L);
triple_pend_DampedL_FR = squeeze(...
    tripleModel.dampedf(tripleModel.dampedout.m3.disp.L, tripleModel.dampedin.gnd.disp.L,:));

%%
figure
subplot(211);
ll=loglog(...
    freq_HAM, abs(triple_pend_undampedL_FR),'b',...
    freq_HAM, abs(triple_pend_DampedL_FR),'r');
set(ll(1),'LineWidth',2,  'Color',lt_blue);
set(ll(2),'LineWidth',1.5,'Color',purple);

title('freq resp of triple: gnd-L to m3-L')
xlabel('freq (Hz)')
ylabel('mag TF (m/m)')
axis([.1 10 1e-4 1e3])
grid on

subplot(212)
ll=semilogx(...
    freq_HAM, 180/pi*angle(triple_pend_undampedL_FR),'b',...
    freq_HAM, 180/pi*angle(triple_pend_DampedL_FR),'r');
set(ll(1),'LineWidth',2,  'Color',lt_blue);
set(ll(2),'LineWidth',1.5,'Color',purple);

xlabel('freq (Hz)')
ylabel('phase (deg)')
axis([.1 10 -185 185])
grid on
FillPage('t')
IDfig

%% simulate the time series of the pendulum from ISI table motion

pend_motion_series = lsim(triple_pend_DampedL_SS, HAM_series, time_HAM);

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

%%
figure
subplot(211);
ll=loglog(...
    freq_HAM, abs(triple_pend_DampedL_FR),...
    freq, abs(tfe));
set(ll(1),'LineWidth',1.5)
title('freq resp of triple: gnd-L to m3-L')
xlabel('freq (Hz)')
ylabel('mag TF (m/m)')
axis([.1 10 1e-4 1e3])
legend('from model','from coh2')
grid on

subplot(212)
ll=semilogx(...
    freq_HAM, 180/pi*angle(triple_pend_DampedL_FR),...
    freq,     180/pi*angle(tfe));
set(ll,'LineWidth',1.5)
xlabel('freq (Hz)')
ylabel('phase (deg)')
axis([.1 10 -185 185])
grid on
FillPage('t')
IDfig

