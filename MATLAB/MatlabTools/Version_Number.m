%Version_Number gets the version of the "Unit Specific Testing Scripts" you
%are currently running and cd to the folder of the corresponding routines

function [Version]=Version_Number(file)

Path_Script_In_Use=which(file);
Version=Path_Script_In_Use(end-2);
Routines_Folder=['/ligo/svncommon/SeiSVN/seismic/HAM-ISI/Common/Control_Generic_Scripts_HAM_ISI/Version_' Version];
cd (Routines_Folder);
disp('Routines Used: ');
disp(Routines_Folder);
disp(' ');
end