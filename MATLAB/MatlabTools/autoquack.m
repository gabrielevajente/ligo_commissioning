function autoquack(foton_filename, filters)
% AUTOQUACK  automatically export matlab filters into a foton file for aLIGO.
%  AUTOQUACK(foton_filename, filters)
% The function's first argument is the foton filename (including the full path). 
% see get_filenames for an easy way to generate the foton file name.
%
% The second argument is 
% a struct array containing the fields
% 'name','value', 'label', and 'subblock'.  The value field is a matlab 'sys' object,
% the name field is the name of the filter in the model where it should go,
% and the label is what the filter will be labeled in the medm screens.  The subblock
% tells medm where in the filter bank the filter should go.
%
% 'name' - matches the name in foton - 
%   if the full name of the module is S1:ISI-ITMX_TEST1, then the name will
%   be ITMX_TEST1, same as foton
%
% 'value' - the discrete time filter
%
% 'label' - a string which appears in the box in the medm screen
%   it CAN NOT contain spaces.
%   it may contain leters, numbers, (_){}[]^:%$#
%   
% 'subblock'- which of the 10 modules to use, numbered 0-9, per foton
%
% 'turnon' - an optional field, which can be set to either
%     'immediate' - engages filter immediately
%        or  
%     'zerocrossing'  set to turn on filter at a zerocrossing,
%         with a 300 count tolerance, and a timeout of 8192 (2 sec)
%         these parameters were determined by Vincent L
%      eg filter(3).turnon = 'immediate';
%      (note - I only check the first 3 letters, so 'immense' and 'immodest' also work)
%        or
%     'ramp'  ramps the filter on. The default ramp time is 5 seconds.
% 
% 'ramptime' is an optional field which can be used to define ramptimes 
%      other than 5 seconds. (Value is only used if 'turnon' is 'ramp') 
%      it must be 0-100, otherwise it goes to 5 sec and sends you a
%      nasty-gram
%
% This function is basically a nice wrapper around the following functions:
%          Fs = get_sample_freq(filename, filter_name)
%          [coe,s] =quack_to_rule_them_all(gomo,Fs,Method,name,label)
%          write_filter_coe(filename, filter_name, filter_string)
%
%  You should look at the help text for each of these functions to
%  understand what each one does.
%  
%  see EASYQUACK for a wrapper which automatically builds the data structure. 
%
%  TSC June 2007
%  LAL July 2007
%
%  BTL updated to RCG2 version of get_sample_freq on April 21, 2011
%  BTL updated on Nov 21 2011 to add optional .turnon field
%      and updated the help.
%
% BTL added complete message, and turned off the disp of every filter
%   Aug 16, 2012.
% BTL also modified write_filter_coe.m to generate error if filter not
% found, and (Feb 2014) to remove any DESIGN string info from the filter module you
% are writing.
%
% July 2015 - BTL added the autoquack_foton_cleaner function calls at the
% beginning and the end to have foton -c clean the foton file and insure
% the format of the foton file will not be changed by furter reads from
% foton. This also creates a pair of new log files in the chans directory
% the file name and locations are defined in get_filenames:
%   autoquack_foton_log_recent.txt  most recent output from foton -c
%    autoquack_foton_log_all.txt  - compilation of all the ..._recent logs.
%
%     and that's not all!
%
% also added autoquack_conversion_check.m to automatically compare
% the filters you specified with the updated filters in the foton file

% changed error message -BTL Aug 22, 2012
% fixed bug so there is always a ramptime defined. BTL Aug 23, 2012
%
% BTL updated Feb 14, 2014 to use write_filter_coe_nodesignstring.m 
% instead of the original write_filter_coe.m
%
%  This has the effect of deleting all the DESIGN info for all the 
% filter sections in the filter module you have updated.
% this makes autoquack and foton play together more nicely, per
% discussions between BTL and Jim Batch. 
% SVN $Id$

model_rate = get_sample_freq(foton_filename);
if model_rate == 0
    error(['Model data rate should not equal 0.  Probably an invalid model name ',foton_filename])
end


initial_status = autoquack_foton_cleaner('initial',foton_filename);
if initial_status < 2
    disp('foton file ready for updating')
else
    error('something is wrong with the starting foton file')
end

    

% do some error checking
if sum(isfield(filters,{'name','value','label','subblock'})) ~= 4
    error('The data structure for autoquack is missing a field. Please use ''help autoquack'' for more information');
end

default_ramptime = 5;  %seconds

for n = 1:length(filters)
    ramptime = default_ramptime;  % start this with a placeholder
    
    if isdiscrete(filters(n).value) == 1
        METHOD = 'D';
        filter_time = filters(n).value.Ts;
        if filter_time ~= 1/model_rate
            error(['The filter rate for filter ',num2str(n),' does not match the model rate!'])
        end
    else
        METHOD = 'T';
    end
    
    if ~isfield(filters,'turnon')
        turnon = 'immediate';
    else
        turnon = filters(n).turnon;
        if isempty(turnon)
            turnon = 'immediate';
            %disp(['warning - filter ',num2str(n),' has an empty turnon fields, setting it to ''immediate'''])
        elseif strncmpi(turnon, 'imm', 3)
            turnon = 'immediate';
        elseif strncmpi(turnon, 'zer', 3);
            turnon = 'zerocrossing';
        elseif strncmpi(turnon, 'ram', 3);
            turnon = 'ramp';
            if ~isfield(filters, 'ramptime')
                ramptime = default_ramptime;
            else
                ramptime = filters(n).ramptime;
                if isempty(ramptime)
                    ramptime = default_ramptime;
                end
                if (ramptime > 100) || (ramptime <0)
                    ramptime = default_ramptime;
                    disp(['bad ramptime for ',filters(n).name,', subblock =',num2str(filters(n).subblock)])
                    disp(['     label =',filters(n).label])
                    warning('ramptime must be 0-100 sec. setting to 5 sec')
                end
                
            end
            
        else
            error('the turnon field must be ''immediate'', ''zerocrossing'', or ''ramp''');
        end
    end
    
    [~,s] = quack_to_rule_them_all(filters(n).value, model_rate,...
        METHOD,filters(n).name, filters(n).label, filters(n).subblock, ...
        turnon, ramptime);
    
    %disp(s);
 
    write_filter_coe(foton_filename,s);
%     write_filter_coe_nodesignstring(foton_filename,s);
end

[final_status,logfilename] = autoquack_foton_cleaner('final',foton_filename);
if final_status == 2
    error('something is wrong with the starting foton file')
    disp('the logfile is')
    disp(logfilename);
end

disp('   Checking foton file to see if filters got implemented correctly')
result = autoquack_conversion_check(foton_filename, filters, 'normal');

if result == 1
    disp('all filters were correctly converted!')
elseif result == 2
    disp('at least one filter got messed up, please follow up...')
end

disp('Autoquack process complete')

