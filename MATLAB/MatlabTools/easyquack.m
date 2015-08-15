% This script finds the *_filter variables in the work space and calls
% autoquack to add them to the .ini file for the model. The user should then
% do a coefficient reload for the filters to appear in epics. If there is a *_filter 
% whose name does not match with any filter in the model, a warning will 
% be displayed. The variables model_path and model_name must be specified
% before running easyquack.
% 
% Ex. model_name = 's1isiitmx';
%
% Optional: The subblock for the filter and the label that will show up 
% in epics can both be specified by appending _#label to the variable name. 
% The default subblock is 0, and default label is the variable name.
%
% For example, the variable CONT_Y_filter_4Yboost will put the filter labelled
% 'Yboost'in the 4th subblock of the CONT_Y filter bank.
%
% LAL August 2007
%
% $Id: easyquack.m 2444 2011-04-21 19:00:36Z brian.lantz@LIGO.ORG $
%
%  mod by BTL to work with new model name and file locations for RCG2
%   also get filter names from foton file, not the simulink diagram
%   April 21, 2011


model_filt_names = get_filt_names(model_name);
[filenames, DCUID, filesExist] = get_filenames(model_name);
if filesExist == false
    disp('Error: can not find the files!')
    disp('aborting easyquack')
    return
else
    foton_filename = filenames.foton;
end


% backup the existing foton file;
[system,message] = unix(['cp ' foton_filename ' ' foton_filename '.bak.run_quack_all']);

if system == 0
    disp('Backed up the old foton file')
else
    disp('Error backing up foton file, message is:')
    disp(message)
    disp(' ')
    disp('aborting easyquack')
    return
end


to_quack = struct('name',{},'value',{},'label',{},'subblock', {});

% find all filters in workspace with _filter in the name
my_filt_names = whos('*_filter*');
disp(' ');
disp(['Found ',num2str(length(my_filt_names)),' filters for foton']);

Previously_Assigned_Subblocks = [];
for ii=1:length(my_filt_names)
    full_name = my_filt_names(ii).name;
    index = findstr(full_name, '_filter');
    filt_name = full_name(1:index-1);

    % Warn about variables named *_filter that that user might expect to be
    % made into a filter, but we can't find a matching name for.
    if ~any(strncmp(filt_name,model_filt_names, length(filt_name)))
       cprintf([0 0.5 0.8],['     No name from the FOTON file found for variable ',filt_name,'\n'])
        
    else
        next_filt = struct('name','label','value','subblock');
        next_index = length(to_quack) + 1;
        next_filt.value = eval(full_name);
        next_filt.name = filt_name;
        
        % if the variable name has nothing after the _filter, then make its
        % label the same as its name, and its sublock should be zero
        if length(full_name) == length(filt_name) + 7
            next_filt.label = next_filt.name;
            next_filt.subblock = 0;
        
        % the subblock number should be after _filter_    
        else
            subblock = str2double(full_name(index + 8));
            
            % if there's no number there, set the subblock to zero
            % and make its label the string after the _filter_
            if isempty(subblock)
                next_filt.label = full_name(index + 8:end);
                next_filt.subblock = 0;
             
            % if there is a number, make the subblock that number, and
            % the label the string after it.  if there is a number but no
            % label, use the default label.
            else
                next_filt.label = full_name(index + 9:end);
                if isempty(next_filt.label)
                    next_filt.label = next_filt.name;
                end
                next_filt.subblock = subblock;
            end
        end
    end

    %add an error checking for multiple button (subblock) assigmentsts  RKM 6/18/08
    INDEXED = [];
    for kk = 1:length(my_filt_names)
        if strmatch(filt_name,my_filt_names(kk).name) %find all filters in current filter bank
            INDEXED = [INDEXED kk];
        end
    end
    X = min(length(Previously_Assigned_Subblocks),INDEXED(end));
    if any(Previously_Assigned_Subblocks(INDEXED(1):X)== subblock)
        warning(['There are multiple assingments to the same button in filter bank ',filt_name]);
    end
    
    %    disp([next_filt.name,' ',num2str(next_filt.subblock),' ',next_filt.label])
    to_quack(next_index) = next_filt;
    Previously_Assigned_Subblocks = [Previously_Assigned_Subblocks next_filt.subblock];
end


disp(' ');

autoquack(foton_filename, to_quack);
        
disp('easyquack has finished')
