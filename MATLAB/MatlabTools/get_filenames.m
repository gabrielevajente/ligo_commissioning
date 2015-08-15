function [filenames, DCUID, files_exist, rate] = get_filenames(model_name, verbose)
% get_filenames Calculates full filenames for files with a RCG 2 model
% call as:
% [filenames, DCUID, files_exist, rate] = get_filenames(model_name)
% model_name  is the name of the simulink diagram, 
%    eg. model_name = 's1isiitmx';
%
%  (the .mdl is optional). Do not include the path to model.
%
% filenames is a data structure with the full paths and names of various
% files which are associated with this model. These are calculated from the
% RCG2 file convention set forth in 
%   T1000379-v2, 'CDS Environment Configuration Scripts',  by Keith Thorne, July 9, 2010.
%   T1100263-v1, 'aLIGO CDS Front-end User Application Repository', by Keith Thorne, 16 may 2011
%   updated on Nov 7, 2012, BTL to follow the softlink for the foton file,
%       (if it exists)
% 
% filenames.mdl is the simulink model
% filenames.ini is the ini file
% filenames.par is the par file
% filenames.foton is the foton file. - follows the softlink, if it exists
% filenames.foton_chans - the orig /opt/.../chans/ locaton of the foton file.
% filenames.autoquack_logfile_recent: most recent log file from foton -c
%                                     conversion of the autoquacked foton file.
% filenames.autoquack_logfile_all: appended version of all the autoquack
%                                  conversion logs
% filenamse.foton_is_a_softlink:  1 if the chans file is a softlink, 0 otherwise
% for example, if the model_name is 's1isiitmx' and the foton file is
% softlinked to the userapps directory, then:
%
% filenames = 
%
%      ini: '/opt/rtcds/stn/s1/chans/daq/S1ISIITMX.ini'
%      par: '/opt/rtcds/stn/s1/target/s1isiitmx/param/tpchn_s1isiitmx.par'
%      mdl: '/opt/rtcds/userapps/release/isi/s1/models/s1isiitmx.mdl'
%      foton: '/opt/rtcds/userapps/release/isi/s1/filterfiles/S1ISIITMX.txt'
%      foton_chans: '/opt/rtcds/stn/s1/chans/S1ISIITMX.txt'
%      foton_is_a_softlink: 1
%         (if the foton file is not softlinked, then foton and foton_chans
%         will be the same, and foton_is_a_softline will be 0).
%      chans_dir: '/opt/rtcds/stn/s1/chans/'
%      autoquack_logfile_all:    '/opt/rtcds/stn/s1/log/s1isiitmx/autoquack_foton_log_all.txt'
%      autoquack_logfile_recent: '/opt/rtcds/stn/s1/log/s1isiitmx/autoquack_foton_log_recent.txt'
%
% DCUID: 
%   If the simulink model file exists, it will attempt to look at the model
%   and find the DCUID, and return that as a number in the DCUID field.
%
% files_exist:
%   The function will check the local file system to be sure these files
%   exist, if so, it will set files_exist to true.
%   If any of the files are not found, it will display an error message and
%   set files_exist to false.
% 
% rate:
%   BTL added this new output arg on June 10, 2011.
%   it is the rate of the model, and works for 1K, 2K, 4K, 8K and 16K models
%   rate is a number, and is the cycles per sec of the model, 
%   e.g. is this is a 4K model, rate = 4096
%
% chans_dir:       (added July 2015)
%   this is the chans directory. useful for log files added in July 2015 
%   to track the changes made by foton to the filter files.
%   e.g. chans_dir : '/opt/rtcds/stn/s1/chans/'
% 
% get_filenames can be called with an optional second parameter
% get_filenames(model_name,'verbose')
% which prints various diagnostic info.
%  ('v' is just as good as 'verbose')
% Brian Lantz, April 20, 2011
%
% on May 13, BTL updated the model directory to point to
%   the new cds_user_apps directory. This may not work with the LSC/ASC parts
% on May 17, BTL and DEC changed the cds_user_apps path to use a lowercase
%   version of the subsystem.  
% on June 10, BTL added the rate output. should work with older codes which
%    only take 3 outputs.
% on June 30, 2011 BTL added some robustness to the dcuid searching.
% on Nov 7, 2012 BTL added symbolic link following for foton files.
% on July 10, 2015, BTL added new output fields
%    filenames.chans_dir - location of the chans directory
%    filenames.log_dir - location of the log files directory
%    filenames.autoquack_logfile_recent - log of most recent autoquack / foton interaction 
%    filenames.autoquack_logfile_all    - log of all the autoquack / foton interactions 
%        the log file location was updated on July 31, 2015 to meet Jim Batch request   
% SVN $Id: get_filenames.m 8875 2015-07-31 21:08:19Z hugo.paris@LIGO.ORG $

%  various test cases:
%model_name = 's1isiitmx';    % should be OK
%model_name = 's1isiitmx.mdl';    % should be OK
%model_name = 'h1isiitmx';   % will not work at stanford
%model_name = 's2isiitmx';   % bad ifo should fail
%model_name = 's1isoitmx';   % bad subsystem name, should fail
%model_name = 'a1isiitmx';   % bad ifo should fail
%model_name = 'x1isiitmx';  % should fail at stanford

% strip off the .mdl at the end, using regexp.
% the '.' is not a word character, so if we get the first word, it
% automatically strips off the .mdl if it exists,
%> regexp('model','\w*','match')
%ans = 
%    'model'
%
%> regexp('model.mdl','\w*','match')
%ans = 
%    'model'    'mdl'

% fail state info

% name of the autoquack log files:
quack_log_all    = 'autoquack_foton_log_all.log';
quack_log_recent = 'autoquack_foton_log_recent.log';

DCUID = -1;
files_exist = false;
filenames = [];
rate = 0;

name_cell_array = regexp(model_name,'\w*','match');
model_name = lower(name_cell_array{1});
model_name_upper = upper(model_name);

display_info = false;

if nargin == 2
    if strncmpi(verbose, 'v', 1)
        display_info = true;
    end
end

if display_info        
    disp(['Looking for simulink file ',model_name,'.mdl'])
end

% figure out stuff from the name of the model:
% these vars match the stdenv variables from T1000379
ifo       = lower(model_name(1:2));  % eg 's1'
IFONUM    = lower(model_name(2));    % eg '1'
subsystem = lower(model_name(3:5));  % eg 'isi'

switch ifo
    case 'c1'
        site = 'cit';
    case 'g1'
        site = 'geo';
    case 'h1'
        site = 'lho';
    case 'h2'
        site = 'lho';
    case 'l1' 
        site = 'llo';
    case 'm1'
        site = 'mit';        
    case 's1',
        site = 'stn';
    case {'x0','x1','x2','x3'}
        site = 'tst';  % test stands
    otherwise
        disp(['Error: IFO ',ifo,' is not recognized, ']);
        disp('  Maybe your model name is bad?');
        disp('  It should start with ''s1'' or similar');
        files_exist = false;
        return
end

if display_info
    disp(['Building for ifo ',ifo,' at site ', site, ' for the ',subsystem,' subsystem.'])
end

% the model lives in:
% filenames.mdl = '/opt/rtcds/userapps/release/isi/s1/models
% it used to be:

%filenames.ini = '/opt/rtcds/stn/s1/chans/daq/S1ISIITMX.ini';
%filenames.par = '/opt/rtcds/stn/s1/target/s1isiitmx/param/tpchn_s1isiitmx.par';
%filenames.match.dcuid = '22';
%filenames.match.site = 'S1';

% these were added BTR, July 2015
filenames.chans_dir = ['/opt/rtcds/',site,'/',ifo,'/chans/'];
filenames.log_dir = ['/opt/rtcds/',site,'/',ifo,'/log/',model_name,'/'];
filenames.autoquack_logfile_all    = [filenames.log_dir, quack_log_all];
filenames.autoquack_logfile_recent = [filenames.log_dir, quack_log_recent];

filenames.ini = ['/opt/rtcds/',site,'/',ifo,'/chans/daq/',model_name_upper,'.ini'];
filenames.par = ['/opt/rtcds/',site,'/',ifo,'/target/',model_name,'/param/tpchn_',model_name,'.par'];
model_2_4 =  ['/opt/rtcds/userapps/release/',subsystem,'/',ifo,'/models/',model_name,'.mdl'];
if exist(model_2_4, 'file') ~= 0
    if display_info; disp('RCG 2.4 or later'); end
	filenames.mdl = model_2_4;
else
    if display_info; disp('RCG 2.3 or before'); end
	filenames.mdl = ['/opt/rtcds/',site,'/',ifo,'/userapps/release/',subsystem,'/',ifo,'/models/',model_name,'.mdl'];
end
filenames.foton_chans = ['/opt/rtcds/',site,'/',ifo,'/chans/',model_name_upper,'.txt'];
    

if ~exist(filenames.ini,'file')
    disp('ERROR: can not find the old ini file')
    disp(['   looking for ',filenames.ini])
    disp(['   Be sure to run the make install-',model_name,' before this step'])
    files_exist = false;
    return
end

if ~exist(filenames.par,'file')
    disp('ERROR: can not find the par file')
    disp(['   looking for ',filenames.par])
    files_exist = false;
    return
end

if ~exist(filenames.mdl,'file')
    disp('ERROR: can not find the simulink file')
    disp(['   looking for ',filenames.mdl])
    files_exist = false;
    return
end

if ~exist(filenames.foton_chans,'file')
   disp('ERROR: can not find the foton file')
   disp(['   looking for ',filenames.foton])
   disp(['   Be sure to run the make install-',model_name,' before this step'])
   files_exist = false;
   return
end

% is the file in the chans directory a softlink? - BTL, Nov 7, 2012.
% we need to find out if the foton file in the chans directory 
% is a link to the foton file in the (whereever they decided to put it).
% NOTE - if the link is a HARD link then ??? will happen.

try
    [stat, ls_listing] = system(['ls -l ',filenames.foton_chans]);
catch
    disp('I think you need to move to an operator computer')
    error('The matlab command ''system(''ls -l filename'')'' is not supported on your machine')
end

if stat ~=0
    error('failed to get directory info for the foton file. exiting')
end

foton_file_expr = '\/\S+\.txt';  % matches a '/(anything except a space).txt'
% for a normal file, there is one of these, for a soft link there are 2
% the first is the local file, the second is the real file.
% thus, the last match is always the real file.
file_list = regexp(ls_listing, foton_file_expr, 'match');
if isempty(file_list)
    error('the regexp parser for the foton file find is not working as expected. Tell BTL')
end

if length(file_list) == 1
    filenames.foton_is_a_softlink = false;
elseif length(file_list) == 2
    filenames.foton_is_a_softlink = true;
else 
    error('something odd is happening with the foton file location. Tell BTL')
end


filenames.foton = file_list{end};

if ~exist(filenames.foton,'file')
   disp('ERROR: can not find the foton file')
   disp(['   looking for ',filenames.foton])
   disp(['   Be sure to run the make install-',model_name,' before this step'])
   files_exist = false;
   return
end


%  use fileattrib to see if file exists, and to see if it is a softlink
%  If the file is a softlink, the 'Name' field follows the softlink
%  (or, at least, it is supposed to  - BTL Nov 7, 2012
% THIS ONLY WORKS ON THE MAC, DARN IT
%[foton_file_exists, foton_file_data, foton_file_message] = fileattrib(filenames.foton_chans);

% if foton_file_exists == 0
%     disp('ERROR: can not find the foton file')
%     disp(['   looking for ',filenames.foton_chans])
%     disp(['   Be sure to run the make install-',model_name,' before this step'])
%     files_exist = false;
%     disp('fileattrib returned this messge:')
%     disp(foton_file_message)
%     disp(' ')
%     return
% else
%     % get the location of the real file if the chans file is a softlink.
%     filenames.foton = foton_file_data.Names;
%     if ~strcmp(filenames.foton, filenames.foton_chans);
%         if display_info
%             disp('foton file is a soft link');
%         end
%     end
% end


if display_info
    disp(' ')
    disp('Located the following files:')
    disp(filenames)
    disp(' ')
end

%% now try to get the DCUID from the simulink model
% from the command line we can get the dcuid if we know the model name and path:
%controls@ligo-ops:~$ grep dcuid /opt/rtcds/stn/s1/userapps/isi/models/s1isiitmx.mdl      
%      Name		      "site=S1\nrate=2K\ndcuid=22\nshmem_daq=1\nadcSlave=1\nspecific_cpu=3\nhost=s1isi"
%controls@ligo-ops:~$ 

% [grep_status, grep_return] = unix(['grep dcuid ',filenames.mdl]);
%
% the old way is above, and can fail is the string dcuid appears elsewhere
% in the file (in a comment, for example).
% June 30, 2011 - BTL makes this more robust by doing a 2 step grep -
% the first step returns the 5 lines before and after the cdsParameter Tag, and the 
% second step finds the dcuid line from that.
% This should be sure that we only find the dcuid associated with
% cdsParameter block
% grep -e allows regexp to be used, this one should match the string:
%      Tag		      "cdsParameters"
%
% this may break if simulink changes its file formats. 
% Tested against 2009a and 2010a

cdsParam_regexp = ' Tag[[:space:]]*\"cdsParameters\" ';

[grep_status, grep_return] = unix(['grep -e ',cdsParam_regexp,' -C 5 ',filenames.mdl,' | grep dcuid ']);

if grep_status ~= 0
    disp('Error: the grep to get the DCUID failed with the following message:')
    disp(grep_return)
    files_exist = false;
    return
end
% find the string 'dcuid=digits' and return the digits.
% the \s* matches 0 or more spaces so dcuid = digits will also work
% the 'tokens' means that stuff in the () is returned as a cell in a cell
% array, \d* is any number of digits, 
% ie, return all the digits following the dcuid = 

% test cases, these should all work:
%grep_return = '  Name		      "site=S1\nrate=2K\ndcuid=22\nshmem_daq=1\nadcSlave=1\nspecific_cpu=3\nhost=s1isi"';
%grep_return = '  Name		      "site=S1\nrate=2K\ndcuid=22\nshmem_daq=1';
%grep_return = '  Name		      "site=S1\nrate=2K\ndcuid=22';
%grep_return = '  Name		      "site=S1\nrate=2K\ndcuid= 22\nshmem_daq=1';
%grep_return = '  Name		      "site=S1\nrate=2K\ndcuid= 22 \nshmem_daq=1';
%grep_return = '  Name		      "site=S1\nrate=2K\ndcuid=22 \nshmem_daq=1';
%grep_return = '  Name		      "site=S1\nrate=2K\ndcuid=2\nshmem_daq=1';

% these test cases should be caught by error checking
%grep_return = '  Name		      "site=S1\nrate=2K\ndcud=22\nshmem_daq=1'; % no cell is returned 
%grep_return = '  Name		      "site=S1\nrate=2K\nshmem_daq=1';
%grep_return = '  Name		      "site=S1\nrate=2K\ndcuid=\nshmem_daq=1';  % here we get cell, but text is empty

% these should work
%grep_return = '  Name		      "site=S1\nrate= 2K\ndcuid=22';
%grep_return = '  Name		      "site=S1\nrate=4 K\ndcuid=22';
%grep_return = '  Name		      "site=S1\nrate= 8k\ndcuid=22';

% these should fail gracefully
%grep_return = '  Name		      "site=S1\nrate=3K\ndcuid=22';
%grep_return = '  Name		      "site=S1\ndcuid=22';
%grep_return = '  Name		      "site=S1\nrate= 2\ndcuid=22';



dcuid_pat = 'dcuid\s*=\s*(\d*)';
regexp_cell_array = regexp(grep_return, dcuid_pat, 'tokens');

if isempty(regexp_cell_array)
    disp('ERROR: failed to find the DCUID in the model file')
    disp('   the grep returned:')
    disp(grep_return);
    files_exist = false;
    return
end

temp_cell = regexp_cell_array{1};
dcuid_string = temp_cell{1};  %double cell array, weird.

if isempty(dcuid_string)
    disp('ERROR: failed to find the DCUID in the model file')
    disp('   the grep returned:')
    disp(grep_return);
    files_exist = false;
    return
else
    DCUID = str2double(dcuid_string);
    if display_info
        disp(['DCUID = ',dcuid_string]);
    end
end

% added the rate reader - BTL June 10, 2011
% pattern is rate=2K, the \s* matches 0 or more spaces
% the [kK] allows upper or lower k
% the (\d*) returns the digits as the token
% so this will match 'rate=2K' or 'rate = 16 k'
% and return {{'2'}} or {{'16'}}.
% why the double cell array and strings? just the way it is, I guess
% BTL june 10 2011

rate_pat = 'rate\s*=\s*(\d*)\s*[kK]';
regexp_cell_array = regexp(grep_return, rate_pat, 'tokens');

if isempty(regexp_cell_array)
    disp('ERROR: failed to find the RATE in the model file')
    disp('   the grep returned:')
    disp(grep_return);
    files_exist = false;
    return
end

temp_cell = regexp_cell_array{1};
rate_string = temp_cell{1};  %double cell array, weird.

if isempty(rate_string)
    disp('ERROR: failed to find the RATE in the model file')
    disp('   the grep returned:')
    disp(grep_return);
    files_exist = false;
    return
else
    RATENUM = str2double(rate_string);
    if display_info
        disp(['RATE = ',rate_string]);
    end
    if (RATENUM == 1)
        rate = 1024;
    elseif (RATENUM == 2)
        rate = 2048;
    elseif (RATENUM == 4)
        rate = 4096;
    elseif (RATENUM == 8)
        rate = 8192;
    elseif (RATENUM == 16)
        rate = 16384;
    else 
        disp('I did not understand the rate')
        disp(['the rate number is ',rate_string])
        disp('the grep returns:')
        disp(grep_return)
        files_exist = false;
        return
    end
end


files_exist = true;
return


