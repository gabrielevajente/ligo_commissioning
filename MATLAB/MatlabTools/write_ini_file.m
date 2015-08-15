function [status] = write_ini_file(channel_name_file, model_name, user_data_rate, user_output_file_name)
% write_ini_file  creates a new ini file based on a file of desired channels
% modified to work with RCG2 on April 7, 2011 by BTL
% this appends _DQ not _DAQ
% updated again to store the model rate in the defaults and the storage
% rate with the channels. BTL June 13, 2011
%
% The rcg 1 verison is now write_ini_file_rcg1.m
%   (the new rcg keeps all the files in new, much better, places)
%
%   call as 
% status = write_ini_file(channel_name_file, model_name)
%  optional args are:
% status = write_ini_file(channel_name_file, model_name, data_rate, output_file_name)
%
% it expects the model to be at
%
% /opt/rtcds/userapps/SUBSYSTEM/models/MODEL_NAME.mdl'
%
%   e.g. 
% status = write_ini_file('BSC-ISI-ITMXchannels.txt','s1isiitmx');
%  the model_name can have the .mdl or not, as you like.
% 
% status is either a 0 or 1, 0 means an error occured, 1 means the file was
%   written correctly
%
% channel_name_file  is a text file with the list of channels to put into
% the framebuilder. this is a text file, with 1 channel per line
% blank lines are OK, lines beginning with a % are treated as comments
% lines with only spaces cause warning messages, but don't break anything
%   
% an example file might look like this
%   %ISIchannels.txt:
%   % this is a file of ISI framebuilder channels
%   % created by Jeff Kissel on July 18, 2008
%   L1:ISI-OMC_MON_COILVOLTV1_IN1
%   L1:ISI-OMC_MON_COILVOLTV2_IN1
%   L1:ISI-OMC_MON_COILVOLTV3_IN1, 256
%   L1:ISI-OMC_MON_COILVOLTH1_IN1
%   L1:SOME-BOGUS_CHANNEL
%   L1:ISI-OMC_GEOPF_H1_IN1
%
% channels can be written at a data rate slower than the default.
% To do this, follow the channel name with a comma and the new datarate
% as was done with the COILVOLT3 channel above.
% 
% The framebuilder channels will be assigned the name of the original
% channel with _DQ appended to the end.
% If there is a name in the file which can not be found in the .par file
% (e.g. L1:SOME-BOGUS_CHANNEL) then a warning will be printed, 
% and that channel will not be added to the .ini file.
%
% data_rate  -  rate at which the framebuilder stores the data.
%    Note this is NOT the rate at which the model run (although they are related)
%    an optional input argument which can be used
%   to pick a different default data rate (it must be a power of 2).
%   The default data rate is 2048.
%
% This function automatically creates a new ini file, and saves it in the 
%   correct place (as determined by get_filenames.m).
%
% output_file_name  -  an optional input argument which allows you to 
%  save the new ini file to a different location, instead. This can be useful
%  for testing purposes. 
%
% ie.
%
% status = write_ini_file('BSC-ISI-ITMXchannels.txt','s1isiitmx',1024,'test.ini')
%
% would create the ini file 'test.ini' in the local directory, and it would
% have a default data rate of 1024 samples/ sec.
%
% the following header is automatically added to the new file:
% [default]
%   offset=0
%   units=V
%   datarate= MODELRATE  (eg 4096)
%   gain=1.00
%   datatype=4
%   dcuid= DCUID  (eg 22)
%   ifoid= IFOID  (eg 1)
%   slope=6.1035e-04
%   acquire=1
% 
% DCUID is parsed from the cdsParameters block in the simulink model file 
%         by the get_filenames.m function.
% MODELRATE is the also parsed from the cdsParameters block
% IFOID is parsed from the file names
%
% this script automatically backs up the existing BLAH.ini file to
% to the file BLAH.ini.datestring, where datestring is
% yyyymmddThhmmss (option 30 of the datestr command)
%
% BTL July 18, 2008
%
% updated 20110323 by DEC to ensure that the data names are less than 34
% characters long including the _DAQ
% and modified by BTL to work with RCG 2
%
% $Id: write_ini_file.m 125 2008-07-31 15:49:03Z seismic $


% BTL changed the gain to 'slope=6.1035e-04\n', from 6.1028e-5
% this is for the DAQ with a conversion of 40V/65536 cnts 
% instead of 4V/65536cnts
% 

MAX_NAME_LENGTH = 51; % new maximum length of the filter name. 
%                       (this + _IN1_DQ must fit in the new FB system)
% BTL June 11, 2011.

if nargin == 2;
    default_data_rate_string = '2048';
    default_data_rate = str2double(default_data_rate_string);
    use_default_ini_file = true;
elseif nargin == 3;
    default_data_rate_string = num2str(user_data_rate);
    default_data_rate = str2double(default_data_rate_string);
    if round(log2(default_data_rate)) ~= log2(default_data_rate)
        disp('Error: The data rate must be a power of 2, e.g. 2048')
        status = 0;
        return
    end
    use_default_ini_file = true;
else
    default_data_rate_string = num2str(user_data_rate);
    default_data_rate = str2double(default_data_rate_string);
    if round(log2(default_data_rate)) ~= log2(default_data_rate)
        disp('Error: The data rate must be a power of 2, e.g. 2048')
        status = 0;
        return
    end
    use_default_ini_file = false;
end


fid_channel_list = fopen(channel_name_file,'r');

if fid_channel_list == -1
    disp(['Could not open specified file ',channel_name_file])
    status = 0;
    return
end

%%    channel name parsing
% Read in the whole text of the channel list file
% comments in the text file start with a % and are ignored
% empty lines are ignored by the 'MultipleDelimsAsOne',1 option
% first, get the name, and put it in complete_lines{1}
% then get the data rate and put it in complete_lines{2} 
% if the data rate is not defined, then it will be NaN

complete_lines = textscan(fid_channel_list,'%s%n', ... 
    'CommentStyle','%', 'MultipleDelimsAsOne',1,'Delimiter',' ,');
include_chans = complete_lines{1};
include_rates = complete_lines{2};

fclose(fid_channel_list);

num_chans = length(include_chans);
chan_length = zeros(num_chans,1);
illegal_chans = 0;

for ii=1:num_chans
    chan_length(ii) = length(char(include_chans(ii)));
    if chan_length(ii) > MAX_NAME_LENGTH %maximum is 34 with the _DAQ added so that makes 30 the maximum here and 26 in simulink
        disp(['WARNING, illegally long channel name: ', char(include_chans(ii))])
        illegal_chans = illegal_chans +1;
    end
end

if illegal_chans > 0
    
        disp(['The system has detected ', num2str(illegal_chans), ' illegally long channel names'])
        disp('you MUST fix this or framebuilder will not start')
        disp('')
        status = 0;
        return
end

%%  get the DCUID and ModelRate

[filenames, DCUID_num, files_exist, ModelRate_num] = ...
    get_filenames(model_name,'verbose');

if ~files_exist
    disp('Error, failed to find some files, exiting')
    status = 0;
    return
end

dcuid_string = num2str(DCUID_num);
modelrate_string = num2str(ModelRate_num);


IFONUM    = lower(model_name(2));    % eg '1'

ini_filename = filenames.ini;
par_filename = filenames.par;

if use_default_ini_file == true
    output_file_name = ini_filename;
else
    output_file_name = user_output_file_name;
end

time_tag = datestr(now,30);
backup_ini_file = [ini_filename,'.',time_tag];
disp(['copying existing .ini file to ',backup_ini_file])
copyfile(ini_filename, backup_ini_file);   

% check that the backup file is OK
fid = fopen(backup_ini_file,'r');
if fid == -1
    disp(['Could not open backup file ',filename])
    status = 0;
    return
end

fclose(fid);


tp_chans = get_chan_info(par_filename);

% do a check to be sure that all the channels we want to write
% exist in the par file

for this_chan = 1:length(include_chans)
    if ~any(strcmp(include_chans{this_chan}, tp_chans.names))
        disp(['WARNING: can not find the channel ',include_chans{this_chan},' in the par file'])
    end
    if sum(strcmp(include_chans{this_chan},include_chans)) > 1
        disp(['ERROR: channel ',include_chans{this_chan},' appears more than once'])
        status = 0;
        return
    end
    
end


% open the new .ini file to write
fid = fopen(output_file_name,'w');

IFONUM='0'; % VL - ifoid should be 0 for all ifo
% print default info
fprintf(fid, ['[default]\n',...
    'offset=0\n',...
    'units=V\n',...
    'datarate=',modelrate_string,'\n',...
    'gain=1.00\n',...
    'datatype=4\n',...
    'dcuid=',dcuid_string,'\n',...   
    'ifoid=',IFONUM,'\n',... 
    'slope=6.1035e-04\n',...
    'acquire=1\n']);
fprintf(fid, '\n');

% setup for the loop
channel_count   = 0;
total_data_rate = 0;
number_size     = 4;
high_rate_channel_count = 0;
low_rate_channel_count  = 0;

%% VL - 2011_07_20 - add acquire=1 and data_rate=4 for each channel
% print channel names and channel numbers
for n = 1:length(tp_chans.names)  % run through the testpoints from the par file, in order
    include_chan_index = find(strcmp(tp_chans.names{n}, include_chans),1,'first');
    if ~isempty(include_chan_index)  % if this testpoint is in the include list, then
        fprintf(fid, '%s\n', ['[', tp_chans.names{n}, '_DQ]']); %changed this for Stanford
        fprintf(fid, '%s\n', 'acquire=1');
        fprintf(fid, '%s\n', ['chnnum=', num2str(tp_chans.nums(n))]);

        if ~isnan(include_rates(include_chan_index))  
            % if there is a number here, use that rate for this channel
            fprintf(fid, '%s\n', ['datarate=', num2str(include_rates(include_chan_index))]);
            total_data_rate = total_data_rate + number_size*include_rates(include_chan_index);
            low_rate_channel_count = low_rate_channel_count + 1;
        else
            % otherwise, write the default data rate for this channel
            fprintf(fid, '%s\n', ['datarate=', default_data_rate_string]);
            total_data_rate = total_data_rate + number_size*default_data_rate;
            high_rate_channel_count = high_rate_channel_count +1;
        end
        fprintf(fid, '%s\n', 'datatype=4');
        channel_count = channel_count+1;
    else
        % don't include this testpoint in the framebuilder
    end
end


disp(['wrote ',num2str(channel_count),' channels to ',output_file_name,' on ',date])
disp(['  high rate channels: ',num2str(high_rate_channel_count),...
    '  low rate channels: ',num2str(low_rate_channel_count)]);
disp(['  the total data rate is ',num2str(total_data_rate)])
status = 1;

