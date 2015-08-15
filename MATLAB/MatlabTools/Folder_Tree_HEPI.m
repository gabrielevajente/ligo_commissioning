% Arborescence_HEPI(IFO,CHAMBER,Version_Control_Scripts)
% HP - September 2013
% This function creates the folder tree for HEPI

% Other unit's folders may interfere with the exist() function,
% which is used extensively in this script. Every unit, of 
% every platform type should be removed from the Matlab
% path before use. 

function Folder_Tree_HEPI(IFO,CHAMBER,Version_Control_Scripts)

cd(['/ligo/svncommon/SeiSVN/seismic/HEPI/',IFO,'/',CHAMBER]);
% warning off
% rmpath(genpath('/ligo/svncommon/SeiSVN/seismic/HEPI/'));
% rmpath(genpath('/ligo/svncommon/SeiSVN/seismic/HAM-ISI/'));
% rmpath(genpath('/ligo/svncommon/SeiSVN/seismic/BSC-ISI/'));
% warning on

Upper_Path=pwd;

if exist('Channels_List') ~=7
    mkdir('Channels_List')
end
if exist('Filters') ~=7
    mkdir('Filters')
end
cd('Filters')

if exist('Foton') ~=7
    mkdir('Foton')
end

if exist('Filters_file') ~=7
    mkdir('Filters_file')
end

if exist('Matlab') ~=7
    mkdir('Matlab')
end

if exist('Foton') ~=7
    mkdir('Foton')
end

cd('Matlab')

if exist('Main') ~=7
    mkdir('Main')
end

if exist('Isolation_Filters') ~=7
    mkdir('Isolation_Filters')
end

cd Main
if exist('By_Measurements_Date') ~=7
    mkdir('By_Measurements_Date')
end
cd ../../..

if exist('Scripts') ~=7
    mkdir('Scripts')
end
cd Scripts

if exist('Control_Scripts') ~=7
    mkdir('Control_Scripts')
end
cd Control_Scripts

if exist(Version_Control_Scripts) ~=7
    mkdir(Version_Control_Scripts)
end
cd ..

if exist('Data_Collection') ~=7
    mkdir('Data_Collection')
end
cd ..

if exist('Misc') ~=7
    mkdir('Misc')
end

if exist('Data') ~=7
    mkdir('Data');
end
cd Data;

if exist('Misc') ~=7
    mkdir('Misc')
end

if exist('Static_Tests') ~=7
    mkdir('Static_Tests')
end

if exist('Transfer_Functions') ~=7
    mkdir('Transfer_Functions')
end
cd Transfer_Functions

if exist('Simulations') ~=7
    mkdir('Simulations')
end
cd('Simulations')

if exist('Undamped') ~=7
    mkdir('Undamped')
end

if exist('Super_Sensors') ~=7
    mkdir('Super_Sensors')
end 

if exist('Isolation') ~=7
    mkdir('Isolation')
end

if exist('Parameters') ~=7
    mkdir('Parameters')
end
cd ..

if exist('Measurements') ~=7
    mkdir('Measurements')
end
cd('Measurements')

if exist('Batch_file_Archive') ~=7
    mkdir('Batch_file_Archive')
end

if exist('Exc_Files') ~=7
    mkdir('Exc_Files')
end

if exist('Undamped') ~=7
    mkdir('Undamped')
end

if exist('Super_Sensors') ~=7
    mkdir('Super_Sensors')
end

if exist('Isolation') ~=7
    mkdir('Isolation')
end

if exist('Ground') ~=7
    mkdir('Ground')
end
cd ../..

if exist('Linearity_Test') ~=7
    mkdir('Linearity_Test')
end

if exist('Spectra') ~=7
    mkdir('Spectra')
end
cd('Spectra')

if exist('Undamped') ~=7
    mkdir('Undamped')
end

if exist('Isolation') ~=7
    mkdir('Isolation')
end

if exist('Ground') ~=7
    mkdir('Ground')
end

cd ..

if exist('Figures') ~=7
    mkdir('Figures')
end
cd Figures

if exist('Linearity_Test') ~=7
    mkdir('Linearity_Test')
end

if exist('Spectra') ~=7
    mkdir('Spectra')
end
cd('Spectra')

if exist('Undamped') ~=7
    mkdir('Undamped')
end

if exist('Isolation') ~=7
    mkdir('Isolation')
end

if exist('Ground') ~=7
    mkdir('Ground')
end
cd ..

if exist('Transfer_Functions') ~=7
    mkdir('Transfer_Functions')
end
cd('Transfer_Functions')

if exist('Simulations') ~=7
    mkdir('Simulations')
end
cd('Simulations')

if exist('Undamped') ~=7
    mkdir('Undamped')
end

if exist('Super_Sensors') ~=7
    mkdir('Super_Sensors')
end

if exist('Isolation') ~=7
    mkdir('Isolation')
end

if exist('Open_Loop_Check') ~=7
    mkdir('Open_Loop_Check')
end
cd ..

if exist('Measurements') ~=7
    mkdir('Measurements')
end
cd('Measurements')

if exist('Undamped') ~=7
    mkdir('Undamped')
end

if exist('Super_Sensors') ~=7
    mkdir('Super_Sensors')
end

if exist('Damping') ~=7
    mkdir('Damping')
end

if exist('Comparison') ~=7
    mkdir('Comparison')
end

if exist('Ground') ~=7
    mkdir('Ground')
end

end