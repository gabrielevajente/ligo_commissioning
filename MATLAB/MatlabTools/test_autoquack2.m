% test autoquack.m

clear
close all

commandwindow;   %bring command window to the front

%%
filenames.foton = '/opt/rtcds/stn/s1/chans/S1ISITEST.txt';
Ts = 1/4096;

filename_ITMX.foton = '/opt/rtcds/stn/s1/chans/S1ISIITMX.txt';

%% make a simple fiter
filt1_CT  = zpk([], -2*pi*2, 2*pi*2);
filt1_DT  = zpk(c2d(ss(filt1_CT),Ts,'tustin'));

quackcheck(filt1_DT);

filt2_CT  = tf(2);
filt2_DT  = zpk(c2d(ss(filt2_CT),Ts,'tustin'));

quackcheck(filt2_DT);

filt3_CT  = myellip_z2(22,3, 3, 30, 100);
filt3_DT  = zpk(c2d(ss(filt3_CT),Ts,'tustin'));

% this filter has a right-half-plane pole! BAD EVIL!
filt_BAD_CT  = zpk([], 2*pi*5, 1);
filt_BAD_DT  = zpk(c2d(ss(filt_BAD_CT),Ts,'tustin'));

%%

% this one is OK
test_filter1.name     = 'ITMX_TEST1';
test_filter1.value    = filt1_DT;
test_filter1.label    = 'test1';
test_filter1.subblock = 1;
test_filter1.turnon   = 'immediate';

autoquack(filename_ITMX.foton,test_filter1)

%% this should give a 'no module' error
test_filter2.name     = 'ITMX_SU_WIT_STS_Z_MISSSSPELLED';
test_filter2.value    = filt1_DT;
test_filter2.label    = 'test1';
test_filter2.subblock = 1;
test_filter2.turnon   = 'immediate';

%% ok for now
test_filter3.name     = 'ITMX_TEST1';
test_filter3.value    = filt2_DT;
test_filter3.label    = 'test-ramp';
test_filter3.subblock = 1;
test_filter3.turnon   = 'ramp';
test_filter3.ramptime = 10;


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


autoquack(filename_ITMX.foton,test_filter4)

%%
test_filter_BAD          = test_filter4;
test_filter_BAD(3).value = filt_BAD_DT;

autoquack(filename_ITMX.foton,test_filter_BAD)

%% use a bad ramptime
test_filter6.name     = 'ITMX_TEST1';
test_filter6.value    = filt2_DT;
test_filter6.label    = 'test-ramp';
test_filter6.subblock = 0;
test_filter6.turnon   = 'ramp';
test_filter6.ramptime = 1000;

%% use a bad ramptime
test_filter7.name     = 'ITMX_TEST1';
test_filter7.value    = filt2_DT;
test_filter7.label    = 'test-ramp';
test_filter7.subblock = 0;
test_filter7.turnon   = 'ramp';
test_filter7.ramptime = -12;

%% forget to define a field (label)
test_filter8.name     = 'ITMX_TEST1';
test_filter8.value    = filt2_DT;
test_filter8.subblock = 0;

%% put filter into field not at the end
test_filter9.name     = 'ITMX_CDMON_POD1_H_CS_I';
test_filter9.value    = filt2_DT;
test_filter9.label    = 'test-ramp';
test_filter9.subblock = 1;
test_filter9.turnon   = 'ramp';
test_filter9.ramptime = 10;

%%

%autoquack(filenames.foton, test_filter1);
%autoquack(filenames.foton, test_filter2);
%autoquack(filenames.foton, test_filter3);

disp('running quack_to_rule_them_all.m with ramp time selected')
[~,s] = quack_to_rule_them_all(test_filter3.value, 4096, 'D', ...
    test_filter3.name, test_filter3.label, test_filter3.subblock, ...
    test_filter3.turnon, test_filter3.ramptime);

disp(s)

disp(' ' )
disp('running quack_to_rule_them_all.m with no ramp time selected')

[~,s] = quack_to_rule_them_all(test_filter3.value, 4096, 'D', ...
    test_filter3.name, test_filter3.label, test_filter3.subblock, ...
    test_filter3.turnon);

disp(s)

simple_filt_DT = zpk(c2d(ss(tf(2)),1/4096,'tustin'));
[~,s] = quack_to_rule_them_all(simple_filt_DT, 4096, 'D', 'ITMX_TEST1','gain2',9,'ramp');
disp(s)

write_filter_coe_nodesignstring(filename_ITMX.foton,s);

%%
help autoquack

%% does an old one still work?
autoquack(filename_ITMX.foton, test_filter1)
system(['tail --lines=20 ',filename_ITMX.foton]);


%% does it work at all for a ramp?
autoquack(filename_ITMX.foton, test_filter3)
system(['tail --lines=20 ',filename_ITMX.foton]);

% warning - cheeseball alert!
%   the tail only works because the TEST1 is the last filter 

%% does it work when the 'ramptime' field is not defined?

autoquack(filename_ITMX.foton, test_filter4)
system(['tail --lines=20 ',filename_ITMX.foton]);

% warning - cheeseball alert!
%   the tail only works because the TEST1 is the last filter 

%% does it work when ramptime is defined a few places?
autoquack(filename_ITMX.foton, test_filter5)
system(['tail --lines=20 ',filename_ITMX.foton]);

% warning - cheeseball alert!
%   the tail only works because the TEST1 is the last filter 

%% does it work when ramptime is too big?  % should give warning and set to 5 sec.
autoquack(filename_ITMX.foton, test_filter6)
system(['tail --lines=20 ',filename_ITMX.foton]);

%% does it work when ramptime is too small?  % should give warning and set to 5 sec.
autoquack(filename_ITMX.foton, test_filter7)
system(['tail --lines=20 ',filename_ITMX.foton]);

%% check error if 'label' is not defined
autoquack(filename_ITMX.foton, test_filter8)

%% check OK for filter at the top of the list
autoquack(filename_ITMX.foton, test_filter9)
system(['grep -B 2 -A 10 "### ITMX_CDMON_POD1_H_CS_I" ', filename_ITMX.foton]);

