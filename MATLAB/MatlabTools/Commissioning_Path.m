function [ output_args ] = Commissioning_Path( IFO,Chamber)
% This function loads the Matlab path needed for the comissioning of a
% given Unit.
% It also scans the folders to remove the unwanted
% Units/Script_versions from the Matlab Path.
% Built to work with discrepancies beween sites.

% List of updates:
% ---------------
%   - 2012-13 - HP initial version
%   -June 9th 2014 - HP 
%       - Allowed function to work at stanford by adjusting
%       upper path based on the IFO
%       - Allowed function to work with both HAM-ISI and BSC-ISI

%% Initialisation

disp(['- The Matlab paths needed for the commissioning of ' Chamber ' are being loaded'])
warning off

%% Standfod has a different root for the SVN folder tree
if strcmp(IFO,'S1')
    Upper_Path='/home/controls/SeismicSVN/seismic/';
else
    Upper_Path = '/ligo/svncommon/SeiSVN/seismic/';
end
%% Type of System (HAM or BSC)
Is_HAM  = strcmp(Chamber(1:2),'HA');
Is_BSC  = strcmp(Chamber(1:2), 'IT') || strcmp(Chamber(1:2), 'ET') || strcmp(Chamber(1:2), 'BS');
if Is_HAM
    System  = 'HAM-ISI';
    Unit    = str2num(Chamber(4));
%     Units  = 2:5;
elseif Is_BSC
        System='BSC-ISI';
%         Units= #####;
end

%% Clear Starting Point
System_Folder=[Upper_Path System];
Common_Folder=[Upper_Path System '/Common/']; % Needed to run the script

%% Local Scripts
fprintf('\n')
disp('----Unit''s Folders')
disp('--------Local Comissioning Scripts')
% Load Unit's folder
Units_Folder=[Upper_Path System  '/' IFO '/'];
addpath(  genpath([System_Folder '/' IFO]))
disp(['added:   '  System_Folder '/' IFO])

% Remove unwanted commissioning scripts Versions
Other_Local_Versions=Subfolders([Units_Folder,Chamber, '/Scripts/Control_Scripts/']);
for ii=1:length(Other_Local_Versions)
    Other_Local_Version=Other_Local_Versions{ii};
    if strcmp(Other_Local_Version,'release')==0 && strcmp(Other_Local_Version,'Misc')==0
        Other_Local_Version_Folder=[Upper_Path System '/' IFO '/' Chamber '/Scripts/Control_Scripts/' Other_Local_Version ];
        rmpath(genpath(    Other_Local_Version_Folder));
        disp( ['removed: ' Other_Local_Version_Folder ])
    end
end

% Add Latest version
Latest_Version=Latest_Version_Folders(Other_Local_Versions);
addpath(genpath( [Units_Folder,Chamber, '/Scripts/Control_Scripts/' Latest_Version ] ));
disp( ['added: ' [Units_Folder,Chamber, '/Scripts/Control_Scripts/' Latest_Version ] ])

% Add Perf_Analysis
disp('--------Local Perf Analysis Scripts')
Units_Perf_Path = [Units_Folder,Chamber, '/Scripts/Perf_Analysis/'];
addpath(genpath(  Units_Perf_Path))
disp(['added:   ' Units_Perf_Path ]);

%% Remove other Units' folders
disp('--------Other Units'' Data')
% Current IFO
% Remove Units' Folders
disp(['----------------' IFO])
Other_Units=Subfolders(Units_Folder);
for ii=1:length(Other_Units)
    Other_Unit=Other_Units{ii};
    if strcmp(Other_Unit,Chamber)==0 && strcmp(Other_Unit,'Misc')==0
        Other_Units_Folder=[Upper_Path System '/' IFO '/' Other_Unit '/'];
        rmpath(genpath(Other_Units_Folder));
        disp( ['removed: ' Other_Units_Folder ])
    end
    
end
%Add data folder only
for ii=1:length(Other_Units)
    Other_Unit=Other_Units{ii};
    if strcmp(Other_Unit,Chamber)==0 && strcmp(Other_Unit,'Misc')==0
        Other_Units_Folder=[Upper_Path System '/' IFO '/' Other_Unit '/'];
        addpath(genpath([  Other_Units_Folder 'Data']));
        disp( ['added:   ' Other_Units_Folder 'Data']) 
    end
end

% Other IFO
if strcmp(IFO,'H1')
    Other_IFO='L1';
    Staging_Building = 'X1';
    SB_Units=1:7;
elseif strcmp(IFO,'L1') || strcmp(IFO,'S1') 
    Other_IFO='H1';
    Staging_Building = 'X2';
    SB_Units=2:5;
end
Units_Folder=[Upper_Path System '/' Other_IFO '/'];
Other_Units=Subfolders(Units_Folder);

disp(['----------------' Other_IFO])
% Remove the folders for units of other IFO
for ii=1:length(Other_Units)
    Other_Unit=Other_Units{ii};
    if strcmp(Other_Unit,'Misc')==0
        Other_Units_Folder=[Upper_Path System '/' Other_IFO '/' Other_Unit '/'];
        rmpath(genpath(Other_Units_Folder));
        disp( ['removed: ' Other_Units_Folder ])
    end    
end
        SB_Units_Folder=[Upper_Path System '/' Staging_Building '/'];
        rmpath(genpath(SB_Units_Folder));
        disp( ['removed: ' SB_Units_Folder ])

% Add Data Folders only
for ii=1:length(Other_Units)
    Other_Unit=Other_Units{ii};
    Other_Units_Data_Folder=[Upper_Path System '/' Other_IFO '/' Other_Unit '/Data/'];
    addpath(genpath(   Other_Units_Data_Folder));
    disp( ['added:   ' Other_Units_Data_Folder ])
end
for ii=1:length(SB_Units)
    SB_Units_Data_Folder=[Upper_Path System '/' Staging_Building '/Unit_' num2str(SB_Units(ii)) '/Data/'];
    addpath(genpath(   SB_Units_Data_Folder));
    disp( ['added:   ' SB_Units_Data_Folder ])
end

%% Common Folder
fprintf('\n')
disp('----Common Folder')

%% Common Plotting Functions
disp('--------Common Plotting Functions')
Common_Plotting_Path=[Upper_Path System '/Common/Plot_Functions_' System(1:3) '_ISI/'];
% addpath(genpath(  Common_Plotting_Path))
% disp(['added:   ' Common_Plotting_Path]);

%Remove other versions of the Plotting Functions
Other_Plotting_Versions=Subfolders(Common_Plotting_Path);
for ii=1:length(Other_Plotting_Versions)
    Other_Plotting_Version=Other_Plotting_Versions{ii};
    if strcmp(Other_Plotting_Version,'release')==0 && strcmp(Other_Plotting_Version,'Misc')==0
        Other_Plotting_Version_Folder=[ Common_Plotting_Path Other_Plotting_Version '/'];
        rmpath(genpath(    Other_Plotting_Version_Folder));
        disp( ['removed: ' Other_Plotting_Version_Folder ])
    end
end

% Add Latest version
Latest_Version=Latest_Version_Folders(Other_Plotting_Versions);
addpath(genpath( [ Common_Plotting_Path Latest_Version ] ));
disp( ['added: ' [ Common_Plotting_Path Latest_Version ] ])


%% Common Routines
disp('--------Common Routines')
Common_Routines_Path=[Upper_Path System '/Common/Control_Generic_Scripts_' System(1:3) '_ISI/'];
% addpath(genpath(  Common_Routines_Path))
% disp(['added:   ' Common_Routines_Path ]);

%Remove other versions of the Routines
Other_Routines_Versions=Subfolders(Common_Routines_Path);
for ii=1:length(Other_Routines_Versions)
    Other_Routines_Version=Other_Routines_Versions{ii};
    if strcmp(Other_Routines_Version,'release')==0 && strcmp(Other_Routines_Version,'Misc')==0
        Other_Routines_Version_Folder=[ Common_Routines_Path Other_Routines_Version '/'];
        rmpath(genpath(    Other_Routines_Version_Folder));
        disp( ['removed: ' Other_Routines_Version_Folder ])
    end
end

% Add Latest version
Latest_Version=Latest_Version_Folders(Other_Routines_Versions);
addpath(genpath( [ Common_Routines_Path Latest_Version ] ));
disp( ['added: ' [ Common_Routines_Path Latest_Version ] ])


%% Common Routines Perf_Analysis
disp('--------Common Perf_Analysis')
Common_Perf_Path=[Upper_Path System '/Common/Perf_Analysis/'];
addpath(genpath(  Common_Perf_Path))
disp(['added:   ' Common_Perf_Path ]);


%% Final information
fprintf('\n')
cprintf([0.1 0.65 0],['- The Matlab paths needed for the commissioning of ' Chamber ' were successfully loaded']),cprintf('\n\n');
warning on
end