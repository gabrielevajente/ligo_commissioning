% ######################################################################
%                        SEI_Matrices_Check
% ######################################################################

% This function collects the values installed in the matrices of a given Unit
% And compares them to the standard SEI matrices
% It will also:
%    - Point out which matrices have the absolute values of their 
%      coefficients differing from the standard matrices, 
%      by the amount defined in the Allowance variable, or more, and
%    - Pounts out which matrices have their sign wrong.

% Note:
%      - Ground STS not yet implemented. A bit complicated to to the use of
%      different channels: A,B and C.

% Input Variables:
%   - Chamber: 'HAM3', 'ITMX',...
%   - Type: 'ISI' or 'HEPI'
%   - Allowance: How much deviation is allowed on values before raising
%     flag

% HP 09/15/14 - Initial Version

function SEI_Matrices_Check (Chamber,IFO,Unit_Type,Allowance)

cprintf([0 0 0],['******** Checking matrices for ' IFO ' ' Chamber '-' Unit_Type ' ********']); fprintf('\n'); error=0;
cprintf([0.1 0.1 0.1],['Comparison precision: ' num2str(Allowance)]);fprintf('\n'); error=0;  

%% Load Reference Matrices

% Load Paths
addpath(genpath('/ligo/svncommon/SeiSVN/seismic/BSC-ISI/Common/Basis_Change_BSC_ISI/'));
addpath(genpath('/ligo/svncommon/SeiSVN/seismic/HAM-ISI/Common/Basis_Change_Matrices/'));
addpath(genpath('/ligo/svncommon/SeiSVN/seismic/HEPI/Common/Basis_Change_Matrices_HEPI/'));

if strcmp(Unit_Type,'ISI')
    % BSC-ISI
    if strcmp(Chamber,'ITMX')||strcmp(Chamber,'ETMY')
        Type='ISI';
        What='BSC';
        load('aLIGO_BSC_ISI_ITMX_ETMY.mat');
        load('aLIGO_BSC_HEPI_ITMX_ETMY.mat','L4C2CART');
        L4C2CART = L4C2CART([ 1:3 , 5:7 ] , :); % Removing rows 4 and 8 which are for HP and VP
    elseif strcmp(Chamber,'BS')||strcmp(Chamber,'ITMY')||strcmp(Chamber,'ETMX')
        Type='ISI';
        What='BSC';
        load('aLIGO_BSC_ISI_BS_ITMY_ETMX.mat');
        load('aLIGO_BSC_HEPI_BS_ITMY_ETMX.mat','L4C2CART');
        L4C2CART = L4C2CART([ 1:3 , 5:7 ] , :); % Removing rows 4 and 8 which are for HP and VP
    end
    
    
    % HAM-ISI
    if strcmp(Chamber,'HAM2')||strcmp(Chamber,'HAM3')
        Type='ISI';
        What='HAM';
        load('aLIGO_HAM_ISI_2_3.mat');
    elseif strcmp(Chamber,'HAM4')||strcmp(Chamber,'HAM5')||strcmp(Chamber,'HAM6')
        Type='ISI';
        What='HAM';
        load('aLIGO_HAM_ISI_4_5_6.mat');
    end
end

% HEPI
if strcmp(Unit_Type,'HEPI')
    Type='HPI';
    What='HEPI';    
    if strcmp(Chamber,'ITMX')||strcmp(Chamber,'ETMY')
        load('aLIGO_BSC_HEPI_ITMX_ETMY.mat');
    elseif strcmp(Chamber,'BS')||strcmp(Chamber,'ITMY')||strcmp(Chamber,'ETMX')
        load('aLIGO_BSC_HEPI_BS_ITMY_ETMX.mat');
    elseif strcmp(Chamber,'HAM1')||strcmp(Chamber,'HAM2')||strcmp(Chamber,'HAM3')
        load('aLIGO_HAM_HEPI_1_2_3.mat');
    elseif strcmp(Chamber,'HAM4')||strcmp(Chamber,'HAM5')||strcmp(Chamber,'HAM6')
        load('aLIGO_HAM_HEPI_4_5_6.mat');
    end
end


% %Ground STSs
% if strcmp(Chamber,'ETMX')||strcmp(Chamber,'ETMY')
%     load('aLIGO_HEPI_BSC_STS_End_Station.mat');
% elseif strcmp(Chamber,'ITMX')||strcmp(Chamber,'BS')||strcmp(Chamber,'ITMY')
%     load('aLIGO_HEPI_STS_LVEA.mat');
% end

%% List Standard Values
Var_List=who;
kk=0;
for Var = 1:length(Var_List)
    Var_Name=Var_List{Var};
    if strcmp(Var_Name,'ST1_T2402CART9') == 0
        if strcmp(Var_Name(1:3),'ST1') || strcmp(Var_Name(1:3),'ST2')||strcmp(Var_Name(1:3),'CAR') || strcmp(Var_Name(1:3),'GS1')||strcmp(Var_Name(1:3),'T24') || strcmp(Var_Name(1:3),'CPS')|| strcmp(Var_Name(1:3),'L4C')|| strcmp(Var_Name(1:3),'IPS')|| strcmp(Var_Name(1:3),'STS')
            kk=kk+1;
            Matrices(kk).name=Var_Name;
            eval(['Matrices(kk).standard=' Matrices(kk).name ';'])
        end
    end
end
Number_of_Matrices=kk;

%% List Installed Values
for Mat = 1 : Number_of_Matrices
    chan=[IFO,':' Type '-',Chamber,'_',Matrices(Mat).name];
    if strcmp(Matrices(Mat).name,'T2402CART9') == 0
        if strcmp(Matrices(Mat).name,'L4C2CART') && strcmp(What,'BSC')
            clear chan
            chan=[IFO,':', Type, '-',Chamber,'_','ST1_HPIL4C2CART'];
            Matrices(Mat).standard=Matrices(Mat).standard(1:6,1:7);
        end
        standard=Matrices(Mat).standard;
        Matrices(Mat).installed=read_matrix_values(chan,standard);
        clear standard
    end
end

%% Compare and store differences
% Abs Values
for Mat = 1 : Number_of_Matrices
    Matrices(Mat).wrong_values=0;
    standard  = round(Matrices(Mat).standard.*1e5)./1e5 ; % epics rounded at 1e-5
    installed = Matrices(Mat).installed;
    diff = abs(standard) - abs(installed);
    if max(max(abs(diff)))>=Allowance
        Matrices(Mat).wrong_values=1;
    end
end

% Sing included in comparison
for Mat = 1 : Number_of_Matrices
    Matrices(Mat).wrong_sign=0;
    standard  = sign(Matrices(Mat).standard.*1e10) ;
    installed = sign(Matrices(Mat).installed.*1e10) ;
    diff = standard - installed;
    if max(max(abs(diff)))>=Allowance
        Matrices(Mat).wrong_sign=1;
    end
    % Wrong signs ignored
    
end

%% Display the list of matrices that do not match
for Mat = 1 : Number_of_Matrices
    Mat_Name=Matrices(Mat).name;
    
    if Matrices(Mat).wrong_values==1
        cprintf([0.9 0 0],[Mat_Name ' absolute values are not standard']); fprintf('\n'); error=0;
    else
        cprintf([0 0.5 0],[Mat_Name ' absolute values are standard' ]); fprintf('\n'); error=0;
    end
    
    if Matrices(Mat).wrong_sign==1
        cprintf([0.9 0 0],[Mat_Name ' signs are wrong' ]); fprintf('\n'); error=0;
    else
        cprintf([0 0.5 0],[Mat_Name ' signs are correct' ]); fprintf('\n'); error=0;
    end
end


cprintf([0 0 0],['******** Done Checking matrices for ' IFO ' ' Chamber '-' Unit_Type ' ********']); fprintf('\n\n\n'); error=0;

end

