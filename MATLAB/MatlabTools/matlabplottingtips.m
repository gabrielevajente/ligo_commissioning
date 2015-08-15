close all
clear all
clc

%%
printFigs = false;
dataDir = '/Users/kissel/Desktop/scratch/';

howMany = pi; % used in awesomeness step 16 later

%% Create some toy data
% Random DC offset [V]
V0_V  = [1000.2;...
           20.3;...
           20.3;...
            0.004];
   
% Random AC signal, Vac [V], at frequency, f [Hz]
Vac_V = [200.0;...
           2.00;...
          10.0;...
           0.0015];
f_Hz   = [2.9e6;...
          5.1e6;...
          0.5e6;...
          1.44e6];

% Time vector [sec]
time_sec = 1e-7:5e-8:5.1e-6; %

% Make the time series
for iDataSet = 1:length(V0_V)
    data(iDataSet).ts_V = V0_V(iDataSet) + Vac_V(iDataSet) * sin(2*pi*f_Hz(iDataSet)*time_sec); %#ok<*SAGROW>
end



%% Get to the plotting!

% Demonstrate how lame a default Matlab plot is
figure(1)
semilogy(time_sec,data(1).ts_V,time_sec,data(2).ts_V,time_sec,data(3).ts_V,time_sec,data(4).ts_V);

% Add awesomeness
figure(2)
plotHandle = semilogy(time_sec*1e6,...                                           % (1) time_sec is multiplied by 1e6 (i.e. turned into microseconds),
                      [data(1).ts_V(:); data(2).ts_V(:); data(3).ts_V(:);...     % to get it display without the tiny, often-not-visible little 10^-6 
                         data(4).ts_V(:)]);                                      % in the corner of the x axis. (:) forces data into columns.
                                                                                 % (2) The data vectors are collected in an array, so that you don't 
                                                                                 % have to type the x variable every time
                                                                                 % (3) The plot "handle" is absorbed by the variable plotHandle, for 
                                                                                 % use later                               
xlim([0.1 5.1])                                                                  % (4) Force the x limits to the start and end of your data
ylim([1e-3 1e4])                                                                 % (5) Same for y. Note, you can do this in one line with "axis([xMin xMax yMin yMax])"
set(plotHandle(1),'LineWidth',4,'Color',[0.5 0.8 0.0])                           % (6) Use plotHandle to change the line thickness and color. You can 
                                                                                 % specify a particular line (where the element number of the given 
                                                                                 % data trace that is modified is defined by the order you put called
                                                                                 % it in semilogy. Or, without calling any specific element applies the
                                                                                 % modification to all traces. You should AT LEAST, always set your 
                                                                                 % LineWidths to thickness of 2, i.e.
                                                                                 % set(plotHandle,'LineWidth',2)
                                                                                 % (7) You can change the color of your line to whatever you want with
                                                                                 % and array of numbers as shown, in order [red green blue], from 0 to 1
set(plotHandle(2),'Color','black','LineStyle','--')                              % (8) Or, there are some basic, predefined colors that matlab knows about
                                                                                 % (9) LineStyle can change ... the line style. DON'T ever use ':', it sucks 
                                                                                 % because you can't see it in the pdf, no matter how thick you make the line.
                                                                                 % Stick to '-','--','-.' OR
set(plotHandle(4),'Marker','s','MarkerSize',4,'LineStyle','none')                % (10) You can change to markers, of varying sizes, with or without 
                                                                                 % a line connecting the points.
                                                                                 % Type "doc LineSpec" in the command line to see all options.
grid on                                                                          % (11) Turn the grid on. You should ALWAYS turn this on
set(gca,'XTick',0.1:0.5:5.1)                                                     % (12) Matlab sucks at putting tick marks where they're useful. You can 
                                                                                 % force it to put them whereever you like, i.e. in linear spacing or
set(gca,'YTick',10.^(-3:4))                                                      % (13) in log spacing. They'll look fine on your .fig in matlab, but the 
                                                                                 % printed .pdf will leave them sucky unless you force it as shown
set(gca,'FontSize',20)                                                           % (14) All fonts should be AT LEAST size 16 to be readable in .pdf
title({'Plot Awesomeness 2012-08-08';...                                         % (15) Title can accept cells! Sweet!
      ['Subtitle with ' num2str(howMany,3) ' Smaller Details']})                 % (16) Useful when you want to include calculated numbers somewhere. The second
                                                                                 % argument given in num2str determines the precision to which it's displayed
xlabel('Time [\musec]')                                                          % (17) Matlab will use LaTeX commands in your labels! Sweet!
ylabel('Signal [V]')                                                   
legHandle = legend('Data 1','Data 2','Data 3','Data_4',...                       % (18) Grab the handle of the legend too, for later              
                   'Location','West');                                           % (19) And you can define the best location for the legend with the cardinal
                                                                                 % directions, 'East','NorthWest', etc. 'NorthEast' is the default
set(legHandle,'FontSize',12)                                                     % (20) Sometimes you need to make the legend a little smaller if it 
                                                                                 % gets in the way of the data. But don't go too small!!
set(legHandle,'Interpreter','None')                                              % (21) Sometimes, say if you're including a channel name that has
                                                                                 % underscores, you don't want matlab to turn it into subscript
                                                                                 % then this is how you turn the LaTeX interpreter off.
     

%% For the record,
% You can do steps (6), (11), and (14) by adding these commands to your startup.m file
% set(0,'DefaultLineLineWidth',2) % is step (6)
% set(0,'DefaultAxesFontSize',16) % is step (14)
% set(0,'DefaultAxesXGrid','on')  % is step (11)
% set(0,'DefaultAxesYGrid','on')  %    |
% set(0,'DefaultAxesZGrid','on')  %    v

% I've commented it out, because once you run it once in a given matlab
% session, it sticks, so I wouldn't be able to demostrate all of the above
% explicitly. Note that my matlab session is using those, which is why the
% even the 'toyplot_default.pdf' I show has some gridlines, the font size
% at 16, and line thickness of 2.

% Also, you combine a bunch of the steps shown above, as long as they're
% calling the same handle, e.g. (12), (13), and (14) can be combined into
% set(gca,'XTick',0.1:0.5:5.1,'YTick',10.^(-3:4),'FontSize',20)

%% Print them as .pdfs to show the difference in the final result
if printFigs
    figure(1)
    saveas(gcf,[dataDir 'toyplot_default.pdf'])
    
    figure(2)
    FillPage('w')                                                           % (22) This separate function forces matlab to print to 
                                                                            % fill up a full 8.5 x 11 sheet (basically getting rid of)
                                                                            % the wasted negative space
    IDfig(', J. Kissel')                                                    % (23) This separate function sticks a little string of text
                                                                            % on the bottom right-hand corner of the plot which tells you
                                                                            % the date the plot was made and what script made it, and then
                                                                            % anything else you like as in input argument (I like to put 
                                                                            % the author of the data there)
    saveas(gcf,[dataDir 'toyplot_awesome.pdf'])                             % FillPage and IDfig should just always be in your path, so 
                                                                            % you can call them any time you print a figure EVER.
end

          
          