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

%%

% this one is OK
test_filter1.name     = 'ITMX_TEST1';
test_filter1.value    = filt1_DT;
test_filter1.label    = 'test1';
test_filter1.subblock = 1;
test_filter1.turnon   = 'immediate';

% this should give a 'no module' error
test_filter2.name     = 'ITMX_SU_WIT_STS_Z_MISSPELLED';
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
test_filter4(1).value    = filt2_DT;
test_filter4(1).label    = 'test0-ramp';
test_filter4(1).subblock = 0;
test_filter4(1).turnon   = 'ramp';

test_filter4(2).name     = 'ITMX_TEST1';
test_filter4(2).value    = filt1_DT;
test_filter4(2).label    = 'test1';
test_filter4(2).subblock = 1;
test_filter4(2).turnon   = 'immediate';

test_filter4(3).name     = 'ITMX_TEST1';
test_filter4(3).value    = filt1_DT;
test_filter4(3).label    = 'test2';
test_filter4(3).subblock = 2;
test_filter4(3).turnon   = 'zerocrossing';

%%
test_filter5(1).name     = 'ITMX_TEST1';
test_filter5(1).value    = filt2_DT;
test_filter5(1).label    = 'test0-ramp';
test_filter5(1).subblock = 0;
test_filter5(1).turnon   = 'ramp';
test_filter5(1).ramptime = 10;

test_filter5(2).name     = 'ITMX_TEST1';
test_filter5(2).value    = filt1_DT;
test_filter5(2).label    = 'test1';
test_filter5(2).subblock = 1;
test_filter5(2).turnon   = 'immediate';

test_filter5(3).name     = 'ITMX_TEST1';
test_filter5(3).value    = filt1_DT;
test_filter5(3).label    = 'test2';
test_filter5(3).subblock = 2;
test_filter5(3).turnon   = 'zerocrossing';

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

%% does it work when ramptime is too big?
autoquack(filename_ITMX.foton, test_filter6)
system(['tail --lines=20 ',filename_ITMX.foton]);

%% does it work when ramptime is too small?
autoquack(filename_ITMX.foton, test_filter7)
system(['tail --lines=20 ',filename_ITMX.foton]);

%% check error if 'label' is not defined
autoquack(filename_ITMX.foton, test_filter8)

%%
autoquack('/opt/rtcds/stn/s1/chans/S1ISIITMX_bad.txt', test_filter8)
