function [status] = write_ini_file_rcg1(channel_name_file, output_file_name, model_name, model_path)
% write_ini_file_rcg1  creates a new ini file based on a file of desired channels
%   call as 
% status = write_ini_file_rcg1(channel_name_file, output_file_name, model_name, model_path)
%
%  This is the original version, and should work with rcg1
%  It but has been deprecated because the
%  realtime code generator v2 keeps all the files in new places
%      THE RCG2 verison is now
%  write_ini_file.m
%    BTL April 7, 2011
%
% e.g. 
%  status = write_ini_file_rcg1('ISIchannels.txt','test.ini','isi.mdl','/cvs/cds/simLink/');
% 
% status is either a 0 or 1, 0 means an error occured, 1 means the file was
%   written correctly
% channel_name_file  is a text file with the list of channels to put into
% the framebuilder. this is a text file, with 1 channel per line
% blank lines are OK, lines beginning with a % are treated as comments
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
% channel with _DAQ appended to the end.
% If there is a name in the file which can not be found in the .par file
% (e.g. L1:SOME-BOGUS_CHANNEL) then a warning will be printed, 
% and the channel will not be added to the .ini file.
%
% output_file_name is the name of the file to be created
%  this will probably go into the local directory, unless you put a direct
%  path here.
%  We do not assume this will automatically replace the exisiting .ini file.
% 
% model_name and model_path are the name and path of the simulink model
%  used. These are necessary to get the IFO name, locate the par file, etc.
%
% the following header is automatially added to the new file:
%   [default]
%   dcuid=',DCUID
%   datarate=2048
%   gain=1.00
%   acquire=1
%   ifoid=',IFOID
%   datatype=4
%   units=V
%   slope=6.1028e-04
%   offset=0
% 
% DCUID and IFOID are parsed from the cdsParameters block in the simulink 
% model file 
% 
% BTL changed the gain to 'slope=6.1028e-04\n', from 6.1028e-5
% this is for the DAQ with a conversion of 40V/65536 cnts 
% instead of 4V/65536cnts
% 
% this script automatically backs up the existing BLAH.ini file to
% to the file BLAH.ini.datestring, where datestring is
% yyyymmddThhmmss (option 30 of the datestr command)
%
% BTL July 18, 2008
%
% $Id: write_ini_file.m 125 2008-07-31 15:49:03Z seismic $

fid_channel_list = fopen(channel_name_file,'r');

if fid_channel_list == -1
    disp(['Could not open specified file ',channel_name_file])
    status = 0;
    return
end

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


%model_name = 'isi';  % should be an mdl file, but name should not have '.mdl'
%model_path = '/cvs/cds/simLink/';

filenames = get_filenames(model_path, model_name);
if strcmp(filenames.ini, '')  % ini is set to '' if get_filenames_v3 can't find the mdl file
    disp(' did not create the new .ini file!')
    disp(' ')
    status = 0;
    return
else
    disp(' ')
    disp('using the following files:')
    disp(filenames)
    disp(' ')
end

daq_filename = filenames.ini;
par_filename = filenames.par;

%daq_filename = [daq_filename, '.test'];
%par_filename = '/cvs/cds/llo/target/gds/param/tpchn_L3.par'

% back up the .ini file
if exist(daq_filename,'file') ==0
    disp(' ')
    disp('ERROR!')
    disp(' There is no preexisting .ini file, which is odd.')
    disp(' You should make sure that you completed the make process correctly.')
    disp(' aborting file creation process')
    disp(' ')
    status = 0;
    return
end

time_tag = datestr(now,30);
backup_ini_file = [daq_filename,'.',time_tag];
disp(['copying existing .ini file to ',backup_ini_file])
copyfile(daq_filename,backup_ini_file);

% check that the backup file is OK
fid = fopen(backup_ini_file,'r');
if fid == -1
    disp(['Could not open specified file ',filename])
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
DCUID = filenames.match.dcuid;
IFOID = filenames.match.site(2);
% print default info
fprintf(fid, ['[default]\n',...
    'dcuid=',DCUID,'\n',...
    'datarate=2048\n',...
    'gain=1.00\n',...
    'acquire=1\n',...
    'ifoid=',IFOID,'\n',...
    'datatype=4\n',...
    'units=V\n',...
    'slope=6.1028e-04\n',...
    'offset=0\n']);
fprintf(fid, '\n');

channel_count = 0;
total_data_rate = 0;
number_size = 4;
high_rate_channel_count = 0;
low_rate_channel_count  = 0;
% print channel names and channel numbers
for n = 1:length(tp_chans.names)  % run through the testpoints from the par file, in order
    include_chan_index = find(strcmp(tp_chans.names{n}, include_chans),1,'first');
    if ~isempty(include_chan_index)  % if this testpoint is in the include list, then
        fprintf(fid, '%s\n', ['[', tp_chans.names{n}, '_DAQ]']);
        fprintf(fid, '%s\n', ['chnnum=', num2str(tp_chans.nums(n))]);
        if ~isnan(include_rates(include_chan_index))  % if there is a real number here
            fprintf(fid, '%s\n', ['datarate=', num2str(include_rates(include_chan_index))]);
            total_data_rate = total_data_rate + number_size*include_rates(include_chan_index);
            low_rate_channel_count = low_rate_channel_count + 1;
        else
            total_data_rate = total_data_rate + number_size*2048;
            high_rate_channel_count = high_rate_channel_count +1;
        end
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

