% Load_Path_SEI_Common(IFO,CHAMBER, Control_Scripts_Version)
% VL - January 23 - 2013
% This function loads the HEPI matlab scripts in the Matlab path

function Load_Path_HEPI(IFO,CHAMBER,Control_Scripts_Version,Testing_Scripts_Version)

disp('');
disp('HEPI path starts loading')
tic
warning off

%% Removing path (HAM-ISI & BSC-ISI)
rmpath(genpath('/ligo/svncommon/SeiSVN/seismic/BSC-ISI'))
disp('rmpath(/ligo/svncommon/SeiSVN/seismic/BSC-ISI)')

rmpath(genpath('/ligo/svncommon/SeiSVN/seismic/HAM-ISI'))
disp('rmpath(/ligo/svncommon/SeiSVN/seismic/HAM-ISI)')

%% Adding the common parts to HEPI
addpath(genpath('/ligo/svncommon/SeiSVN/seismic/HEPI/Common'))
disp('addpath(/ligo/svncommon/SeiSVN/seismic/HEPI/Common)')

rmpath(genpath('/ligo/svncommon/SeiSVN/seismic/HEPI/Common/Control_Generic_Scripts_HEPI/'))
disp('rmpath(/ligo/svncommon/SeiSVN/seismic/HEPI/Common/Control_Generic_Scripts_HEPI/)')

addpath(genpath(['/ligo/svncommon/SeiSVN/seismic/HEPI/Common/Control_Generic_Scripts_HEPI/',Control_Scripts_Version]))
disp(['addpath(/ligo/svncommon/SeiSVN/seismic/HEPI/Common/Control_Generic_Scripts_HEPI/',Control_Scripts_Version,')'])

rmpath(genpath('/ligo/svncommon/SeiSVN/seismic/HEPI/Common/Plot_Functions_HEPI/'))
disp('rmpath(/ligo/svncommon/SeiSVN/seismic/HEPI/Common/Plot_Functions_HEPI/)')

addpath(genpath(['/ligo/svncommon/SeiSVN/seismic/HEPI/Common/Plot_Functions_HEPI/',Control_Scripts_Version]))
disp(['addpath(/ligo/svncommon/SeiSVN/seismic/HEPI/Common/Plot_Functions_HEPI/',Control_Scripts_Version, ')'])

addpath(genpath(['/ligo/svncommon/SeiSVN/seismic/HEPI/',IFO,'/',CHAMBER])) ;
disp(['addpath(genpath(/ligo/svncommon/SeiSVN/seismic/HEPI/',IFO,'/',CHAMBER]);
rmpath(genpath(['/ligo/svncommon/SeiSVN/seismic/HEPI/',IFO,'/',CHAMBER,'/Scripts/Control_Scripts/'])) ;
disp(['rmpath(genpath(/ligo/svncommon/SeiSVN/seismic/HEPI/',IFO,'/',CHAMBER,'/Scripts/Control_Scripts/']);
addpath(genpath(['/ligo/svncommon/SeiSVN/seismic/HEPI/',IFO,'/',CHAMBER,'/Scripts/Control_Scripts/',Control_Scripts_Version])) ;
disp(['addpath(genpath(/ligo/svncommon/SeiSVN/seismic/HEPI/',IFO,'/',CHAMBER,'/Scripts/Control_Scripts/',Control_Scripts_Version]);

%addpath(genpath(['/ligo/svncommon/SeiSVN/seismic/HEPI/',IFO,'/',CHAMBER,'/Data/Transfer_Functions/Simulations/Paramaters/']));


warning on

disp('HEPI path loaded');
fprintf('\n');
disp('');
toc

clear

end