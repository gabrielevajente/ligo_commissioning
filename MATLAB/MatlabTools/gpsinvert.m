% GPSinvert just runs the ligotool tconvert on the 
% gps second
%
% with no string it returns the current date/time
%
% for tconvert help do gpsinvert(' ')

function OUT = gpsinvert(gpsseconds)

gpsseconds2 = num2str(gpsseconds);

[a,b] = unix([ ' ' getenv('LIGOTOOLS') '/bin/tconvert -l -f"%D %H:%M:%S" ' gpsseconds2 ]);

OUT = b;%str2num(b);

return;