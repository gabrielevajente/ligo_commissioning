%-------------------------------------------------------------------------
%
% This script is common to all ISI TF measurements
%-----------------------------------------------------------------------
% Generate Drive Signal
%  same for all the excitations, apart from gain

% number of repetitions to skip at beginning and end of excitation
Nskip = 1;

% check fRes
fRes0 = fRes;
Nf = round(data_rate / (2 * fRes));
fRes = data_rate / (2 * Nf);
if abs(1 - fRes / fRes0) > 0.01
  disp(sprintf('fRes changed from %g to %g to match data rate %d', ...
    fRes0, fRes, data_rate));
end

% generate drive vector (reps will be applied later in comb_TF)
exc_data = get_comb_timeseries(exc_rate, fRes, 1, fMin, fMax);

% plot the excitation
exc_t = (0:numel(exc_data) - 1)' / exc_rate;
figure(33)
plot(exc_t, exc_data)
clear exc_t

%-----------------------------------------------------------------------
% do the work - this should be a sub function... multiexc_comb_TF

% Make up the proper file name with timestamp for uniqueness.
now_str = datestr(now, 'yyyymmdd-HHMMSS');
file_name = [file_description,'_',now_str,'.mat'];
file_name_exc = [file_description,'_exc_',now_str,'.mat'];
save_file = [data_directory,'/',file_name_exc];

%%%%----


%%%%% This time estimate needs work
% time_estimate = 1.15*num_exc * (20 + (Nreps + 2) / fRes + 2 * num_resp);
time_estimate = 1.15*num_exc * (20 + (Nreps + 2) / fRes);  % Suppressed the "+ 2 * num_resp" 


disp('------------------------------------------------');
disp('begin taking transfer functions');
disp(sprintf('  measurement should take about %2.1f minutes to complete', ...
                  time_estimate / 60))
disp('  '); 
disp('5 second Pause, Control C to abort');
pause(5);


% and what to do next
param_exc = [];
save(save_file, 'param_exc', 'file_name');
fprintf(1, 'load with: Run_TF_get(''%s'', ''%s'', %d);\n', ...
    data_directory, file_name_exc, num_exc);

%file_description = 'Data_2_8Hz';    % timestamp is automatically added
%data_directory = pwd;               % or specify elsewhere

% build parameter struct for comb_TF
param.State_Value = State_Value;
param.Comment = Comment;
param.file_name = file_name;
param.fRes = fRes; 
param.fMin = fMin;
param.fMax = fMax;
param.Nreps = Nreps; 
param.Nskip = Nskip;
 

param.exc_chan = {};  % set in each iteration of the loop
param.exc_rate = exc_rate;
param.exc_data = [];  % set in each iteration of the loop (to apply exc_scale)

param.num_skip = Nskip;
param.num_reps = Nreps;
param.readback_chan = {};  % set in each iteration of the loop
%param.resp_chan_list = resp_chan_list;
param.resp_range = resp_range;
param.data_rate = data_rate;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% start loop over excitations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tic;  % start timer
for n = 1:num_exc
  
  % Check_Quad_Status  
  
   
   % update time estimate
    disp('  ');    
    disp(sprintf('----------------- Starting Loop number %d of %d', n, num_exc));
    
     %Reset_Saturation_Counters
    
    
%     %reset all saturation counters to zero
%     for kk = 1:6  %Reset actuator saturation counters
%         system(['ezcawrite M1:ISI-CD_CS_Sat_Reset_',num2str(kk-1),' 1']); %reset satuation counter
%         pause(0.1);
%         system(['ezcawrite M1:ISI-CD_FN_Sat_Reset_',num2str(kk-1),' 1']); %reset satuation counter
%          pause(0.1);
%         system(['ezcawrite M1:ISI-CD_CS_Sat_Reset_',num2str(kk-1),' 0']); %enable satuation counter
%          pause(0.1);
%         system(['ezcawrite M1:ISI-CD_FN_Sat_Reset_',num2str(kk-1),' 0']); %enable satuation counter
%          pause(0.1);
%     end
% 
% 

    
    if n > 1
       n_done = n - 1;
       time_elapsed = toc;
       time_estimate = (num_exc - n_done) * (time_elapsed / n_done) / 60;
       disp(sprintf('Approximately %2.1f minutes remaining', time_estimate));
    end
    % excitation readbacks
    readback_chan_list = exc_chan_list;
   
    %moved this over from the Run_freq file 1/16/08  rkm
    for jj = 1:num_exc
        exc_chan = exc_chan_list{jj};
        if ~isempty(str2num(exc_chan(end-2:end)))
           disp('Stopped in Excitation channel Name creation')
           disp('Remove from calling program or Check foramt??');
           keyboard
        end
        if data_rate == 512   %make match the data rate
           readback_chan_list{jj} = [exc_chan, '_512'];
%         elseif data_rate == 2048   %make match the data rate
%            readback_chan_list{jj} = [exc_chan, '_2048'];  % mevans HEPI
        elseif data_rate == 4096
           readback_chan_list{jj} = [exc_chan,'_DAQ'];
        else
           disp('Bad Data Rate')
           keyboard
        end
    end
  
  
    % set parameters for this excitation
    param.exc_chan = exc_chan_list{n};
    param.exc_data = exc_data * exc_scale(n);
    param.readback_chan = readback_chan_list{n};

    % run the excitation (in verbose mode)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if n == 1
      param_exc = comb_TF_exc(param);
    else
      param_exc(n) = comb_TF_exc(param);
    end
    % save the excitation parameters so far
    save(save_file, 'param_exc', 'file_name');
    fprintf(1, 'Updated excitation parameter file:\n%s\n', save_file);
    
    if exist(param_file_name)
       load param_file_name
       
      fprintf(fid, 'Updated excitation parameter file:\n%s\n', save_file);
    else
      warn('Running without analyizing'); beep;pause(0.25);beep;pause(0.25);beep
    end

%      for kk = 1:6  %Download number of actuator saturations during run
%         [Flag str] = system(['ezcaread -n M1:ISI-CD_CS_Sat_tot_',num2str(kk-1)]); %reset satuation counter
%         Coarse_act_sat(kk) = str2num(str);
%         [Flag str] = system(['ezcaread -n M1:ISI-CD_FN_Sat_tot_',num2str(kk-1)]); %reset satuation counter 
%         Fine_act_sat(kk) = str2num(str);
%      end
    
    %store actuator saturations
%      result(n).Coarse_act_sat = Coarse_act_sat;
%      result(n).Fine_act_sat =  Fine_act_sat;
    
end


% show elapsed time
toc

% and what to do next
fprintf(1, 'next: Run_TF_get(''%s'', ''%s'');\n', ...
    data_directory, file_name_exc);
