% Load_Path_SEI_Common(Schroeder_Phase_Scripts_Version)
% VL - January 23 - 2013
% This function loads the common matlab scripts in the Matlab path

function Load_Path_SEI_Common(Schroeder_Phase_Scripts_Version)
current_path=pwd;
tic
addpath(genpath('/ligo/svncommon/SeiSVN/seismic/Common/MatlabTools/'))
addpath(genpath(['/ligo/svncommon/SeiSVN/seismic/Common/MatlabTools/Schroeder_Phase_Scripts/',Schroeder_Phase_Scripts_Version]))
disp('SEI path loaded')
toc
cd(current_path)
end