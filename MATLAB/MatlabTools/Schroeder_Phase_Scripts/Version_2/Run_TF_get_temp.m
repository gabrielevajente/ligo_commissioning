% result = Run_TF_get(data_directory, file_name_exc, num_exc)
%   computes results of excitations made by Run_TF_exc
%
% file_name_exc - file produced by Run_TF_exc.  contains
%   param_exc - excitation and measurement parameters (see comb_TF_get)
%   file_name - name of file to save results in
%
%  09/20/11  add frame_builder_failure_time so that I can get the data
%  after that time  rkm
%

function result = Run_TF_get(batchInfo,resp_struct,frame_builder_failure_time,varargin)
%  12/13/11  redefiing input aguments to pass bacthInfo, which now has all
%  data paths and file names in it
% make an awkward if else structure to try and maintain backwards
% compatibility
      
% Run_TF_get(data_directory,  file_name_exc,      num_exc,     resp_struct,    frame_builder_failure_time)

if length(varargin) == 2 % Old Format with failure time
   data_directory = batchInfo;
   file_name_exc = resp_struct; 
   Exc_directory= data_directory;
   num_exc = frame_builder_failure_time;
   resp_struct = varargin{1};
   frame_builder_failure_time = varargin{2};
elseif length(varargin) == 1 % Old Format without failure time
   data_directory = batchInfo;
   file_name_exc = resp_struct; 
   Exc_directory= data_directory;
   num_exc = frame_builder_failure_time;
   resp_struct = varargin{1};
   frame_builder_failure_time =0;
else
   Exc_directory = batchInfo.Exc_directory;
   try %exceptionally ugly patch, need to fix
        data_directory = batchInfo.data_directory;
   catch
       data_directory =Exc_directory;
   end
   file_name_exc = batchInfo.file_name_exc{batchInfo.nNext};
   num_exc =batchInfo.num_exc;
   if ~exist('frame_builder_failure_time','var');
       frame_builder_failure_time  = 0;
   end
end         
 

  %data_directory = '/ligo/svncommon/SeiSVN/seismic/HEPI/M1/BSC/Data/Transfer_Functions/Local_to_Local';
 
% load the excitation paramter file
param_file = [Exc_directory,'/',file_name_exc];
%param_file = file_name_exc;
loadWithRetry(param_file);

% construct the results file name
save_file = [data_directory,'/',file_name];
try
    ss_save_file =  [data_directory,'/',file_name_ss];  %if it exists this name will be for single frequency data
catch
   % save_file = [data_directory,'/',file_name];
end

% if number of excitations is not specified, use param_exc size
% if nargin < 3
%     num_exc = numel(param_exc);
% end

% if nargin <4
%     disp('You have not specified a response channels list will look for one in the parameter file');
% end
%  
% if nargin < 5
%      frame_builder_failure_time = 0;
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% start loop over excitations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tic;  % start timer
for n = 1:num_exc
    
    % reload the excitation paramter file, in case it changed
    if numel(param_exc) < n
        cprintf([0 0.5 0.5],'\nWatching %s for excitation %d of %d...\n', ...
            param_file, n, num_exc );
    else
        cprintf([0 0.25 0.5],['\nProcessing ',param_file,' excitation ',num2str(n),' of ',num2str(num_exc),'...\n']);
          %  param_file, n, num_exc);
    end
    
    % wait for excitation parameters to appear
    while numel(param_exc) < n
        loadWithRetry(param_file);
        pause(10);
    end
    
    % wait for the data
    waitForGPS(param_exc(n).exc_end + 10);
    
    %if the there is no resp_chan_list defined in the param structure from
    %the exictation program or it is empty use the one from the get program
    % or the control is set to use this list
    if resp_struct.control || isempty(strmatch('resp_chan_list',fields(param_exc(n)))) || isempty( param_exc(n).resp_chan_list)
        param_exc(n).resp_chan_list = resp_struct.resp_chan_list;  %added 8/30/10
        param_exc(n).resp_range = resp_struct.resp_range;  %added 8/30/10
    end
    
    %added 1/4/12 so that I can process 'DAQ' data
    resp_struct_fields = fields(resp_struct);
    if isempty(strmatch('old_names',resp_struct_fields))
        resp_struct.old_names = 0;
    end
    if resp_struct.old_names
        param_exc(n).readback_chan(end-1:end+1) = 'DAQ';
    end
    
    if  param_exc(n).exc_start > frame_builder_failure_time
        
        % run the transfer function maker (in verbose mode)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        result(n) = comb_TF_get(param_exc(n),true);
        
        % limit TF data range  now done in compute_tf
        %   fMin = param_exc(n).fMin;
        %   fMax = param_exc(n).fMax;
        %   nTF = find(result(n).f >= fMin & result(n).f <= fMax);
        %
        %   result(n).f = result(n).f(nTF);
        %   result(n).tf = result(n).tf(nTF, :);
        %   result(n).coh = result(n).coh(nTF, :);
        
          % check for saturations
        n_sat = find(result(n).num_sat > 0);
        for m = 1:numel(n_sat)
            disp(sprintf('%d saturations on %s', result(n).num_sat(n_sat(m)), ...
                result(n).param.resp_chan_list{n_sat(m)}));
        end
        
        
        % save the results so far
        try
        if result(n).param.stepped_sine_switch == 1         
            save_data_file = ss_save_file;
        else
            save_data_file = save_file;
        end
        catch
            save_data_file = save_file;
        end
        save(save_data_file, 'result');
        fprintf(1, 'Updated results file:\n%s\n', save_data_file);
        
       
        
        % display some data
        %subplot(2, 2, 1)
        %loglog(result(n).full_freq, result(n).full_pow_exc)
        %title('Excitation power spectrum')
        % set(gca,'YLim',[0.9*min(result(n).pow_exc) 1.1*max(result(n).pow_exc)]);
        
        %subplot(2, 2, 2)
        %loglog(result(n).f, abs(result(n).tf))
        %legend(escformat(resp_chan_list),2)
        %title('Transfer function magnitudes')
        
        %subplot(2, 2, 3)tf
        %semilogx(result(n).f, result(n).coh)
        %title('Transfer function coherences')
        
        %subplot(2, 2, 4)
        %semilogx(result(n).f, angle(result(n).tf) * 180 / pi)
        %title('Transfer function phases')
        %drawnow
        
    else
        cprintf([0.5 0 0.75],['Skipping data analysis because it has started before the specified frame builder set time (',num2str(param_exc(n).exc_start,11),')\n'])
    end
end

% show elapsed time
toc
