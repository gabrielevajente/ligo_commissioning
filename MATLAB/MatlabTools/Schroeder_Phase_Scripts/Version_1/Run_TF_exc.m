%-------------------------------------------------------------------------
%
% This script is common to all ISI TF measurements
%
% ==== Variables assumed to be defined:
%
% State_Value = 0;  %0 means both stages unlocked
%                   %1 means stage one locked stage 2 free
%                   %2 means stage one free, stage 2 locked
%                 
% Comment = {'Local to Local - No damping - No control - Quad off'};
%
% file_description = ['Data_10_100Hz_Stage',int2str(Stage_Driven)];
% data_directory = '/data/isi/SysID/DataH';
% 
% % frequencies
% fRes = 1;  
% fMin = 10;
% fMax = 100;
% Nreps = 3;   % number of repetitions (i.e.averages) to process
% 
% % excitation channels
% exc_chan_list = my_exc_chan_list(Stage_Driven);
% num_exc = numel(exc_chan_list);
% 
% %  excitation parameters
% exc_rate  = 2048;             % Hz, must match the channel's DAQ rate
% exc_scale = [1 1 1 1 1 1];     
% 
% % response channels
% resp_chan_list = my_resp_chan_list(Stage_Driven) ;                        
% num_resp = numel(resp_chan_list);
% data_rate = 2048;
%          
% % response saturation range (one sided)
% resp_range = ones(size(resp_chan_list)) * 2^15 - 1000;
%-------------------------------------------------------------------------


%-----------------------------------------------------------------------
% Generate Drive Signal
%  same for all the excitations, apart from gain

% number of repetitions to skip at beginning and end of excitation
Nskip = 1;

if ~exist('Special_Functions','var')
    Special_Functions.Before = {};
    Special_Functions.After = {};
end


% check fRes
fRes0 = fRes;
Nf = round(data_rate / (2 * fRes));
fRes = data_rate / (2 * Nf);
if abs(1 - fRes / fRes0) > 0.01
  disp(sprintf('fRes changed from %g to %g to match data rate %d', ...
    fRes0, fRes, data_rate));
end


% generate drive vector (reps will be applied later in comb_TF)
%  sample rate, resolution, number of repetions, start freqeuncy, stop frequency
if ~exist('shaping_filter','var')
    shaping_filter = tf(1);
end
[exc_data time_vector yMax] = get_comb_timeseries(exc_rate, fRes, 1, fMin, fMax,shaping_filter);

% generate drive vector (reps will be applied later in comb_TF)
%exc_data = get_comb_timeseries(exc_rate, fRes, 1, fMin, fMax);

% plot the excitation
exc_t = (0:numel(exc_data) - 1)' / exc_rate;
figure(33)
plot(exc_t, exc_data)
clear exc_t

%-----------------------------------------------------------------------
% do the work - this should be a sub function... multiexc_comb_TF

if ~strmatch('data_directory',fields(batchInfo))
   batchInfo.Exc_directory = batchInfo.data_directory;
end
    

% Make up the proper file name with timestamp for uniqueness.
now_str = datestr(now, 'yyyymmdd-HHMMSS');
file_name = [file_description,'_',now_str,'.mat'];
file_name_exc = [file_description,'_exc_',now_str,'.mat'];
save_file =  [batchInfo.Exc_directory,'/',file_name_exc]; % [batchInfo.batch_file_directory,'/',file_name_exc];

 
%%%%% This time estimate needs work
time_estimate = num_exc*(20+(Nreps+Nskip)/fRes) ;

disp('------------------------------------------------');
disp('begin taking transfer functions');
cprintf([0 0 0.5], ['  measurement should take about ',num2str(time_estimate/60,3),' minutes to complete\n']);
               
disp('  '); 
disp('5 second Pause, Control C to abort');
pause(5);


% and what to do next
param_exc = [];
save(save_file, 'param_exc', 'file_name');

% save batch info
if exist('batchInfo','var')
  batchInfo.file_name_exc{end + 1} = file_name_exc;
  batchInfo.num_exc(end + 1) = num_exc;
  save(batchInfo.save_file, 'batchInfo');
  save(batchInfo.save_file_backup, 'batchInfo');     
  fprintf(1, '-- added to batch file %s\n', batchInfo.save_file); 
      
else
  fprintf(1, 'load with: Run_TF_get(''%s'', ''%s'', %d);\n', ...
    batchInfo.batch_file_directory, file_name_exc, num_exc);
end


 
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
param.drive_scaling = yMax;
 

param.exc_chan = {};  % set in each iteration of the loop
param.exc_rate = exc_rate;
param.exc_data = [];  % set in each iteration of the loop (to apply exc_scale)

param.num_skip = Nskip;
param.num_reps = Nreps;
param.readback_chan = {};  % set in each iteration of the loop
if exist('resp_chan_list','var');   %trying to maintain backwards compatiblity when moving resp list from excitation to resp 
    param.resp_chan_list = resp_chan_list;
    if exist('resp_range','var');
    param.resp_range = resp_range;
    else
        error('Since you have defined a list of response channels, you must also define a saturation level for all of them (resp_range = 2^ 15 -1000;)');
    end
else
    param.resp_chan_list = [];
    param.resp_range = [];
end
 
 param.data_rate = data_rate;

 save(save_file, 'param_exc', 'file_name');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% start loop over excitations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tic;  % start timer
for n = 1:num_exc
  
   
   % update time estimate
    disp('  ');    
    disp(sprintf(['----------------- Starting Loop number %d of %d at ',datestr(clock)], n, num_exc));
    
       
    %  
    %   Need to have a system switch here for system specific operations
    %   that are preformed at the start of every loop
    %
    if ~exist('SYSTEM','var');
        SYSTEM = 'BSC-ISI';
    end
    switch SYSTEM
        case 'BSC-ISI'
            %Check_Quad_Status
            %Reset_Saturation_Counters           
    end
    
    disp(['Driving Channel ',exc_chan_list{n}]);
    
    if n > 1
       n_done = n - 1;
       time_elapsed = toc;
       time_estimate = (num_exc - n_done) * (time_elapsed / n_done) / 60;
       disp(sprintf('Approximately %2.1f minutes remaining', time_estimate));
    end
    % excitation readbacks
    readback_chan_list = exc_chan_list;
   
    %moved this over from the Run_freq file 1/16/08  rkm
    %channel name formating
    for jj = 1:num_exc
        exc_chan = exc_chan_list{jj};
        if ~isempty(str2num(exc_chan(end-2:end)))
           disp('Stopped in Excitation channel Name creation')
           disp('Remove from calling program or Check foramt??');
           keyboard
        end
        readback_chan_list{jj} = [exc_chan, '_DQ'];
    end
  
  
    % set parameters for this excitation
    param.exc_chan = exc_chan_list{n};
    param.exc_data = exc_data * exc_scale(n);
    param.readback_chan = readback_chan_list{n};
    param.exc_amplitude = exc_scale(n);

    %  Run Special Functions
    %   put chamber or system specific fucntions here
    %
      for kk = 1:length(Special_Functions.Before)
          eval(Special_Functions.Before{kk});
      end
    
    
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
        
    %  
    %   Need to have a system switch here for system specific operations
    %   that are preformed at the end of every loop
    %
    
    %  Run Special Functions
    %   put chamber or system specific fucntions here
    %
      for kk = 1:length(Special_Functions.After)
          eval(Special_Functions.After{kk});
      end
    
    
    switch SYSTEM
        case 'BSC-ISI'
            for kk = 1:6  %Download number of actuator saturations during run
                %[Flag str] = system(['ezcaread -n S1:ISI-ITMX_ST1_CD_Sat_tot_',num2str(kk-1)]); %reset satuation counter
                %Coarse_act_sat(kk) = str2num(str);
                %[Flag str] = system(['ezcaread -n S1:ISI-ITMX_ST2_CD_Sat_tot_',num2str(kk-1)]); %reset satuation counter
%                 [Flag str] = system(['ezcaread -n M1:ISI-CD_FN_Sat_tot_',num2str(kk-1)]); %reset satuation counter
                %Fine_act_sat(kk) = str2num(str);
            end

            % store actuator saturations
            % or result(n).BSC_ISI.Coarse_act_sat  to high light system specific
            % data??
            result(n).Coarse_act_sat = 0;%Coarse_act_sat;
            result(n).Fine_act_sat =  0;%Fine_act_sat;
    end
end

% show elapsed time
toc

% and what to do next
fprintf(1, 'next: Run_TF_get(''%s'', ''%s'');\n', ...
   batchInfo.batch_file_directory, file_name_exc);
