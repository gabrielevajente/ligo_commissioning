% test the autoquack_converstion_tester

clear
close all

%%
%foton_file = '/Users/BTL/Brians_files/CDS/cds_user_apps/trunk/isi/s1/filterfiles/S1ISIITMX.txt';
foton_file = '/opt/rtcds/userapps/trunk/isi/s1/filterfiles/S1ISIITMX.txt';



%% make a simple fiter
Ts = 1/4096;

filt1_CT  = zpk([], -2*pi*2, 2*pi*2);
filt1_DT  = zpk(c2d(ss(filt1_CT),Ts,'tustin'));


filt2_CT  = tf(2);
filt2_DT  = zpk(c2d(ss(filt2_CT),Ts,'tustin'));

filt3_CT  = myellip_z2(22,3, 3, 30, 100);
filt3_DT  = zpk(c2d(ss(filt3_CT),Ts,'tustin'));

%%


test_filter4(1).name     = 'ITMX_TEST1';
test_filter4(1).value    = filt1_DT;
test_filter4(1).label    = 'test0-ramp';
test_filter4(1).subblock = 0;
test_filter4(1).turnon   = 'ramp';

test_filter4(2).name     = 'ITMX_TEST1';
test_filter4(2).value    = filt2_DT;
test_filter4(2).label    = 'test1';
test_filter4(2).subblock = 1;
test_filter4(2).turnon   = 'immediate';

test_filter4(3).name     = 'ITMX_TEST1';
test_filter4(3).value    = filt3_DT;
test_filter4(3).label    = 'test2';
test_filter4(3).subblock = 2;
test_filter4(3).turnon   = 'zerocrossing';


%%
autoquack_conversion_check(foton_file, test_filter4,'verbose');

%%
test_filter_bad = test_filter4;
test_filter_bad(1).value =  filt2_DT;

autoquack_conversion_check(foton_file, test_filter_bad);


