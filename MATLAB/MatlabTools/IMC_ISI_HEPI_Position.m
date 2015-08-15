%######################################################
%        RECORD INPUT MODE CLEANER POSITION
%######################################################
clear
clc

IFO='H1';

% SEI HAM and HEPI common paths need to be loaded:
   addpath(genpath('/ligo/svncommon/SeiSVN/seismic/Common'))
   addpath(genpath('/ligo/svncommon/SeiSVN/seismic/HAM-ISI/Common'))
   addpath(genpath('/ligo/svncommon/SeiSVN/seismic/HEPI/Common'))


% %############################
% %        ISI POSITION
% %############################
% 
% Chamber='HAM2';
% HAM2_ISI_pos = Offset_STD_CPS_HAM_ISI(IFO, Chamber)
% clear Chamber
% 
% Chamber='HAM3';
% HAM3_ISI_pos = Offset_STD_CPS_HAM_ISI(IFO, Chamber)
% clear Chamber
% 
% 
% %############################
% %       HEPI POSITION
% %############################
% 
% Chamber='HAM1';
% HAM1_HEPI_pos = Offset_STD_IPS_Readback_HEPI(IFO,Chamber,gps_now-300,'','');
% clear Chamber

Chamber='HAM2';
HAM2_HEPI_pos = Offset_STD_IPS_Readback_HEPI(IFO,Chamber,gps_now-300,'','');
clear Chamber

Chamber='HAM3';
HAM3_HEPI_pos = Offset_STD_IPS_Readback_HEPI(IFO,Chamber,gps_now-300,'','');
clear Chamber

