% designs the 3 IIR filters to go along with the FIR filter
% this version is for the 2k version to be run on HEPI.
% on May 24, 2012, BTL added some more plots for a report
% on May 30, mod to 2k, changed data structures to HPI
%
% June 6, 2012 - updated figures for report  T1200285-v1
clear;
close all

Ts = 1/2048;

plot_filter = 1;
print_figs  = 0;

my_colors;
dk_cyan = [0 .8 .8];
%%

load FIR_Hydr_121603;
FIR_interp_rate = 32;  % number of parallel paths in the FIR code
model_rate      = 1/Ts;  % samples per sec for the model
FIR_rate        = 64;    % samples per sec fed to the FIR filter (set by Alex)
FIR_deci_rate   = model_rate/ FIR_rate;  % decimation rate to get from model rate to 64 samples/sec.
% it is either 32 for the 2k models of 64 for the 4 k models.


low_FIR_freq = 0.010;
blend_freq   = 0.4;

FIR_freq = model_rate / (FIR_interp_rate * FIR_deci_rate);
disp(['The FIR rate is ',num2str(FIR_freq),' Hz. It should be 2 Hz']);

[blend_FIR_d, total_IIR_d, VLF_highpass_w_AA_d, VLF_highpass_comp_only, anti_alias_TF, CT_filters] = ...
    design_aLIGO_FIR_companion_filters_20120112(low_FIR_freq, blend_freq, FIR_freq, Ts);

close all
%%


    
    
    %% push the input filters into nm output, instead of meter output

VLF_HP       = 1e9 * VLF_highpass_w_AA_d;  % output in nm
IIR_path     = 1e9 * total_IIR_d;
FIR_rolloff  = blend_FIR_d;

quackcheck(VLF_HP)
quackcheck(IIR_path)
quackcheck(FIR_rolloff)

% make an explicit version of the SS model, for matlab version issues
% seems stupid, but sometimes is necessary.
[VLF_HP_SS_DT.A, VLF_HP_SS_DT.B, VLF_HP_SS_DT.C, VLF_HP_SS_DT.D, VLF_HP_SS_DT.Ts] = ssdata(VLF_HP);
[VLF_HP_SS_CT.A, VLF_HP_SS_CT.B, VLF_HP_SS_CT.C, VLF_HP_SS_CT.D] = ssdata(CT_filters.VLFHP_wAA_CT);

[IIR_path_SS_DT.A, IIR_path_SS_DT.B, IIR_path_SS_DT.C, IIR_path_SS_DT.D, IIR_path_SS_DT.Ts] = ssdata(IIR_path);
[IIR_path_SS_CT.A, IIR_path_SS_CT.B, IIR_path_SS_CT.C, IIR_path_SS_CT.D] = ssdata(CT_filters.total_IIR_CT);

[FIR_rolloff_SS_DT.A, FIR_rolloff_SS_DT.B, FIR_rolloff_SS_DT.C, FIR_rolloff_SS_DT.D, FIR_rolloff_SS_DT.Ts] = ssdata(FIR_rolloff);
[FIR_rolloff_SS_CT.A, FIR_rolloff_SS_CT.B, FIR_rolloff_SS_CT.C, FIR_rolloff_SS_CT.D] = ssdata(CT_filters.merge_FIR_CT);

    
if plot_filter

    load aLIGO_calibrated_STS2_sensor_20120112 
    % loads STS2_calibrated_position_response


       
    % the freq resp is just the fft of the time resp.
    % the time resp is the list of coefficients.
    % there are 512 coefs, which defines the fft 
    % from DC to the sampling rate 
    % (same as -nyquist to + nyquist, but the matlab version starts at DC).
    % To get a more finely detailed FFT, we pad the time response with 0s
    % so instead of 2/512 = 0.0039 Hz bins we get 2/(10*512) = 0.00039 Hz bins
    fft_pad_rate  = 10;
    FIR_freq_len  = length(filter_coe)*fft_pad_rate;
    FIR_f         = fft(filter_coe, FIR_freq_len);

    FIR_wrap_number = 64;
    % FIR_wrap_f is the FIR highpass filter response, up to 128 Hz.
    % the top freq is FIR_wrap_number  x the FIR rate of 2 Hz.
    % just a bunch of nyquist reflections. 
    % the nyquist freq (1 Hz )to the model rate (2 Hz) is in the original 
    % FFT, so we just copy that a bunch of times

    FIR_wrap_FR = zeros(FIR_freq_len * FIR_wrap_number,1);
    for n=1:FIR_wrap_number
        FIR_wrap_FR((1:FIR_freq_len) + (n-1)*FIR_freq_len) = FIR_f;
    end
    
    freq_wrap = ((1:FIR_freq_len*FIR_wrap_number)-1)/FIR_freq_len*FIR_freq;
    freq      = logspace(-4,log10(200),5000);
 
    FIR_tf_FR = (10.^(interp1(log10(freq_wrap),log10(FIR_wrap_FR),log10(freq)))).';
    
    STS2_resp_FR    = squeeze(freqresp(STS2_calibrated_position_response, freq*2*pi));
    anti_alias_FR   = squeeze(freqresp(anti_alias_TF,  freq*2*pi));
    blend_FIR_FR    = squeeze(freqresp(blend_FIR_d,    freq*2*pi));
    total_IIR_FR    = squeeze(freqresp(total_IIR_d,    freq*2*pi));
    VLF_highpass_w_AA_FR      = squeeze(freqresp(VLF_highpass_w_AA_d, freq*2*pi));
    VLF_highpass_comp_only_FR = squeeze(freqresp(VLF_highpass_comp_only,freq*2*pi));
   
    
    tf_FIR_path_FR = STS2_resp_FR .* VLF_highpass_w_AA_FR .* FIR_tf_FR .* blend_FIR_FR;
    tf_IIR_path_FR = STS2_resp_FR .* total_IIR_FR;
    tf_all_FR      = tf_FIR_path_FR + tf_IIR_path_FR;

    VLF_HP_FR       = squeeze(freqresp(1e9 * VLF_highpass_w_AA_d, 2*pi*freq));  % output in nm

    total_FIR_FR = VLF_HP_FR .* FIR_tf_FR .* blend_FIR_FR;

    %%   plot performance prediction from JUST the FIR and blend
    FIR_part_FR       = FIR_tf_FR .* blend_FIR_FR;
    IIR_part_noSTS_FR = 1 - blend_FIR_FR;
    total_simple_FR   = FIR_part_FR + IIR_part_noSTS_FR;
    
    sens_inv_FR       = 1e9./STS2_resp_FR;  % (nm/sec) / count
    IIR_path_FR       = squeeze(freqresp(IIR_path,2*pi*freq));
    Highpass_blend_FR = IIR_path_FR ./ sens_inv_FR;

    %%   plot the final performance prediction
    
    fig_perf_est = figure;
    subplot(211);
    ll=loglog(...
        freq, abs(tf_all_FR),...
        freq, abs(1-tf_all_FR));
    set(ll,'LineWidth',2)
    legend('Final Highpass','Complement (transmission of sensed ground motion)',...
        'Location','south');
    ylabel('Mag - transmission of displacement');
    grid on;
    hold on
    ll1 = line([.1 1],1/10*[1 1]);
    ll2 = line([.1 1],1/20*[1 1]);
    set(ll1,'LineWidth',1.5,'Color',green,'Linestyle','--');
    set(ll2,'LineWidth',1.5,'Color',green,'Linestyle','--');
    t1 = text(1.01,1/10,'10x isolation');
    t2 = text(1.01,1/20,'20x isolation');
    set(t1,'FontSize',12,'fontWeight','bold','horizontalalignment','left');
    set(t2,'FontSize',12,'fontWeight','bold','horizontalalignment','left');
    axis([1e-3 1e2 1e-4 10])
    set(gca,'YTick',[1e-4 1e-3, 1e-2 1e-1 1 10])
    title('Final shape & performance of FIR and IIR filter set')
    
    subplot(212);
    ll=semilogx(...
        freq, 180/pi*angle(tf_all_FR),...
        freq, 180/pi*angle(1-tf_all_FR));
    set(ll,'LineWidth',2)
    grid on;
    ylabel('Phase (degree)');
    xlabel('Freq (Hz)');
    axis([1e-3 1e2 -185 185])
    set(gca,'YTick',90*(-2:2))
    FillPage('t')
    IDfig
    

        %%   plot the difference between just the FIR and the
        % FIR with all the companion filters
    
    fig_FIRvsTotal = figure;
    subplot(211);
    ll=loglog(...
        freq, abs(FIR_tf_FR),'k',...
        freq, abs(tf_all_FR),'b');
    set(ll(1),'LineWidth',2);
    set(ll(2),'LineWidth',1.5);
    
    legend('FIR filter only','Final Highpass',...
        'Location','south');
    ylabel('Mag - transmission of displacement');
    grid on;
    axis([1e-3 1e2 1e-4 10])
    set(gca,'YTick',[1e-4 1e-3, 1e-2 1e-1 1 10])
    title('Role of the IIR companion filters')
    
    subplot(212);
    ll=semilogx(...
        freq, 180/pi*angle(FIR_tf_FR),'k',...
        freq, 180/pi*angle(tf_all_FR),'b');
    set(ll(1),'LineWidth',2);
    set(ll(2),'LineWidth',1.5);
    grid on;
    ylabel('Phase (degree)');
    xlabel('Freq (Hz)');
    axis([1e-3 1e2 -185 185])
    set(gca,'YTick',90*(-2:2))
    FillPage('t')
    IDfig


%% plot module 0 - FIR
%anti_alias_FR  
%VLF_highpass_comp_only_FR 

    fig_mod0 = figure;

    subplot(211);
    ll = loglog(...
        freq, abs(VLF_HP_FR),'g',...
        freq, abs(anti_alias_FR),'r',...
        freq, abs(VLF_highpass_comp_only_FR),'m',...
        freq, abs(sens_inv_FR),'k--');
   
    set(ll,'LineWidth',1.5)
    set(ll(1),'Linewidth',2,'Color',purple)
    title('Components of module 0, FIR path')
    leg = legend(...
        'total of module 0, FIR path',...
        'Anti-alias filter',...
        'Very Low Freq IIR highpass', ...
        'STS-2 calib. for 1 cnt/(nm/sec)',...
        'Location','NorthEast');
    set(leg,'FontSize',14)
    ylabel('Mag');
    grid on;
    axis([1e-4 2e2 1e-5 1e4])
    set(gca,'YTick',[ 1e-4, 1e-2 1 100 1e4])

    
    subplot(212);
    ll=semilogx(...
        freq, 180/pi*angle(VLF_HP_FR),'b',...
        freq, 180/pi*angle(anti_alias_FR),'r',...
        freq, 180/pi*angle(VLF_highpass_comp_only_FR),'m',...
        freq, 180/pi*angle(sens_inv_FR),'k--');
    set(ll,'LineWidth',1.5)
    set(ll(1),'Linewidth',2,'Color',purple)
    grid on;
    ylabel('Phase (degree)');
    xlabel('Freq (Hz)');
    axis([1e-4 2e2 -185 185])
    set(gca,'YTick',90*(-2:2))
    FillPage('t')
    IDfig


%% plot module 0 - IIR

%anti_alias_FR  
%VLF_highpass_comp_only_FR 

    fig_IIRpath = figure;

    subplot(211);
    ll = loglog(...
        freq, abs(IIR_path_FR),'r',...
        freq, abs(Highpass_blend_FR),'r',...
        freq, abs(sens_inv_FR),'k--');
   
    set(ll,'LineWidth',1.5)
    set(ll(1),'Linewidth',2,'Color',olive)
    title('Components of the IIR path (all in module 0)')
    leg = legend(...
        'total IIR path',...
        ['HP blend at ',num2str(blend_freq,'%1.2f'),' Hz'],...
        'STS-2 inv. assumes 1 cnt/(nm/sec)',...
        'Location','NorthEast');
    set(leg,'FontSize',14)
    ylabel('Mag');
    grid on;
    axis([1e-4 1e2 1e-5 1e4])
    set(gca,'YTick',[ 1e-4 1e-2  1  100 1e4])

    
    subplot(212);
    ll=semilogx(...
        freq, 180/pi*angle(IIR_path_FR),'r',...
        freq, 180/pi*angle(Highpass_blend_FR),'r',...
        freq, 180/pi*angle(sens_inv_FR),'k--');
    set(ll,'LineWidth',1.5)
    set(ll(1),'Linewidth',2,'Color',olive)
    grid on;
    ylabel('Phase (degree)');
    xlabel('Freq (Hz)');
    axis([1e-4 1e2 -185 185])
    set(gca,'YTick',90*(-2:2))
    FillPage('t')
    IDfig

    
    %% plot components of the FIR path

    fig_FIRpath = figure;

    subplot(211);
    ll = loglog(...
        freq, abs(VLF_HP_FR),'g',...
        freq, abs(FIR_tf_FR),'b',...
        freq, abs(blend_FIR_FR),'c',...
        freq, abs(total_FIR_FR),'k');
   
    set(ll,'LineWidth',2)
    set(ll(1),'Color',purple)
    set(ll(3),'Color',dk_cyan)
    set(ll(4),'Color',darkgray)

    title('Components of the FIR path')
    leg = legend(...
        'module 0',...
        'FIR filter',...
        'LP blend',...
        'total FIR path',...
        'Location','south');
    set(leg,'FontSize',14)
    ylabel('Mag');
    grid on;
    axis([1e-4 1e2 1e-3 1e2])
    set(gca,'YTick',[ 1e-3, 1e-2 1e-1 1 10 100])

    
    subplot(212);
    ll=semilogx(...
        freq, 180/pi*angle(VLF_HP_FR),'g',...
        freq, 180/pi*angle(FIR_tf_FR),'b',...
        freq, 180/pi*angle(blend_FIR_FR),'c',...
        freq, 180/pi*angle(total_FIR_FR),'k');
    set(ll,'LineWidth',2)
    set(ll(1),'Color',purple)
    set(ll(3),'Color',dk_cyan)
    set(ll(4),'Color',darkgray)
    grid on;
    ylabel('Phase (degree)');
    xlabel('Freq (Hz)');
    axis([1e-4 1e2 -185 185])
    set(gca,'YTick',90*(-2:2))
    FillPage('t')
    IDfig

    %% plot total transmission

    fig_totalTrans = figure;

    subplot(211);
    ll = loglog(...
        freq, abs(total_FIR_FR),'k',...
        freq, abs(IIR_path_FR),'g',...
        freq, abs(tf_all_FR),'b',...
        freq, abs(sens_inv_FR),'k--',...
        freq, abs(total_FIR_FR + IIR_path_FR),'r');
   
    set(ll,'LineWidth',2)
    set(ll(1),'Color',darkgray)
    set(ll(2),'Color',olive)

    title('Components of Sensor Correction Path')
    leg = legend(...
        'FIR path',...
        'IIR path',...
        'Final Highpass (FHP)',...
        'STS-2 inv. assumes 1 cnt/(nm/sec)',...
        'total (FIR + IIR = STS-2 inv. x FHP)',...
        'Location','northeast');
    set(leg,'FontSize',12)
    ylabel('Mag (nm/cal. STS-2 signal (nm/sec above 8 mHz))');
    grid on;
    axis([1e-4 1e2 1e-3 1e3])
    set(gca,'YTick',[ 1e-3, 1e-2 1e-1 1 10 1e2 1e3])

    
    subplot(212);
    ll=semilogx(...
        freq, 180/pi*angle(total_FIR_FR),'k',...
        freq, 180/pi*angle(IIR_path_FR),'g',...
        freq, abs(tf_all_FR),'b',...
        freq, abs(sens_inv_FR),'k--',...
        freq, 180/pi*angle(total_FIR_FR + IIR_path_FR),'r');
   
    set(ll,'LineWidth',2)
    set(ll(1),'Color',darkgray)
    set(ll(2),'Color',olive)
    grid on;
    ylabel('Phase (degree)');
    xlabel('Freq (Hz)');
    axis([1e-4 1e2 -185 185])
    set(gca,'YTick',90*(-2:2))
    FillPage('w')
    IDfig

    %% plot the blend filter
    
    fig_blend = figure;

    subplot(211);
    ll = loglog(...
        freq, abs(Highpass_blend_FR),'r',...
        freq, abs(blend_FIR_FR),'c');
   
    set(ll,'LineWidth',2)
    set(ll(2),'Color',dk_cyan)
    title(['Complementary Blend Filter at ',num2str(blend_freq,'%1.2f'),' Hz'])
    leg = legend(...
        'Highpass blend for IIR path',...
        'Lowpass blend for FIR path',...
        'Location','South');
    set(leg,'FontSize',14)
    ylabel('Mag');
    grid on;
    axis([1e-4 1e2 1e-5 3])
    set(gca,'YTick',[1e-5 1e-4, 1e-3, 1e-2 1e-1 1 ])

    
    subplot(212);
    ll=semilogx(...
        freq, 180/pi*angle(Highpass_blend_FR),'r',...
        freq, 180/pi*angle(blend_FIR_FR),'c');
    set(ll,'LineWidth',2)
    set(ll(2),'Color',dk_cyan);
    grid on;
    ylabel('Phase (degree)');
    xlabel('Freq (Hz)');
    axis([1e-4 1e2 -185 185])
    set(gca,'YTick',90*(-2:2))
    FillPage('t')
    IDfig

end
%%

empty_SS_CT.A  = 0;
empty_SS_CT.B  = 0;
empty_SS_CT.C  = 0;
empty_SS_CT.D  = 0;

empty_SS_DT.A  = 0;
empty_SS_DT.B  = 0;
empty_SS_DT.C  = 0;
empty_SS_DT.D  = 0;
empty_SS_DT.Ts = 0;

% make an empty version of the final structure
FIR_2k_filter_struct_2012_05_30 = ...
    struct('name',{},'value',{},'label',{},'subblock', {}, 'turnon', {}, ...
    'SS_CT',empty_SS_CT, 'SS_DT', empty_SS_DT);  % make an empty one

filter_turnon = 'immediate';

% and a partially completed one for each section
temp = struct('name','temp','value',0,'label','temp' ,...
    'subblock', 0, 'turnon', filter_turnon,...
    'SS_CT',empty_SS_CT, 'SS_DT', empty_SS_DT);
ii = 1;

% now fill out each one, and append it to the big structure

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
DOF = 'X';

temp.name     = ['xxx_SENSCOR_',DOF,'_FIR'];  
temp.subblock = 0;
temp.value    = VLF_HP;
temp.label    = 'CAL,HP&AA';
temp.SS_CT    = VLF_HP_SS_CT;
temp.SS_DT    = VLF_HP_SS_DT;
FIR_2k_filter_struct_2012_05_30(ii) = temp; ii = ii+1;

temp.name     = ['xxx_SENSCOR_',DOF,'_FIR'];  
temp.subblock = 2;
temp.value    = FIR_rolloff;
temp.label    = 'Blnd_w_IIR';
temp.SS_CT    = FIR_rolloff_SS_CT;
temp.SS_DT    = FIR_rolloff_SS_DT;
FIR_2k_filter_struct_2012_05_30(ii) = temp; ii = ii+1;

temp.name     = ['xxx_SENSCOR_',DOF,'_IIRHP'];  
temp.subblock = 0;
temp.value    = IIR_path;
temp.label    = 'IIR_path';
temp.SS_CT    = IIR_path_SS_CT;
temp.SS_DT    = IIR_path_SS_DT;
FIR_2k_filter_struct_2012_05_30(ii) = temp; ii = ii+1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
DOF = 'Y';
temp.name     = ['xxx_SENSCOR_',DOF,'_FIR'];  
temp.subblock = 0;
temp.value    = VLF_HP;
temp.label    = 'CAL,HP&AA';
temp.SS_CT    = VLF_HP_SS_CT;
temp.SS_DT    = VLF_HP_SS_DT;
FIR_2k_filter_struct_2012_05_30(ii) = temp; ii = ii+1;

temp.name     = ['xxx_SENSCOR_',DOF,'_FIR'];  
temp.subblock = 2;
temp.value    = FIR_rolloff;
temp.label    = 'Blnd_w_IIR';
temp.SS_CT    = FIR_rolloff_SS_CT;
temp.SS_DT    = FIR_rolloff_SS_DT;
FIR_2k_filter_struct_2012_05_30(ii) = temp; ii = ii+1;

temp.name     = ['xxx_SENSCOR_',DOF,'_IIRHP'];  
temp.subblock = 0;
temp.value    = IIR_path;
temp.label    = 'IIR_path';
temp.SS_CT    = IIR_path_SS_CT;
temp.SS_DT    = IIR_path_SS_DT;
FIR_2k_filter_struct_2012_05_30(ii) = temp; ii = ii+1;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
DOF = 'Z';
temp.name     = ['xxx_SENSCOR_',DOF,'_FIR'];  
temp.subblock = 0;
temp.value    = VLF_HP;
temp.label    = 'CAL,HP&AA';
temp.SS_CT    = VLF_HP_SS_CT;
temp.SS_DT    = VLF_HP_SS_DT;
FIR_2k_filter_struct_2012_05_30(ii) = temp; ii = ii+1;

temp.name     = ['xxx_SENSCOR_',DOF,'_FIR'];  
temp.subblock = 2;
temp.value    = FIR_rolloff;
temp.label    = 'Blnd_w_IIR';
temp.SS_CT    = FIR_rolloff_SS_CT;
temp.SS_DT    = FIR_rolloff_SS_DT;
FIR_2k_filter_struct_2012_05_30(ii) = temp; ii = ii+1;

temp.name     = ['xxx_SENSCOR_',DOF,'_IIRHP'];  
temp.subblock = 0;
temp.value    = IIR_path;
temp.label    = 'IIR_path';
temp.SS_CT    = IIR_path_SS_CT;
temp.SS_DT    = IIR_path_SS_DT;
FIR_2k_filter_struct_2012_05_30(ii) = temp; ii = ii+1;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

FIRnote{1} = 'these are 2k the companion IIR filters for the FIR sensor correction';
FIRnote{2} = 'Designed to run on the HEPI';
FIRnote{3} = 'they already have the STS2 inversion in place';
FIRnote{4} = 'They assume the STS-2 is calibrated to 1 (nm/sec)/cnt above 8 mHz';
FIRnote{5} = 'and assume the disp sensors at the add point are calibrated to 1 nanometer/count';
FIRnote{6} = 'the match_x match_y and match_z filters should be 1';
FIRnote{7} = ['created by ',mfilename,' on ',date,' by BTL, on his laptop'];
FIRnote{8} = ['from the working directory ',pwd];
FIRnote{9} = 'SS_CT and SS_DT can be used to rebuild the state space matricies';

%save HPI_2k_FIR_companion_filters_20120530 FIR_2k_filter* FIRnote


if print_figs == true;
        
    figure(fig_perf_est)
    FillPage('t')
    print -dpdf FIR_figure_performance_estimate.pdf
    
    figure(fig_FIRvsTotal)
    FillPage('w')
    print -dpdf FIR_figure_FIRvsTotal.pdf
    
    figure(fig_mod0)
    FillPage('w')
    print -dpdf FIR_figure_module0.pdf

    figure(fig_IIRpath)
    FillPage('w')
    print -dpdf FIR_figure_IIR_path.pdf
    
    figure(fig_FIRpath)
    FillPage('w')
    print -dpdf FIR_figure_FIR_path.pdf
    
    figure(fig_totalTrans)
    FillPage('w')
    print -dpdf FIR_figure_complete_path.pdf

    figure(fig_blend)
    FillPage('w')
    print -dpdf FIR_figure_blends.pdf
    
end
