% Arborescence_ISI(IFO,Type,CHAMBER)
% VL - January 23, 2013
% Arborescence_ISI creates the tree for HAM-ISI and BSC-ISI

function Arborescence_ISI(IFO,Type,CHAMBER,Version_Control_Scripts)

cd(['/ligo/svncommon/SeiSVN/seismic/',Type,'/',IFO,'/',CHAMBER]);
Upper_Path=pwd;

if exist('Channels_List') ~=7
    mkdir('Channels_List')
end
if exist('Filters') ~=7
    mkdir('Filters')
end
cd('Filters')
if exist('Matlab') ~=7
mkdir('Matlab')
end
if exist('Digitized') ~=7
    mkdir('Digitized')
end
if exist('Complementary') ~=7
    mkdir('Complementary')
end
if exist('Filters_file') ~=7
    mkdir('Filters_file')
end
cd Matlab
if exist('Main') ~=7
    mkdir Main
end
cd Main
if exist('By_Measurements_Date') ~=7
    mkdir By_Measurements_Date
end
cd ..
if exist('Isolation_Filters') ~=7
    mkdir Isolation_Filters
end
cd ../..
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
if exist('Misc') ~=7
    mkdir('Misc')
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
if exist('Damped') ~=7
    mkdir('Damped')
end
if exist('Isolated') ~=7
    mkdir('Isolated')
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
if exist('Damped') ~=7
    mkdir('Damped')
end
if exist('Super_Sensors') ~=7
    mkdir('Super_Sensors')
end
if exist('Isolated') ~=7
    mkdir('Isolated')
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
if exist('Damped') ~=7
    mkdir('Damped')
end
if exist('Isolated') ~=7
    mkdir('Isolated')
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
if exist('Damped') ~=7
    mkdir('Damped')
end
if exist('Isolated') ~=7
    mkdir('Isolated')
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
if exist('Damped') ~=7
    mkdir('Damped')
end
if exist('Isolated') ~=7
    mkdir('Isolated')
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
if exist('Damped') ~=7
    mkdir('Damped')
end
if exist('Isolated') ~=7
    mkdir('Isolated')
end
if exist('Comparison') ~=7
    mkdir('Comparison')
end