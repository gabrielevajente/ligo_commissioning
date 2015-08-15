function [pressure] = gs13Presstest(startTime,measDuration,activeChans,printFig)
%%
% startime given in GPS time
% measDuration in s
% Ex:
% activeChans= {'G1:HUD-PRESS_GEO_H1_DAQ';...
%               'G1:HUD-PRESS_GEO_V2_DAQ';}
%or
% activeChans= {'G1:HUD-PRESS_GEO_H1_DAQ,mean';...
%               'G1:HUD-PRESS_GEO_V2_DAQ.mean';}

%if printFig=0, figure is not saved; if printFig=1, figure is saved

%% Settings
svnHome = '/opt/svncommon/seisvn/seismic/';
resultsDir = [svnHome 'Common/Data/Pressure_Plots/'];

        
%% Get Data   

%Option 1: raw data 
%pressure = get_data(activeChans,'raw',startTime,measDuration);

%Option2: lower resolution
pressure=get_data(activeChans,'minute',startTime,measDuration);
totTime = startTime + measDuration;

timeRange = [startTime totTime];
timeSpan = linspace(startTime,startTime+measDuration,length(pressure(1).data));
magRange = [2*10^4 3*10^4];

%% Put data in a matrix

Pressure=[];

for chan=1:length(activeChans)
    
%Option 1: reduce data size
% fs=round(length(rawData(1).data)/10);
% press=1:fs:length(rawData(1).data);
% Pressure(chan,:)=pressure(chan).data(press);
% timeSpan=timeSpan(press);

%Option 2:
Pressure(chan,:)=pressure(chan).data;
name_chans(chan,:)=activeChans{chan};
end

%% Plotting
Pressure=abs(Pressure);% this is to correct the minus sign from the electronics

plot(timeSpan,Pressure);

legend(name_chans(:,25:26));

start_=gpsinvert(startTime);
start_=[start_(1:2) start_(4:5) start_(7:8)];
end_=gpsinvert(totTime);
end_=[end_(1:2) end_(4:5) end_(7:8)];
xlim(timeRange)
ylim(magRange)


temp=gpsinvert(startTime);
ticks_date=temp(1:17);
for i=1:10
    temp=gpsinvert(startTime+i*measDuration/10);
    ticks_date=[ticks_date;temp(1:17)];
end
temp=gpsinvert(totTime);
ticks_date=[ticks_date;temp(1:17)];
set(gca,'XTick',startTime:(measDuration/10):totTime);
set(gca,'XTickLabel',{ticks_date(1,:),...
    ticks_date(2,:),...
    ticks_date(3,:),...
    ticks_date(4,:),...
    ticks_date(5,:),...   
    ticks_date(6,:),...
    ticks_date(7,:),...
    ticks_date(8,:),...
    ticks_date(9,:),...    
    ticks_date(10,:),...
    ticks_date(11,:)});
xticklabel_rotate([],15);

title({'Pressure Sensor Data from',ticks_date(1,:),'to',ticks_date(11,:)},'FontSize',14);

grid on
FillPage('w')
IDfig

ylabel('Magnitude (Counts)')


%% Saving
if printFig
    Name=[];
    for chan=1:length(activeChans)
        Name=[Name name_chans(chan,25:26)];
    end
    saveas(gcf,[resultsDir 'Pressure_' start_ '_to_' end_ '_' Name '.pdf'])
end



    
    