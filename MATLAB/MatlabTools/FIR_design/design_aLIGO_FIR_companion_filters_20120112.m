function [merge_FIR_d, merge_IIR_d, VLF_FIR_HP_w_AA_d, normalized_VLF_FIR_HP, anti_alias_filter,CT_filters] = ...
    design_aLIGO_FIR_companion_filters_20120112(low_FIR_freq, merge_freq, notch_freq, Ts)
% design_aLIGO_FIR_companion_filters_20120112 designs the IIR filters needed to run the HEPI FIR filters
% based on design_flat_FIR_merge_ord_3TH.m by Wensheng Hua
% and design_IIR_filters_ord3_wSTSinv
%
% call as design_aLIGO_FIR_companion_filters_20120112(low_FIR_freq, merge_freq, notch_freq, Ts)
%
% low_FIR_freq is ??? now set to 0.006
% merge_freq   is the 'blend' between the FIR and IIR filter, now set to 0.4 Hz
% notch_freq   is the freq for the notches, now set to 2 Hz
%
% mods by BTL on May 28 2008 to make into 1 file, with comments
% 
% more mods by BTL on Jan 12, 2012 to make it 'better'
%
% also add an anti-alias filter for the 64 sample/sec downsampler!
% 
% added CT_filters as new output on June 4, 2012
% is a structure for the CT versions of the filters
% added so we can save them in the final data structure for later use
% if necessary


% this makes an AA filter with notches at 64 and 128 Hz,
% and 2 deg of phase distortion at 1 Hz.
anti_alias_filter = myellip(50.47, 4, 1, 28.1) * 10^(1/20);
figure
bode(anti_alias_filter)
title('Anti-alias filter for the 64 sample/sec downsampler in the FIR')


% this part rolls off the FIR filter above 1 Hz, and notches out the bumps
% at 2 Hz.
%[merge_FIR_c_temp,merge_IIR_c_temp]=combine_ord_3_notch_extra(merge_freq,notch_freq);

[merge_FIR_c_temp, merge_IIR_c_temp]=combine_ord_3_notch(merge_freq, notch_freq);

load aLIGO_calibrated_STS2_sensor_20120112 
% loads STS2_calibrated_position_response


merge_IIR_c = minreal(merge_IIR_c_temp / STS2_calibrated_position_response);
% cancel the 3 DC poles and zeros from the STS inverstion and HP filtering

merge_FIR_c  = merge_FIR_c_temp;

merge_FIR_d  = zpk(c2d(ss(merge_FIR_c),Ts,'tustin'));
merge_IIR_d  = zpk(c2d(ss(merge_IIR_c),Ts,'tustin'));

CT_filters.merge_FIR_CT = merge_FIR_c;
CT_filters.total_IIR_CT = merge_IIR_c;

% high_pass_filter for pre FIR filtering. 
% Takes care of the very low frequency part of the 
% transfer function, below 0.01 Hz normally.

%extra_hp = make_extra_hp;  % gives lots more low freq atten.


%VLHP_p1 = low_FIR_freq;
%VLHP_p2 = low_FIR_freq/3;
%VLHP_p3 = low_FIR_freq/10;

%VLHP_proto = zpk([0,0,0], -2*pi*[VLHP_p1, VLHP_p2, VLHP_p3], 1);
%new_VLHP_proto = zpk([0,0,0], -2*pi*[low_FIR_freq, (1/5)*low_FIR_freq*[1+1i, 1-1i]/sqrt(2)], 1);
% new one isn't really any better

% figure
% bode(old_VLHP_proto, new_VLHP_proto,1 - old_VLHP_proto,1 - new_VLHP_proto)
% legend('old','new','1-old','1-new')

%normalized_VLF_FIR_HP =  extra_hp * VLHP_proto;  %ie it goes to 1

%LP1 = myhpellip_z(.008, 2, 2, 20, 10) * 10^(2/20);
%[zz,pp,kk] = butter(4,2*pi*.002,'high','s');
%LP2 = zpk(zz,pp,kk);
%normalized_VLF_FIR_HP = LP1 * LP2;

% this is a new filter by BTL on Jan 20, 2012
% the proto_lowpass part helps give the whole final highpass part 
% better performance above 100 mHz.

proto_highpass = zpk([0 0 0 0],-2*pi*[low_FIR_freq*[1+1i 1-1i]/sqrt(2), (1/5)*low_FIR_freq*[1+1i, 1-1i]/sqrt(2)], 1);
proto_lowpass  = myellip_z2(.025,2,1,30,5)*10^(1/20);
norm_sum       = proto_lowpass + proto_highpass;

minreal_tol = 1e-3;
normalized_VLF_FIR_HP = minreal(proto_highpass/norm_sum, minreal_tol);

figure
bode(normalized_VLF_FIR_HP)
title('Normalized very low freq Highpass filter')


VLF_FIR_HP_c   = minreal(normalized_VLF_FIR_HP/STS2_calibrated_position_response, minreal_tol);

disp('The Very Low Freq Highpass is:')
VLF_FIR_HP_c

% now attach the Anti-alias filter...

VLF_FIR_HP_w_AA_c = VLF_FIR_HP_c * anti_alias_filter;
VLF_FIR_HP_w_AA_d = zpk(c2d(ss(VLF_FIR_HP_w_AA_c),Ts,'tustin'));

CT_filters.VLFHP_wAA_CT = VLF_FIR_HP_w_AA_c;

bode(VLF_FIR_HP_w_AA_c, VLF_FIR_HP_w_AA_d)
title('Final filter for bank 1 - VLF highpass, STS-2 inversion, and Anti-alias')
legend('cont time','discrete time')




function [ tf_lowpass, tf_highpass]=combine_ord_3_notch(comb_freq,notch_freq)
%combination filter with 3 order decay on both side.
% added a second notch on Jan 20 2012 - BTL
% pushed the corners closer together, and added a 4th zero to the highpass

[tf_low_temp, tf_high_temp] = combine_ord_3_BTL(comb_freq,10,20);


depth          = 40;
notch_filter   = notch_041703(notch_freq,depth);
lowpass_proto  = tf_low_temp * notch_filter;

extra_DC_zero  = zpk([0],-2*pi*comb_freq/20,1);
highpass_proto = tf_high_temp * extra_DC_zero;

tf_lowpass  = minreal( lowpass_proto / (lowpass_proto + highpass_proto));
tf_highpass = minreal(highpass_proto / (lowpass_proto + highpass_proto));


function notch_tf=notch_041703(notch_freq,depth)

w1 = notch_freq*2*pi;
w2 = 2 * w1;
%lambda=.07;  % this was the original width, it is very wide
lambda = 0.02;
%lambda=.01;

notch_1=tf([1 w1*lambda*2 w1^2],[1 w1*lambda*depth*2 w1^2]);
notch_2=tf([1 w2*lambda*2 w2^2],[1 w2*lambda*depth*2 w2^2]);
notch_tf = notch_1 * notch_2;



function [ tf_lowpass,tf_highpass]=combine_ord_3_BTL(comb_freq, sep1, sep2)
% makes a pair of 3rd order complementary filters
% the base low-pass has 1 pole at the comb_freq,
% a second pole at the comb_freq * sep1 (seperation to second pole)
% and a third at comb_freq * sep 2.
% eg a filter with a blend at 2 Hz, and additional poles at 6 Hz and 8 Hz
% would be combine_ord_3_BTL(2,3,4)
% the high pass filter has 3 zero at DC, 1 pole at the combine freq,
% and 2 more at comb/sep1 and comb/sep2.
% so it is symmetric with the low pass filter.
%combination filter with 3 order decay on both side.
%
% BTL May 28, 2008

LP_p1=comb_freq;
LP_p2=comb_freq*sep1;
LP_p3=comb_freq*sep2;

HP_p1=comb_freq;
HP_p2=comb_freq/sep1;
HP_p3=comb_freq/sep2;

lowpass_proto  = zpk([],      -2*pi*[LP_p1, LP_p2, LP_p3], (2*pi)^3 * LP_p1 * LP_p2 * LP_p3);
highpass_proto = zpk([0,0,0], -2*pi*[HP_p1, HP_p2, HP_p3], 1);

tf_lowpass  = minreal( lowpass_proto / (lowpass_proto + highpass_proto));
tf_highpass = minreal(highpass_proto / (lowpass_proto + highpass_proto));



function [extra_hp] = make_extra_hp()
% make a subfunction, because it gets called from 2 different places,
% and I'd like to keep the result the same.
% gives more low freq attenuation, to compensate for the STS-2 inversion.

extra_hp_ellip = myhpellip_z(.003, 2, 1, 15, 8)*10^(1/20);
extra_hp_zpk   = zpk(0, -2*pi*.001, 1);
extra_hp       = extra_hp_ellip * extra_hp_zpk;  % gives lots more low freq atten.


%%%%    Hua's original code  %%%
% [merge_FIR_c,merge_IIR_c]=combine_ord_3_th(merge_freq,notch_freq);
% merge_FIR_d=c2d(ss(merge_FIR_c),Ts,'tustin');
% 
% %load G:\data\data_combine_0811\process\standard_STS_tf;
% load standard_STS_tf;
% inv_merge_IIR_c_temp=merge_IIR_c/STS_c;
% 
% [num,den]=tfdata(inv_merge_IIR_c_temp);
% inv_merge_IIR_c=tf(num{1}(1:length(num{1})-3),den{1}(1:length(den{1})-3));
% inv_merge_IIR_d=c2d(ss(inv_merge_IIR_c),Ts,'tustin');
% 
% %high_pass_filter for pre FIR filtering. 
% [temp,low_FIR_c_temp]=combine_ord_3(low_FIR_freq);
% inv_low_FIR_c_temp=low_FIR_c_temp/STS_c;
% [num,den]=tfdata(inv_low_FIR_c_temp);
% inv_low_FIR_c=tf(num{1}(1:length(num{1})-3),den{1}(1:length(den{1})-3));
% inv_low_FIR_d=c2d(ss(inv_low_FIR_c),Ts,'tustin');

