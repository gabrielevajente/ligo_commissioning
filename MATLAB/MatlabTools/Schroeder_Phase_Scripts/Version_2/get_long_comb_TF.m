% result = get_long_comb_TF(param, isVerbose)
%   measure transfer functions from a given excitation to
%   a collection of response channels
%
% param struct must contain
%   exc_start - excitation start GPS
%   exc_period - length of excitation signal (seconds)
%   num_reps - number of repetitions to use for TF
%   num_skip - number of repetitions to skip before measuring TF
%   readback_chan - excitation readback channel
%   resp_chan_list - list of response channels (N x 1 cell array)
%   resp_range - saturation level for each resp channel (N x 1 vector)
%   data_rate - readback and resp channel data rate
%
% result struct will contain
%   num - number of TFs measured ( = number of resp channels = N)
%   max - maximum value for each channel (N x 1 vector)
%   min - minimum value for each channel (N x 1 vector)
%   mean - mean value for each channel (N x 1 vector)
%   rms - RMS, after detrending, for each channel (N x 1 vector)
%   num_sat - number of saturations in each channel (N x 1 vector)
%   f - frequency vector for transfer functions and coherence (Nf x 1)
%   tf - transfer functions (Nf x N)
%   coh - coherences (Nf x N)
%   pow_exc - power spectrum of excitation (Nf x 1)
%
% The data is read from exc_start with duration data_length
%   data_length = ceil(exc_period * (num_reps + num_skip));
%

function result = get_long_comb_TF(param, isVerbose)

  global data_call_number CONFIG
 
  %------------------------------------------------------------------------
  % Get the data

  % GPS start and stop times for data reading
  exc_start = param.exc_start;
  data_length = ceil(param.exc_period * (param.num_reps + param.num_skip));
  %data_rate = param.data_rate;
  resp_range = param.resp_range;
  
  %%%% get the excitation readback channel
   
    counter=0; 
    data_call_number = 0;
  data_success = 0;
  while counter<100 && data_success == 0;
     
    counter = counter + 1;
    
    try
      % read the data from the frame-builder
      data_call_number = data_call_number+1;
%       
      [exc_data param.exc_rate] = get_raw_data(param.readback_chan, exc_start, ...
      data_length,  param.exc_rate, isVerbose);
      data_success = 1;
      exc_data = exc_data{1};
      if param.model_rate == 0;
          param.model_rate = param.exc_rate;
      end
      
          %debug line to check for time mismatches
        if sum(abs(exc_data(1:100))) == 0 || sum(abs(exc_data((end-100):end))) == 0
          warning(['There is probably a data timing mismatch in ',param.exc_chan]);
          disp(['Warning in get_long_comb_TF.m  line 67    ',num2str([sum(abs(exc_data(1:100))), sum(abs(exc_data((end-100):end)))])]);
        end
      
    catch
        cprintf([1 0 0.5],['Data read failed. Attempt #',num2str(counter),'\n'])
        error_message=lasterror ;
        error_message.message
        try
%         CONFIG.SITE = 'M';  %M = MIT configure needs to get fixed to be made more general for anerien/athens
%         CONFIG.METHOD = 'NDS';
        configure
        CONFIG.channels = NDS_GetChannels(CONFIG.nds_server);
        catch
            cprintf([0.6 0.2 0.2],['\nWas unable to run configure.m This function attempts to repair the CONFIG variable\n', ... 
                                     'The most common problem is thatyou are asking for a channel which is not being stored on the frame builder\n',...
                                     'Try checking for it in dataviewer\n\n']);
        end
        data_success = 0;
    end
  end
  
  if exist('exc_data','var');
      if sum(abs(exc_data)) == 0
          error('The excitation reads back as all zeros!')
      end
  else
      error('oops at start tim ',num2str(exc_start),' From file ',param.file_name);
 end
  
  %%%% loop over response channels
  num_resp_chan = numel(param.resp_chan_list);
  next_channel = 1;
  while  next_channel <= num_resp_chan
      %for nn = 1:num_resp_chan
      
      counter=0;
      data_success = 0;
      while counter<100 && data_success == 0;
          counter = counter + 1;
          max_rate = max([param.data_rate param.exc_rate param.model_rate]);
%           try  % read the data from the frame-builder
              
              % For more speed I'm going to resurect the multiple channels at
              % once option, say that 100MB is the maxium size that I want to
              % download, unfortunately the drive sample rate might not be the
              % fast rate that we are downloading, so through in another factor
              % of 2
              num_download_channels = floor((1E8/2)/(4*max_rate*data_length)); %how man channels can we read at once
              if num_download_channels < 1
                  num_download_channels = 1;
              end
              if (next_channel+num_download_channels-1) <=  num_resp_chan 
                    current_down_load_channels = next_channel:(next_channel+num_download_channels-1);
              else
                  current_down_load_channels = next_channel:num_resp_chan;
              end
              %current_down_load_channels = 1:5;
              data_call_number = data_call_number+1;
              
              [resp_data param.data_rate(current_down_load_channels)]= get_raw_data(param.resp_chan_list(current_down_load_channels), exc_start, ...
                  data_length, param.data_rate(1), isVerbose);
               
              data_success = 1;
              %cprintf([0 0 0.75],['Data Rate is ',num2str(param.data_rate(nn)),'\n']);
              
              for kk = 1:length(resp_data)
                  if sum(abs(resp_data{kk})) == 0
                     cprintf([0.75 0.3 0.3],['The data is all zeros!!   in channel ',param.resp_chan_list{current_down_load_channels(kk)},'\n']);
                      disp('Message in get_long_comb_TF line 104');
                  end
              end
              
%           catch
%               disp(['Data read failed. Attempt #',num2str(counter)])
%               error_message=lasterror;
%               disp(error_message.message);
%               CONFIG.SITE = 'M';
%               CONFIG.METHOD = 'NDS';
%               configure
%               CONFIG.channels = NDS_GetChannels(CONFIG.nds_server);
%               data_success = 0;
%           end
      end
      
      %       resp_data = get_raw_data(param.resp_chan_list{n}, exc_start, ...
      %         data_length, data_rate, isVerbose);
      
      % compute the results
      for kk = 1:length(resp_data)
          param.num_fft(current_down_load_channels(kk)) = 2 * ceil(param.exc_period * min(param.data_rate(current_down_load_channels(kk)),param.exc_rate) / 2);
      end
      %--------------------------
      % Problem on this line
      %% param.resp_range = resp_range(n);  % send just this range, used to check for instrument saturations
      for jj = 1:length(current_down_load_channels)
          if length(resp_range) >= current_down_load_channels(jj)
              param.resp_range = resp_range(current_down_load_channels(jj));  % send just this range, used to check for instrument saturations
          else
              param.resp_range = resp_range(end);
          end
          %loop over multiple channels here
          result_n = compute_TF(param, resp_data{jj}, exc_data,current_down_load_channels(jj));
          
          % compile results
          if current_down_load_channels(jj) == 1
              result = result_n;
          else
              if sum(result_n.f) > sum(result.f)
                  result.f = result_n.f;
              end
              result.max(current_down_load_channels(jj), 1) = result_n.max;
              result.min(current_down_load_channels(jj), 1) = result_n.min;
              result.mean(current_down_load_channels(jj), 1) = result_n.mean;
              result.rms(current_down_load_channels(jj), 1) = result_n.rms;
              result.num_sat(current_down_load_channels(jj), 1) = result_n.num_sat;
              
              
              %debuging line
              if size(result.tf,1) ~= size(result_n.tf,1)
                  disp('goofed up data set');
              end
              result.tf(:, current_down_load_channels(jj)) = result_n.tf;
              result.coh(:, current_down_load_channels(jj)) = result_n.coh;
              result.Coarse_act_sat = result_n.Coarse_act_sat;
              result.Fine_act_sat =  result_n.Fine_act_sat;
              result.param = result_n.param;
          end
      end
     next_channel = current_down_load_channels(end) + 1;
  end
 
  result.num = num_resp_chan;
  
  return
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% this function uses get_data, inspects the result, and then
% returns only the data vector
%
function [data data_rate] = get_raw_data(data_chans, gps_start, ...
    data_length, data_rate, isVerbose)

global data_call_number


 actual_data_rate = [];
% wrap a single channel as a cell
if ~iscell(data_chans)
    data_chans = {data_chans};
end
Nchan = numel(data_chans);

% report what we are about to do
pause(1)                                         % be sure not to ask for data too rapidly
waitForGPS(gps_start + data_length + 10, true);  % give the data a little time to arrive
if isVerbose
    if Nchan == 1
        disp(sprintf('%.1f: Getting mDV data for %s (start %d, duration %d): Call number %d', ...
            gps_now, data_chans{1}, gps_start, data_length, data_call_number ));
    else
        disp(sprintf('%.1f: Getting mDV data for channels (start %d, duration %d):', ...
            gps_now, gps_start, data_length));
        disp(data_chans);
    end
end
if data_rate*data_length*4 >1E8  % get_data has a limit of 128Mbyte (4 bytes/pt) added 10/24/11 RKM
    disp(['you are asking for a lot of data (',num2str(4*data_rate*data_length/1E6),'Mbytes) getting in chunks'])
    start_time = gps_start;
    short_data_length = 1000*floor(1E5/(4*data_rate)); %down load in chunks of 100Mb
    data = {[]};
    data_time = 0;
    while data_time < data_length
        if short_data_length >0
            raw_data = get_data(data_chans, 'raw', start_time,short_data_length);
            actual_data_rate  = raw_data.rate;
            if size(raw_data.data,2) > size(raw_data.data,1)  
                raw_data.data = transpose(raw_data.data);
            end
             data = {[data{1};raw_data.data]};
            
            data_time = data_time+ short_data_length; % keep track of how much data we have gotten
        end
        start_time = start_time + short_data_length;      %start time for next data segment
        if (gps_start+data_length-start_time) <= short_data_length           %last data segment condition
            short_data_length = (gps_start+data_length-start_time);
        end
    end
else
    % read the data from the frame-builder
    raw_data = get_data(data_chans, 'raw', gps_start, data_length);
    if isempty(raw_data(1).data)
        cprintf([1 0.5 0],['\n No data was returned for channel(s) starting at ',data_chans{1},' \n']);
        cprintf([1 0.5 0],['In get_raw_data, (a subroutine in get_long_comb_tf)\n']);   
         cprintf([1 0.5 0],['Maybe a bad channel name?\n']);
        error('crashing now, have a nice day');
    end
    for zz = 1:length(raw_data)
        data{zz} = raw_data(zz).data;
        actual_data_rate(zz) = raw_data(zz).rate;
    end
end


%actual_data_rate = raw_data.rate;  %add line 8/20/10 for variable sensor data rate
if isempty(actual_data_rate)
    cprintf([0.75 0.3 0],'********* WARNING NO DATA WAS RETURNED **********\n');
    temp = input('Pausing now, input something to continue   ','s');
else
    data_rate = actual_data_rate;
end

num_nans = 0;
for zz = 1:length(data_chans)
    num_nans = num_nans+ sum(isnan(raw_data(zz).data));
end
if num_nans > 0
    cprintf([1 0.5 0],'Got NAN for excitation amplitude data, time to crash\n');
    keyboard
end


% check number of channels
if numel(raw_data) ~= Nchan
    error('get_data returned the wrong number of channels');
end

%   % get data rate
%   if any([raw_data.rate] ~= data_rate)
%     disp(sprintf('Required data rate %d', data_rate));
%     error('All response channels must have this data rate')
%   end

% check data length
%num pts/sec * num seconds
for n = 1:numel(raw_data)
     num_points = data_rate(n) * data_length;  %num pts/sec * num seconds
    num_points_raw = max(size(data{n}));
    if num_points_raw ~= num_points
        error('%s got %d points, wanted %d (rate = %d, duration %f)', ...
            data_chans{n}, num_points_raw, num_points, data_rate, data_length);
    end
end


