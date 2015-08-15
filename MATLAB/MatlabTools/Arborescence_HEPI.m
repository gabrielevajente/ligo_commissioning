% Arborescence_HEPI(IFO,CHAMBER,Version_Control_Scripts)
% VL - January 23 - 2013
% HP - June 12th 2013 - Added "Exc_Files" folder, under /Data/Transfer_Functions/Measurements/, so Run_TF_exc could work.
% This function creates the path for HEPI
% HP - Nocember 08th 2013 - replaced all instances of ==7 with ==0. Added
% the current path(pwd) to the exist() test for robustness purpose.

function Arborescence_HEPI(IFO,CHAMBER,Version_Control_Scripts)

cd(['/ligo/svncommon/SeiSVN/seismic/HEPI/',IFO,'/',CHAMBER]);
Upper_Path=pwd;

if exist([pwd '/Channels_List']) ==0
    mkdir('Channels_List')
end
if exist([pwd '/Filters']) ==0
    mkdir('Filters')
end
cd('Filters')

if exist([pwd '/Foton']) ==0
    mkdir('Foton')
end

if exist([pwd '/Filters_file']) ==0
    mkdir('Filters_file')
end

if exist([pwd '/Matlab']) ==0
    mkdir('Matlab')
end

if exist([pwd '/Foton']) ==0
    mkdir('Foton')
end

cd('Matlab')

if exist([pwd '/Main']) ==0
    mkdir('Main')
end

if exist([pwd '/Isolation_Filters']) ==0
    mkdir('Isolation_Filters')
end

cd Main
if exist([pwd '/By_Measurements_Date']) ==0
    mkdir('By_Measurements_Date')
end
cd ../../..

if exist([pwd '/Scripts']) ==0
    mkdir('Scripts')
end
cd Scripts

if exist([pwd '/Control_Scripts']) ==0
    mkdir('Control_Scripts')
end
cd Control_Scripts

if exist(Version_Control_Scripts) ==0
    mkdir(Version_Control_Scripts)
end
cd ..

if exist([pwd '/Data_Collection']) ==0
    mkdir('Data_Collection')
end
cd ..

if exist([pwd '/Misc']) ==0
    mkdir('Misc')
end

if exist([pwd '/Data']) ==0
    mkdir('Data');
end
cd Data;

if exist([pwd '/Misc']) ==0
    mkdir('Misc')
end

if exist([pwd '/Static_Tests']) ==0
    mkdir('Static_Tests')
end

if exist([pwd '/Transfer_Functions']) ==0
    mkdir('Transfer_Functions')
end
cd Transfer_Functions

if exist([pwd '/Simulations']) ==0
    mkdir('Simulations')
end
cd('Simulations')

if exist([pwd '/Undamped']) ==0
    mkdir('Undamped')
end

if exist([pwd '/Super_Sensors']) ==0
    mkdir('Super_Sensors')

if exist([pwd '/Isolation']) ==0
    mkdir('Isolation')
end

if exist([pwd '/Parameters']) ==0
    mkdir('Parameters')
end
cd ..

if exist([pwd '/Measurements']) ==0
    mkdir('Measurements')
end
cd('Measurements')

if exist([pwd '/Batch_file_Archive']) ==0
    mkdir('Batch_file_Archive')
end

if exist([pwd '/Exc_Files']) ==0
    mkdir('Exc_Files')
end

if exist([pwd '/Undamped']) ==0
    mkdir('Undamped')
end

if exist([pwd '/Super_Sensors']) ==0
    mkdir('Super_Sensors')
end

if exist([pwd '/Isolation']) ==0
    mkdir('Isolation')
end

if exist([pwd '/Ground']) ==0
    mkdir('Ground')
end
cd ../..

if exist([pwd '/Linearity_Test']) ==0
    mkdir('Linearity_Test')
end

if exist([pwd '/Spectra']) ==0
    mkdir('Spectra')
end
cd('Spectra')

if exist([pwd '/Undamped']) ==0
    mkdir('Undamped')
end

if exist([pwd '/Isolation']) ==0
    mkdir('Isolation')
end

if exist([pwd '/Ground']) ==0
    mkdir('Ground')
end

cd ..

if exist([pwd '/Figures']) ==0
    mkdir('Figures')
end
cd Figures

if exist([pwd '/Linearity_Test']) ==0
    mkdir('Linearity_Test')
end

if exist([pwd '/Spectra']) ==0
    mkdir('Spectra')
end
cd('Spectra')

if exist([pwd '/Undamped']) ==0
    mkdir('Undamped')
end

if exist([pwd '/Isolation']) ==0
    mkdir('Isolation')
end

if exist([pwd '/Ground']) ==0
    mkdir('Ground')
end
cd ..

if exist([pwd '/Transfer_Functions']) ==0
    mkdir('Transfer_Functions')
end
cd('Transfer_Functions')

if exist([pwd '/Simulations']) ==0
    mkdir('Simulations')
end
cd('Simulations')

if exist([pwd '/Undamped']) ==0
    mkdir('Undamped')
end

if exist([pwd '/Super_Sensors']) ==0
    mkdir('Super_Sensors')
end

if exist([pwd '/Isolation']) ==0
    mkdir('Isolation')
end

if exist([pwd '/Open_Loop_Check']) ==0
    mkdir('Open_Loop_Check')
end
cd ..

if exist([pwd '/Measurements']) ==0
    mkdir('Measurements')
end
cd('Measurements')

if exist([pwd '/Undamped']) ==0
    mkdir('Undamped')
end

if exist([pwd '/Super_Sensors']) ==0
    mkdir('Super_Sensors')
end

if exist([pwd '/Damping']) ==0
    mkdir('Damping')
end

if exist([pwd '/Comparison']) ==0
    mkdir('Comparison')
end

if exist([pwd '/Ground']) ==0
    mkdir('Ground')
end

end