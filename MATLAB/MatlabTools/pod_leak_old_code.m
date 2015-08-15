%% load the data, Time, Argon and Neon
clear all
% Bring in data from foo.txt
% Data seperated by commas
delimiter = ',';

% how many lines until the header is over this will change depending on what
% settings are used during the P v T scan.
headerlines = 25;

% Defines the data set name. importgas.data is in columns. 
% Time in seconds is the first column. AMUs are subsequent columns.
filename = input('Enter name of data file:  ', 's');
importgas = importdata(filename, delimiter, headerlines);

% x axis set by the first column
Time = importgas.data(:,1);

% y axis values set by subsequent columns 
Neon = importgas.data(:,2);

Neon22 = importgas.data(:,3);

Argon = importgas.data(:,4);


%% Find max of calibrated leak

CalLeak = 4.49e-9; % value of calibrated leak in torr-l/sec

srate = Time(2); % first value is 0 the second should be the sample rate

% this should give the value and the index of the max in Neon which is the
% calibrated leak, it ignores the first 20 samples. This will breakdown if
% there are more than one large peak in the data. This could be an issue
% with large pod leaks and this may need to be switched to something more
% similar to the pod accumulation

[Ncal, Ncali] = max(Neon(20:end)); 
                                                                      
% Reset the index value for Ncali. This should be tied to the 
% max(Neon(blah:end)) value

Ncali = Ncali+19;

[Ncalbg, Ncalbgi] = min(Neon(Ncali-15:Ncali));  % this gives the background 
                                                % before 

Ncalbgi = Ncalbgi+Ncali-16; % reset index

CalibratedLeakAmps = Ncal - Ncalbg; % this will be the value in Amps 
                                    % corresponding to the torr-l/s value
                                    
%% User input time of valve opening after accumulation

% Since the RGA displays time in h:m:s this should make it easier to
% coordinate the exported time with the user
fprintf...
('Give me the time when valve was opened after pod leak accumulation. \n');

fprintf('I will ask for hour, minute and second in that order, \n')
fprintf('enter 0 if necessary. \n')
hour = input(' Hour:');
minute = input(' Minute:');
second = input(' Second:');

t1 = hour*3600 + minute*60 + second; % time to look for Neon pod leak


% two lines of code and half an hour later, output!
t1str = sprintf(' %G seconds', t1);
disp(t1str)

%% We'll be super conservative and pick min and max of data
% This may now be antiquated but we'll still need the parts dealing with
% picking of the max and min values

% create an index value based on time entered divided by sample rate
indexleak = round(t1/srate);

% Since the pod accumulation won't have a clearly defined peak (most of
% the time) picking a max and min at the valve open time is a good way to
% get a positive "signal" even if it's an exagerated value.

% This looks for a max value around 20 indexes of the input
[PodM,PodMi] = max(Neon(indexleak:indexleak+20));
PodMi = indexleak-1+PodMi;
[Podbg,Podbgi] = min(Neon(PodMi-15:PodMi));
Podbgi = Podbgi+PodMi-16; % index reset

% PodLeakAmps = PodM-Podbg; % this is the value in amps of the pod leak

% Now use the calibrated leak to get the pod leak in the right units
% Keep in mind that the cal leak also has the pod leak in it

% PodLeak = PodLeakAmps/(CalibratedLeakAmps-PodLeakAmps)*CalLeak;

% str = sprintf('The max pod leak value is: %s torr-liters/sec', PodLeak);
% disp(str)


%% Calculate error bars

% we want to look at data before the calibrated leak to see noise stats
% 
% errordata = Neon(Ncalbgi-50:Ncalbgi);
% meanerr = mean(errordata);
% err = std(errordata);
% 
% error = err/(CalibratedLeakAmps-err)*CalLeak*2; % times 2 since we're 
%                                                 % taking min and max
% 
% str2 = sprintf('The error on this number is %s torr-liter/sec', error);
% disp(str2)

%% best fit
% how many index points to calculate out to for the curve fit.
ptstop = 40;
% lsqcurve fit doesn't like small numbers hence the *1e14, this doesn't
% matter so much because the leak is a ratio of the CalLeak value
fitne = Neon(Ncali:Ncali+ptstop)*1e14;
fitt = Time(Ncali:Ncali+ptstop)-Time(Ncali);
% The time constant x(3) will apply for both the cal+pod leak and the pod
% leak. lsqcurvefit will look for the exponential x values @(blah) are the
% variable for the function. 
options = optimset('Display','off');
x = lsqcurvefit(@(x,fitt) x(1)+x(2)*exp(-fitt*x(3)),[0 1.2 1], fitt,...
    fitne,[0 0 0],[100 100 100],options);

fittedexp = x(1)+x(2)*exp(-fitt*x(3));

% This does the same for the pod leak, based off the user input time and
% max value of 20 indexes surrounding
fitbg = Neon(PodMi:PodMi+ptstop)*1e14;
fittbg = Time(PodMi:PodMi+ptstop)-Time(PodMi);

% x(3) is used to keep the time constant the same as the calibrated + pod
% leak
options = optimset('Display','off');
y = lsqcurvefit(@(y,fittbg) y(1)+y(2)*exp(-fittbg*x(3)),[0 1.2], fittbg,...
    fitbg,[0 0],[100 100],options);
fittedbgexp = y(1)+y(2)*exp(-fittbg*x(3));

%% Area under curve

% integrating the exponential fit above the background of both the pod and
% calibrated + pod leak.
areacal = -x(2)/x(3)*(exp(-fitt(end)*x(3))-1);
areapod = -y(2)/x(3)*(exp(-fittbg(end)*x(3))-1);


% Now use the calibrated leak to get the pod leak in the right units
% Keep in mind that the cal leak also has the pod leak in it

PodLeak2 = areapod/(areacal-areapod)*CalLeak;

str = sprintf('The max pod leak value is: %s torr-liters/sec', PodLeak2);
disp(str)

%% Plot stuff to check

figure(1)
subplot(411)
graph1 = semilogy(Time, Neon, Time, Argon, Time, Neon22);
set(graph1(1),'DisplayName','Neon 20','Color','red');
set(graph1(2),'DisplayName','Argon','Color','blue');
set(graph1(3),'DisplayName','Neon 22','Color','green');
title('RGA signals');
xlabel('Time (s)');
ylabel('Amps (faraday)');
legend('show');
grid

subplot(412)
plot(Time(Ncali-10:Ncali+ptstop+5),Neon(Ncali-10:Ncali+ptstop+5),'r.-',...
         Time(Ncali),Neon(Ncali),'bo',Time(Ncali+ptstop),...
         Neon(Ncali+ptstop),'bo')
axis tight
title('Neon Calibrated Leak Zoom In')
xlabel('Time (s)')
ylabel('Amps (faraday)')
grid

% subplot(212)
% plot(Time(PodMi-20:PodMi+30),Neon(PodMi-20:PodMi+30),'g.-',...
%         Time(PodMi),Neon(PodMi),'ro',Time(Podbgi),Neon(Podbgi),'ro',...
%         Time(indexleak),Neon(indexleak),'bo')
% grid
% axis tight
% title('Neon Pod Leak Zoom In')
% xlabel('Time(s)')
% ylabel('Neon RGA reading(Amps)')
% legend('Neon data','Max','Min','Inputed time')
% ylim([Neon(Ncalbgi) Neon(Ncali)]) % scale both plots the same
% 

subplot(413)
plot(fitt,fitne,'bo',fitt,fittedexp,'r-')
axis tight
title('Neon Calibration + Pod leak fit')
xlabel('Time (s)')
ylabel('Amps (faraday)')
grid

subplot(414)
plot(fittbg,fitbg,'bo',fittbg,fittedbgexp,'r-')
axis tight
title('Neon Pod leak fit')
xlabel('Time (s)')
ylabel('Amps (faraday)')
grid

%% Error calculation
% 
% errorcal = sqrt(sum(abs(fitne.^2-fittedexp.^2))/40)*1e-14
% errorpod = sqrt(sum(abs(fitbg.^2-fittedbgexp.^2))/40)*1e-14
