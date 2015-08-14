addpath(genpath('/ligo/svncommon/40mSVN/DttData'));
addpath(genpath('/ligo/svncommon/SeiSVN/seismic/Common/MatlabTools'));

gps_start = 1123064009;
gps_stop = 1123072749;
dt = gps_stop - gps_start;

file_list = dir('IssCoupIOP_*.xml');

ch1 = 'H1:IOP-PSL0_MADC0_TP_CH20';
ch2 = 'H1:IOP-LSC0_MADC0_TP_CH12';

hnum = 888;
h = figure(hnum);
clf(hnum);
colors = bone(floor(1.4*length(file_list)));

for ii=1:length(file_list);
    file_name = file_list(ii).name;
    disp(file_name)
    gps_time = strrep(strrep(file_name, 'IssCoupIOP_', ''), '.xml', '')
    time = gps_time - gps_start;
    %if gps_time < gps_start && gps_time < gps_stop:
    data = DttData(file_name);
    [ff tf] = data.transferFunction(ch1, ch2);
    [ff coh] = data.coherence(ch1, ch2);
    ff = ff(coh>0.5);
    %dcpd_resp = 1e3 * readFilterResp('/opt/rtcds/lho/h1/chans/H1OMC.txt', [1 4 5 7], ff); % mA/ct
    %iss_pd_resp = readFilterResp('/opt/rtcds/lho/h1/chans/H1PSLISS.txt', 'ISS_SECONDLOOP_PD1', [1 2], ff); % V/ct
    tf = tf(coh>0.5); %*dcpd_resp/iss_pd_resp;
    subplot(211);
    loglog(ff, abs(tf), '.', 'Color', colors(ii,:));
    hold all;
    subplot(212);
    semilogx(ff, angle(tf)*180/pi, '.', 'Color', colors(ii,:));
    hold all;
end;

subplot(211);
ylabel('Magnitude [mA/V]');
title('Intensity coupling in DARM');
xlim([500 30e3]);
ylim([3e-3 10]);
grid on;
subplot(212);
ylabel('Phase [deg.]');
xlabel('Frequency [Hz]');
xlim([500 30e3]);
grid on;

colorbar();
colormap(colors);
caxis([1, 1.4*length(file_list)])
