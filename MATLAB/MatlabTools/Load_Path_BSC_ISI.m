% Load_Path_BSC_ISI(IFO,CHAMBER,Version_Control_Scripts,Version_Testing_Scripts)
% VL - January 23 - 2013
% This function loads the BSC-ISI matlab scripts in the Matlab path

function Load_Path_BSC_ISI(IFO,CHAMBER,Version_Control_Scripts,Version_Testing_Scripts)

disp('');
disp('BSC-ISI path starts loading')

tic
warning off
rmpath(genpath('/ligo/svncommon/SeiSVN/seismic/HEPI'))
disp('rmpath(/ligo/svncommon/SeiSVN/seismic/HEPI)')

rmpath(genpath('/ligo/svncommon/SeiSVN/seismic/HAM-ISI'))
disp('rmpath(/ligo/svncommon/SeiSVN/seismic/HAM-ISI)')

addpath(genpath('/ligo/svncommon/SeiSVN/seismic/BSC-ISI/Common'))
disp('addpath(/ligo/svncommon/SeiSVN/seismic/BSC-ISI/Common)')

%% Control Scripts
rmpath(genpath('/ligo/svncommon/SeiSVN/seismic/BSC-ISI/Common/Loops_Design_Functions_BSC_ISI/'))
disp('rmpath(genpath(/ligo/svncommon/SeiSVN/seismic/BSC-ISI/Common/Loops_Design_Functions_BSC_ISI/))')

rmpath(genpath('/ligo/svncommon/SeiSVN/seismic/BSC-ISI/Common/Temp/'))
disp('rmpath(genpath(/ligo/svncommon/SeiSVN/seismic/BSC-ISI/Common/Temp/))')

rmpath(genpath('/ligo/svncommon/SeiSVN/seismic/BSC-ISI/Common/Plot_Functions_BSC_ISI/'))
disp('rmpath(genpath(/ligo/svncommon/SeiSVN/seismic/BSC-ISI/Common/Plot_Functions_BSC_ISI/))')

rmpath(genpath('/ligo/svncommon/SeiSVN/seismic/BSC-ISI/Common/Control_Generic_Scripts_BSC_ISI/'))
disp('rmpath(genpath(/ligo/svncommon/SeiSVN/seismic/BSC-ISI/Common/Control_Generic_Scripts_BSC_ISI/))')

addpath(genpath(['/ligo/svncommon/SeiSVN/seismic/BSC-ISI/Common/Control_Generic_Scripts_BSC_ISI/', Version_Control_Scripts]))
disp(['addpath(genpath(/ligo/svncommon/SeiSVN/seismic/BSC-ISI/Common/Control_Generic_Scripts_BSC_ISI/', Version_Control_Scripts])

addpath(genpath(['/ligo/svncommon/SeiSVN/seismic/BSC-ISI/Common/Plot_Functions_BSC_ISI/', Version_Control_Scripts]))
disp(['addpath(genpath(/ligo/svncommon/SeiSVN/seismic/BSC-ISI/Common/Plot_Functions_BSC_ISI/', Version_Control_Scripts])

%% Testing Functions
rmpath(genpath(['/ligo/svncommon/SeiSVN/seismic/BSC-ISI/Common/Testing_Functions_BSC_ISI/']))
disp(['rmpath(genpath(/ligo/svncommon/SeiSVN/seismic/BSC-ISI/Common/Testing_Functions_BSC_ISI/'])

addpath(genpath(['/ligo/svncommon/SeiSVN/seismic/BSC-ISI/Common/Testing_Functions_BSC_ISI/', Version_Testing_Scripts]))
disp(['addpath(genpath(/ligo/svncommon/SeiSVN/seismic/BSC-ISI/Common/Testing_Functions_BSC_ISI/', Version_Testing_Scripts])



%% Chamber
addpath(genpath(['/ligo/svncommon/SeiSVN/seismic/BSC-ISI/',IFO,'/',CHAMBER]))

rmpath(genpath(['/ligo/svncommon/SeiSVN/seismic/BSC-ISI/',IFO,'/',CHAMBER,'/Scripts/Control_Scripts/']))
disp(['rmpath(genpath(/ligo/svncommon/SeiSVN/seismic/BSC-ISI/',IFO,'/',CHAMBER,'/Scripts/Control_Scripts/'])
addpath(genpath(['/ligo/svncommon/SeiSVN/seismic/BSC-ISI/',IFO,'/',CHAMBER, '/Scripts/Control_Scripts/',Version_Control_Scripts]))
disp(['addpath(genpath([/ligo/svncommon/SeiSVN/seismic/BSC-ISI/',IFO,'/',CHAMBER,'/Scripts/Control_Scripts/',Version_Control_Scripts])

warning on

disp('BSC-ISI path loaded')
toc
disp('');
clear