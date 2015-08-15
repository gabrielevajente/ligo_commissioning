function chans = get_chan_info(filename)
% function chan_names = get_chan_names(filename)
%
% This function finds the DAQ channel names and numbers from a .par or .ini
% file.
% 
% filename should be a string with either the absolute or relative path 
% to the directory containing the par file.  It should have a 
% trailing slash.  For example:
%               
%  '/opt/rtcds/stn/s1/target/s1isiitmx/param/tpchn_s1isiitmx.par'
%
%   the function get_filenames can calculate this for you.
%
% chan_names is a cell array where each element is a string with a channel
% name from the ini file.  To reference one name, use curly braces as in  
%  >> for i = 1:length(chan_names)
%  >      disp(chan_names{i})
%  >  end
%
% $Id: get_chan_info_RCG1.m 2447 2011-04-21 19:05:58Z brian.lantz@LIGO.ORG $

fid = fopen(filename,'r');

if fid == -1
    error(['Could not open specified file ',filename])
end

complete_lines = textscan(fid,'%s','Delimiter','\n');
complete_lines = complete_lines{1};

fclose(fid);

chans.names = {};
i = 1;

% skip ahead to where the channel names and numbers start
% while ~isempty(complete_lines{i})
%    i = i + 1;
% end

j = 0;
while i < length(complete_lines)
    cur = complete_lines{i};
    
    % if the line has the format [xx:xx], copy its name
    if ~isempty(cur)
        if cur(1) == '[' && cur(4) == ':' && cur(end) == ']'
            j = j + 1;
            chans.names{j} = cur(2:end - 1);

            i = i + 1;
            % now keep looking and find the channel number
            while true
                cur = complete_lines{i};
                if strncmp(cur, 'chnnum', 6)
                    chans.nums(j) = strread(cur, '%*s %d', 'delimiter', '=');
                    break
                end
                i = i + 1;
            end
        end
    end
    i = i + 1;
end
