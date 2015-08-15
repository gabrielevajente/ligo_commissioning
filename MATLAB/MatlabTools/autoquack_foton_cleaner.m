function [success_flag, logfile_name_recent] = autoquack_foton_cleaner(call_tag, foton_filename)
% autoquack_foton_cleaner   cleans up the foton file before and after autoquack
% On July 2015, autoquack was updated to essentially run a ">foton -c" 
% on the foton filter file at the beginning and end of the filter update
% process and log the results. 
% See integration issue XXX at http:
%
%    This function does all the actual work for that change.
% This is a pair of closely related auxilliary functions to clean the 
% foton file before and after it has been updated by autoquack
% At the beginning of autoquack, it is called with
% [initial_status] = autoquack_foton_cleaner('initial',foton_filename);
%    foton_filename is the full path name of the model (returned by get_filenames)
%    This "cleans" the foton file before autoquack does anything.
%    If this is a new foton file, this will create all the slots to put the
%      filter coefficients into. 
%    If the foton file was last updated by an older version of autoquack,
%      then this will probably result in lots of warnings about missing
%      design strings. 
%    If the file was last touched by foton, or autoquack after July 2015,
%      then nothing should happen.
% initial_status:   
%    0: no change to the foton file or
%       foton file was updated and function completed. You should look at the
%       log file to see what foton did.
%    2: the cleaner function failed, but somehow completed anyways
%
% [final_status, logfile_name] = autoquack_foton_cleaner('final', filenames);
%    This cleans up the foton file after autoquack writes in the new filter
%    coefficients. You would expect that foton will add a design string to
%    each new filter.
%    Foton will also subtly alter each of the filters. This is a ''feature''.
% final_status:   
%    0: foton file was updated, function completed. You should look at the
%       log file to see what foton did.
%    2: the cleaner function failed, but somehow completed anyways.
% logfile_name: this is the text file with the foton -c logging.
%
% Brian Lantz, July 14, 2015
% SVN $Id$


%filenames = get_filenames('s1isiitmx');

success_flag = 2;  % set at 'fail' to start.

% this is just silly, and likely to break: 
pat = '\w+\.txt';
mdl_name_cell = regexp(foton_filename, pat, 'match');
mdl_name = mdl_name_cell{1};
filenames = get_filenames(mdl_name);

logfile_name_all    = filenames.autoquack_logfile_all;
logfile_name_recent = filenames.autoquack_logfile_recent;
%logfile_name = [filenames.chans_dir,'temp.txt'];
[status, result] = system(['touch ',logfile_name_all]);
if status ~= 0
    disp('unable to touch the autoquack log file')
    disp('the log file should be:')
    disp(logfile_name_all)
    disp('the system error is:')
    disp(result)
    error('can''t touch this')
end


if strncmpi(call_tag,'initial',4)             %    this is the initial call   %%
    
    %initial_command = 'Halt and Catch fire';
    initial_command = ['foton -c ',filenames.foton_chans,' >> ',logfile_name_recent];

    FID = fopen(logfile_name_recent, 'w');    % open a new, clean file
    fprintf(FID,'====================\n');
    fprintf(FID,['This is a log file created by autoquack on ',datestr(now)]);
    fprintf(FID,' with output from foton -c\n');
    fprintf(FID,'The initial call is:\n');
    fprintf(FID,'%s\n',initial_command);
    fprintf(FID,'  --   log from initial cleanup follows   --\n');
    fclose(FID);
    
    [status, result] = system(initial_command);  
    if status == 0
        disp('initial foton call succeeded')
        success_flag = 0;
    else
        disp('failed initial command')
        disp('the call was:')
        disp(initial_command)
        disp('the system error is:')
        disp(result)
        error('failed initial foton -c call')
    end
    
    
        
elseif strncmpi(call_tag, 'final',4)           %    this is the completion call
    disp('starting foton cleanup process');
    final_command_1 = ['foton -c ',filenames.foton_chans,' >> ',logfile_name_recent];
    final_command_2 = ['cat ',logfile_name_recent,' >> ',logfile_name_all];

    FID = fopen(logfile_name_recent, 'a');    % add to the existing file
    fprintf(FID,'  --  log from final cleanup  --\n');
    fclose(FID);
    
    [status, result] = system(final_command_1);  
    if status == 0
        disp('final foton call succeeded')
    else
        disp('failed final command')
        disp('the call was:')
        disp(final_command_1)
        disp('the system error is:')
        disp(result)
        error('failed initial foton -c call')
    end
    
    [status, result] = system(final_command_2);
    if status == 0
        disp('log file updated')
        disp('please review the recent foton -c log file at')
        disp(logfile_name_recent)
        success_flag = 0;
    else
        disp('failed final command')
        disp('the call was:')
        disp(final_command_2)
        disp('the system error is:')
        disp(result)
        error('failed initial foton -c call')
    end


else                                           %    and this is one version of failure
    disp('autoquack_foton_cleaner should be call with either ''initial'' or ''final''');
    disp('   you should try')
    disp('help autoquack_foton_cleaner')
    success_flag = 2;
end
return


