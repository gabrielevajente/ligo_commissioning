function Fs = get_sample_freq(filename)
%function Fs = get_sample_freq(filename)
%
% This function returns the sampling frequency of filter_name as found in
% the foton filter file, filename
%
% filename is the full path, e.g.
% '/opt/rtcds/stn/s1/chans/S1ISIITMX.txt'
%
%
% If the filtername cannot be found, Fs will be 0
%
%  TSC June 2007
%
% $Id: get_sample_freq.m 2440 2011-04-21 06:32:55Z brian.lantz@LIGO.ORG $
%
% BTL mod on April 20, 2011 to work with the foton file format 
% as of april 20, 2011
% this format has the filter rate defined exactly once, after the list of
% modules, in a line which looks like:
% #
% # SAMPLING RATE 2048
% #


fid = fopen(filename,'r');

if fid == -1
    error(['Could not open specified file ',filename])
end

% look for the line which starts like this:
header_pat = '# SAMPLING';

% it seems that the Fs is no longer included in the sample rate defn.
% make a better regexp pattern - BTL April 20, 2011
% now we will just look for the line '# SAMPLING RATE xxxx'
% and get the last set of digits from that line
regexp_pat = '\d+';

% Read in the whole text.  This is a hack.  If you know a better way,
% please email tarm@stanford.edu
complete_lines = textscan(fid,'%s','Delimiter','\n');
complete_lines = complete_lines{1};
fclose(fid);


Fs = 0;

i=0;
while i < length(complete_lines)
    i=i+1;
    if (strncmp(header_pat,complete_lines(i),length(header_pat)))
        this_line = complete_lines{i};
        digit_start = regexp(this_line,regexp_pat);
        rate_str = this_line(digit_start(end):end); % from the start of the last digit to the end of the line
        Fs = str2num(rate_str);
    end
end

if isempty(Fs)
    Fs = 0;
    warning(['Sampling freq not found in ',filename,'.  Reset to 0.'])
end


