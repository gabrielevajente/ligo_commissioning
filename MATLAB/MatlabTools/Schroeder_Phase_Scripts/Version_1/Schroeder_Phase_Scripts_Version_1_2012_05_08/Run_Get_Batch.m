%% Run_Get_Batch(IFO,Subsystem,Chamber,Old_Data)
% Example: Run_Get_Batch('H2','Subsystem','ITMY','batch_file_XXXX.mat')

% This scripts loads and process the measurements
% It is made of a loop that watches for more work to appear in batch_file.mat
% Run_TF_get loads individual measurement

function Run_Get_Batch(IFO,Subsystem,Chamber,Old_Data)

if nargin<4
    batchFileName = 'batch_file.mat';
else
    batchFileName = ['/Batch_file_Archive/' ,Old_Data];
end

path('/ligo/svncommon/SeiSVN/seismic/Common/MatlabTools/Schroeder_Phase_Scripts',path);
path('/usr/share/libtool/libltdl',path);  % i think that this is where configure lives, it's used in get_long_comb_TF to reset CONFIG when get_data fails

batchInfo.batch_file_directory = ['/ligo/svncommon/SeiSVN/seismic/',Subsystem,'/',IFO,'/',Chamber,'/Data/Transfer_Functions/Measurements/'];
load_file = [batchInfo.batch_file_directory  '/' batchFileName];
Use_THIS_List = 0;
resp_range = 2^15 -1000;
resp_struct.resp_range = resp_range; 
resp_struct.control =  Use_THIS_List    

% contains fileList
loadWithRetry(load_file);
nNext = 1;
data_directory= batchInfo.data_directory

while true 
  loadWithRetry(load_file);
  if numel(batchInfo.file_name_exc) == nNext - 1
    fprintf('\nWatching %s for more parameter files...\n', batchFileName);
  end
  
  nWait = 0;
  while numel(batchInfo.file_name_exc) == nNext - 1
    pause(10)
    loadWithRetry(load_file);
    
    nWait = nWait + 1;
    if nWait > 360
      fprintf('\nStill watching %s for more parameter files...\n', batchFileName);
      nWait = 0;
    end
  end
  
  if numel(batchInfo.file_name_exc) < nNext - 1
    fprintf('\n%s shrank... starting over.\n', batchFileName);
    nNext = 1;
  end
  
  % start working on this file
%   file_name_exc = batchInfo.file_name_exc{nNext};
  batchInfo.nNext=nNext;
%   num_exc = batchInfo.num_exc(nNext);
  
%   fprintf('================================================ %d', nNext)
%   fprintf('\nProcessing %s\n from batch file %s\n', ...
%       file_name_exc, load_file);

fprintf('================================================ %d', nNext)
  fprintf('\nProcessing %s\n from batch file %s\n', ...
      batchInfo.file_name_exc{batchInfo.nNext}, load_file);
  


%   
%   Run_TF_get(data_directory, file_name_exc, num_exc,resp_struct);
  Run_TF_get(batchInfo,resp_struct)
  nNext = nNext + 1;
end
