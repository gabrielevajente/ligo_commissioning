% designs the 3 IIR filters to go along with the FIR filter
% this version is for the 4k version to be run on the ISI at Stanford.

clear;
close all

addpath /home/controls/SeismicSVN/seismic/Common/MatlabTools/
addpath /home/controls/SeismicSVN/seismic/HAM-ISI/Common/MatlabTools/
Ts = 1/4096;

plot_filter=1;

%%

load FIR_Hydr_121603;
FIR_interp_rate = 32;  % number of parallel paths in the FIR code
model_rate      = 1/Ts;  % samples per sec for the model
FIR_rate        = 64;    % samples per sec fed to the FIR filter (set by Alex)
FIR_deci_rate   = model_rate/ FIR_rate;  % decimation rate to get from model rate to 64 samples/sec.
% it is either 32 for the 2k models of 64 for the 4 k models.


low_FIR_freq = 0.010;
merge_freq   = 0.4;

FIR_freq = model_rate / (FIR_interp_rate * FIR_deci_rate);
disp(['The FIR rate is ',num2str(FIR_freq),' Hz. It should be 2 Hz']);

[merge_FIR_d, merge_IIR_d, VLF_highpass_w_AA_d, VLF_highpass_comp_only, anti_alias_TF] = ...
    design_aLIGO_FIR_companion_filters_20120112(low_FIR_freq, merge_freq, FIR_freq, Ts);

%%
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
    freq      = logspace(-4,log10(128),2000);
 
    FIR_tf_FR = (10.^(interp1(log10(freq_wrap),log10(FIR_wrap_FR),log10(freq)))).';
    
    STS2_resp_FR    = squeeze(freqresp(STS2_calibrated_position_response, freq*2*pi));
    anti_alias_FR   = squeeze(freqresp(anti_alias_TF,  freq*2*pi));
    merge_FIR_FR    = squeeze(freqresp(merge_FIR_d,    freq*2*pi));
    merge_IIR_FR    = squeeze(freqresp(merge_IIR_d,    freq*2*pi));
    VLF_highpass_w_AA_FR      = squeeze(freqresp(VLF_highpass_w_AA_d, freq*2*pi));
    VLF_highpass_comp_only_FR = squeeze(freqresp(VLF_highpass_comp_only,freq*2*pi));
   
    
    tf_FIR_path_FR = STS2_resp_FR .* VLF_highpass_w_AA_FR .* FIR_tf_FR .* merge_FIR_FR;
    tf_IIR_path_FR = STS2_resp_FR .* merge_IIR_FR;
    tf_all_FR      = tf_FIR_path_FR + tf_IIR_path_FR;

    %%   plot the final performance prediction
    
    figure;
    data_plot=[tf_all_FR 1-(tf_all_FR)];
    subplot(211);
    ll=loglog(freq,abs(data_plot));
    set(ll,'LineWidth',2)
    legend('Overall Highpass','Complement (transmission of sensed ground motion)',...
        'Location','south');
    ylabel('Mag');
    grid on;
    hold on
    line([.1 1],1/10*[1 1])
    line([.1 1],1/30*[1 1])
    axis([1e-3 1e2 1e-4 10])
    title('Final shape & performance of FIR and IIR filter set')
    
    subplot(212);
    ll=semilogx(freq,angle(data_plot)/pi*180);
    set(ll,'LineWidth',2)
    grid on;
    ylabel('Phase (degree)');
    xlabel('Freq (Hz)');
    axis([1e-3 1e2 -185 185])
    set(gca,'YTick',90*(-2:2))
    FillPage('t')
    IDfig
    

    %%   plot performance prediction from JUST the FIR and merge
    FIR_part_FR       = FIR_tf_FR .* merge_FIR_FR;
    IIR_part_noSTS_FR = 1 - merge_FIR_FR;
    total_simple_FR   = FIR_part_FR + IIR_part_noSTS_FR;
    
    %%
    
    figure;
    data_plot=[total_simple_FR   1-(total_simple_FR)];
    subplot(211);
    loglog(freq,abs(data_plot));
    legend('Overall Highpass','Complement');
    ylabel('Mag');
    grid on;
    hold on
    line([.1 1],1/10*[1 1])
    line([.1 1],1/30*[1 1])
    axis([1e-3 1e2 1e-4 10])
    
    subplot(212);
    semilogx(freq,angle(data_plot)/pi*180);
    grid on;
    ylabel('Phase (degree)');
    xlabel('Freq (Hz)');
    axis([1e-3 1e2 -185 185])
    set(gca,'YTick',90*(-2:2))
    FillPage('t')
    IDfig
    
    
%%  
    figure;
    data_plot=[FIR_tf_FR 1e9*VLF_highpass_w_AA_FR anti_alias_FR merge_FIR_FR 1e9*merge_IIR_FR  ]; 
    subplot(211);
    ll=loglog(freq,abs(data_plot));
    set(ll,'LineWidth',2);
    tt=legend('FIR','1e9*VFL\_highpass\_with\_AA ','anti\_alias','merge\_FIR','1e9*merge\_IIR',...
        'Location','south');
    set(tt,'FontSize',14);
    ylabel('Mag');
    grid on;
    title('Components of the FIR filter path')
    axis([1e-3 128 1e-6 100]);
    
    subplot(212);
    ll=semilogx(freq,angle(data_plot)/pi*180);
    set(ll,'LineWidth',2);
    grid on;
    ylabel('Phase (degree)');
    xlabel('Freq (Hz)');
    axis([1e-3 1e2 -185 185])
    set(gca,'YTick',90*(-2:2))
    IDfig
    FillPage('t')
    
    %%
    figure;
    data_plot=[tf_FIR_path_FR  tf_IIR_path_FR  tf_FIR_path_FR+tf_IIR_path_FR  ]; 
    subplot(211);
    ll = loglog(freq,abs(data_plot));
    set(ll,'LineWidth',2)
    title('Normalized Highpass filter')
    legend('FIR path','merge\_IIR', 'sum','Location','south');
    ylabel('Mag');
    grid on;
    axis([1e-3 1e2 1e-5 5])

    
    subplot(212);
    ll=semilogx(freq,angle(data_plot)/pi*180);
    set(ll,'LineWidth',2)
    grid on;
    ylabel('Phase (degree)');
    xlabel('Freq (Hz)');
    axis([1e-3 1e2 -185 185])
    set(gca,'YTick',90*(-2:2))
    FillPage('t')
    IDfig


end

%% push the input filters into nm output, instead of meter output

VLF_HP       = 1e9 * VLF_highpass_w_AA_d;  % output in nm
IIR_path     = 1e9 * merge_IIR_d;
FIR_rolloff  = merge_FIR_d;

quackcheck(VLF_HP)
quackcheck(IIR_path)
quackcheck(FIR_rolloff)



% make an empty version of the final structure
FIR_4k_filter_struct_2012_01_19 = ...
    struct('name',{},'value',{},'label',{},'subblock', {}, 'turnon', {});  % make an empty one

filter_turnon = 'immediate';

% and a partially completed one for each section
temp = struct('name','temp','value',0,'label','temp' ,...
    'subblock', 0, 'turnon', filter_turnon);
ii = 1;

% now fill out each one, and append it to the big structure

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
DOF = 'X';

temp.name     = ['xxx_ST1_SENSCOR_',DOF,'_FIR'];  
temp.subblock = 0;
temp.value    = VLF_HP;
temp.label    = 'LP&AA';
FIR_4k_filter_struct_2012_01_19(ii) = temp; ii = ii+1;

temp.name     = ['xxx_ST1_SENSCOR_',DOF,'_FIR'];  
temp.subblock = 2;
temp.value    = FIR_rolloff;
temp.label    = 'Blend_w_IIR';
FIR_4k_filter_struct_2012_01_19(ii) = temp; ii = ii+1;

temp.name     = ['xxx_ST1_SENSCOR_',DOF,'_IIRHP'];  
temp.subblock = 0;
temp.value    = IIR_path;
temp.label    = 'HP_Blend';
FIR_4k_filter_struct_2012_01_19(ii) = temp; ii = ii+1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
DOF = 'Y';

temp.name     = ['xxx_ST1_SENSCOR_',DOF,'_FIR'];  
temp.subblock = 0;
temp.value    = VLF_HP;
temp.label    = 'LP&AA';
FIR_4k_filter_struct_2012_01_19(ii) = temp; ii = ii+1;

temp.name     = ['xxx_ST1_SENSCOR_',DOF,'_FIR'];  
temp.subblock = 2;
temp.value    = FIR_rolloff;
temp.label    = 'Blend_w_IIR';
FIR_4k_filter_struct_2012_01_19(ii) = temp; ii = ii+1;

temp.name     = ['xxx_ST1_SENSCOR_',DOF,'_IIRHP'];  
temp.subblock = 0;
temp.value    = IIR_path;
temp.label    = 'HP_Blend';
FIR_4k_filter_struct_2012_01_19(ii) = temp; ii = ii+1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
DOF = 'Z';

temp.name     = ['xxx_ST1_SENSCOR_',DOF,'_FIR'];  
temp.subblock = 0;
temp.value    = VLF_HP;
temp.label    = 'LP&AA';
FIR_4k_filter_struct_2012_01_19(ii) = temp; ii = ii+1;

temp.name     = ['xxx_ST1_SENSCOR_',DOF,'_FIR'];  
temp.subblock = 2;
temp.value    = FIR_rolloff;
temp.label    = 'Blend_w_IIR';
FIR_4k_filter_struct_2012_01_19(ii) = temp; ii = ii+1;

temp.name     = ['xxx_ST1_SENSCOR_',DOF,'_IIRHP'];  
temp.subblock = 0;
temp.value    = IIR_path;
temp.label    = 'HP_Blend';
FIR_4k_filter_struct_2012_01_19(ii) = temp; ii = ii+1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

FIRnote1 = 'these are 4k the companion IIR filters for the FIR sensor correction';
FIRnote2 = 'Designed to run on the BSC ISI platform';
FIRnote3 = 'they already have the STS2 inversion in place';
FIRnote4 = 'They assume the STS-2 is calibrated to 1 cnt / (nm/sec)';
FIRnote5 = 'and assume the disp sensors at the add point are calibrated to 1 nanometer/count';
FIRnote6 = 'the match_x match_y and match_z filters should be 1';
FIRnote7 = ['created by ',mfilename,' on ',date,' by BTL, on his laptop'];
FIRnote8 = ['from the working directory ',pwd];

%save ISI_4k_FIR_companion_filters_20120119 FIR_4k_filter* FIRnote*
