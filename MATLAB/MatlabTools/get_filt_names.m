function filter_names = get_filt_names(model_name)
% function filter_names = get_filt_names(model_name)
%
% This function finds the foton filter names associated with a control diagram. 
% This is the RCG2 version. 
% It gets the info from the FOTON FILE and not the simulink model.  
% %
% model_name should be a string with the name of the LIGO simulink model. 
%               model_name = 's1isiitmx' or 's1isiitmx.mdl'
%
% filter_names is a cell array where each element is a string with a filter
% name from the model.  To reference one name, use curly braces as in  
%  >> for i = 1:length(filter_names)
%  >      disp(filter_names{i})
%  >  end
%
% see also get_chans_filename, autoquack
%
%  TSC June 2007
%
%  updated BTL July 8 2008 to grab both cdsFILT and also cdsPPFIR
%
% completely rewritten by BTL on April 21, 2011
%
% $Id: get_filt_names.m 2444 2011-04-21 19:00:36Z brian.lantz@LIGO.ORG $

[filenames, DCUID, amIhappy] = get_filenames(model_name);

if amIhappy == false
    disp('ERROR: unable to find the necessary files')
    disp('aborting')
    filter_names = {};
    return
end

%%

% for local testing
%filenames.foton = '/Users/BTL/Brians_files/testfiles/S1ISIITMX.txt';

foton_file = filenames.foton;

% open the foton file, 
% find all the lines which start with   # MODULES
% and get the strings in the rest of those lines
% this will be a list of all the filter modules
%   eg grab the two filters from the line:
% # MODULES ITMX_SU_1 ITMX_SU_2
% etc.


fid = fopen(foton_file,'r');

if fid == -1
    error(['Could not open foton file ',filename])
end

% Read in the whole text.  This is a hack.  If you know a better way,
% please email blantz@stanford.edu

complete_lines = textscan(fid,'%s','Delimiter','\n');
complete_lines = complete_lines{1};
fclose(fid);

% look for the line which starts like this:
header_pat = '# MODULES';

filter_names = {};  % start with an empty cell array

i=0;
while i < length(complete_lines)
    i=i+1;
    if (strncmp(header_pat,complete_lines(i),length(header_pat)))
        % this line has 1 or more filter names in it
        this_line = complete_lines{i};
        filter_part = this_line(10:end);  % drop the # MODULES
        new_filter_names = regexp(filter_part,'\w+','match'); % grap each word seperately
        filter_names = [filter_names, new_filter_names];  % concat the cell arrays;
    end
end


filter_names = sort(unique(filter_names));


