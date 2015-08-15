function [status] = install_HAM_FIR_filter(model_name, optional_name_tag)
% install_FIR_filter  installs the FIR filter modules for a model in a FOTON-like file
% 
% [status] = install_FIR_filter(model_name)
% model_name  is the name of the simulink diagram, 
%     eg. model_name = 's1isiitmx';
%    (the .mdl is optional). Do not include the path to model.
% 
% This opens creates a foton-like file for  FM2 of FIR filters
% by taking the master file at
% /opt/rtcds/userapps/release/hpi/common/filterfiles/MASTER_FIR_FILE.fir
% and then
% 1) replace the TAGRATE with the rate of your model
% 2) replase the TAGSYSTEM with your chamber name
% 3) saving the new file at /opt/rtcds/{SITE}/{IFO}/chans/{MODELNAME}.fir
%
% By default, the filter modules are going to be
%
% chamber_SENSCOR_X_FIR, chamber_SENSCOR_Y_FIR, and chamber_SENSCOR_Z_FIR
% chamber is calculated from the model_name.
% 
% If you want to put it into a different module, ie
% ITMX_ST1_SENSCOR_X_FIR, then you can use the optional second argument
% and call the function as:
% 
% status =  install_FIR_filter(model_name,'ITMX_ST1')
%
% status = 0 if there is an error
% status = 1 if everything is OK
%
% BTL Jan 30, 2012

status = 0;

disp(' ')
disp(['running ',mfilename, ' on ',date])

[filenames, ~, files_exist, rate] = get_filenames(model_name);

rate_str = num2str(rate);

if ~files_exist
    error('All the necessary files can not be found, have you made the model yet?')
end

fir_file_name = strrep(filenames.foton, 'txt', 'fir');

% if the .fir already exists, make a backup file.
if exist(fir_file_name,'file')
    datestamp     = datestr(now,30);
    backup_file   = [fir_file_name,'.bak.',datestamp];
    [stat, mssg]  = system(['cp ',fir_file_name,' ',backup_file]);
    if stat ~=0;    error(mssg); end
end


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

name_cell_array = regexp(model_name,'\w*','match');
model_name      = lower(name_cell_array{1});
CHAMBER         = upper(model_name(6:end));  % eg ITMX

if nargin == 1
    new_tag = CHAMBER;
else
    new_tag = upper(optional_name_tag);
end

%test_file   = '/Users/BTL/Brians_files/CDS/cds_user_apps/temp/hpi/common/scripts/test.fir';
%test_source = '/Users/BTL/Brians_files/CDS/cds_user_apps/temp/hpi/common/filterfiles/MASTER_FIR_FILE.fir';
%[stat, mssg]  = system(['cp ',test_source,' ',test_file]);


source_file = '/opt/rtcds/userapps/release/hpi/common/filterfiles/MASTER_HAM_FIR_FILE.fir';

[stat, mssg]  = system(['cp ',source_file,' ',fir_file_name]);
if stat ~=0;    error(mssg); end

% insert the model rate
search_term  = 'TAGRATE';
replace_term = rate_str;

[stat, mssg] = system(['perl -pi -w -e ''s/',search_term,'/',replace_term,'/g;'' ',fir_file_name]);
if stat ~=0; error(mssg); end

% insert the correct filter names
search_term  = 'TAGSYSTEM';
replace_term = new_tag;

[stat, mssg] = system(['perl -pi -w -e ''s/',search_term,'/',replace_term,'/g;'' ',fir_file_name]);
if stat ~=0; error(mssg); end

disp(['successfully saved FIR file as ',fir_file_name]);
status = 1;






