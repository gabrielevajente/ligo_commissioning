% test autoquack.m
% BTL July 2015
% quick example of autoquack to demo the function
% SVN $Id$

clear
close all

commandwindow;   %bring command window to the front

%%
% get_filenames should be used for a local model, 
% e.g. s1isiitmx at stanford, or h1isibs at hanford

[ITMX_filenames, ~, ~, rate] = get_filenames('h1isiitmx');
Ts = 1/rate;

ff = logspace(-1,4, 1000);
ww = 2*pi*ff;

%% make a simple fiter
filt1_CT  = zpk([], -2*pi*2, 2*pi*2);
filt1_DT  = zpk(c2d(ss(filt1_CT),Ts,'tustin'));

quackcheck(filt1_DT);

filt2_CT  = tf(2);
filt2_DT  = zpk(c2d(ss(filt2_CT),Ts,'tustin'));

quackcheck(filt2_DT);

filt3_CT  = myellip_z2(22,3, 3, 30, 100);
filt3_DT  = zpk(c2d(ss(filt3_CT),Ts,'tustin'));

filt3_CT_FR = squeeze(freqresp(filt3_CT, ww));
filt3_DT_FR = squeeze(freqresp(filt3_DT, ww));

quackcheck(filt3_DT);

% this filter has a right-half-plane pole! BAD EVIL!
% autoquack will install it, and foton will remove it.
% i.e.  example of a filter where the before/ after 
% of foton -c are dramatically different - BTL July 2015

filt_BAD_CT  = zpk([], 2*pi*5, 1);
filt_BAD_DT  = zpk(c2d(ss(filt_BAD_CT),Ts,'tustin'));

%%
figure
subplot(211)
ll = loglog(ff, abs(filt3_CT_FR),'k',...
    ff, abs(filt3_DT_FR), 'r--');
set(ll,'LineWidth',2);
grid on
legend('cont time','Discrete time')
title('example filter 3')
axis([ .1 3000 1e-4 2])

subplot(212)
ll = semilogx(ff, 180/pi*angle(filt3_CT_FR),'k',...
    ff, 180/pi*angle(filt3_DT_FR), 'r--');
set(ll,'LineWidth',2);
grid on
title('example filter 3')
axis([ .1 3000 -185 185])
set(gca,'YTick',45*(-4:4));

FillPage('t')
IDfig;

%%
test_filter4(1).name     = 'ITMX_TEST1';
test_filter4(1).value    = filt1_DT;
test_filter4(1).label    = 'test0-ramp';
test_filter4(1).subblock = 0;
test_filter4(1).turnon   = 'ramp';
test_filter4(1).ramptime = 10;

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


autoquack(ITMX_filenames.foton,test_filter4)
%%

autoquack_conversion_check(ITMX_filenames.foton,test_filter4, 'verbose')
%%
test_filter_BAD          = test_filter4;
test_filter_BAD(3).value = filt_BAD_DT;

<<<<<<< .mine
% autoquack(ITMX_filenames.foton,test_filter_BAD)
=======
%autoquack(ITMX_filenames.foton,test_filter_BAD)
>>>>>>> .r8880
