 close all
 clear  
%  

%%
printFigs = 0;

filterModules = 9; % FM Number (counting starts at 1), 
                   % can use multiple banks; e.g. [2 3]
IFO = 'H1';
CHAMBER='ETMX';
svnDir    = '/ligo/svncommon/SeiSVN/seismic/';
filterDir = '/opt/rtcds/lho/h1/chans/';
seiTools  = [svnDir 'Common/MatlabTools/']; 
DOF=  {'X','Z','RY','RZ'};
plotDate = '2015-04-13';
author = ', jw';

freqRange = [1e-3 1e3];
xTicks = 10.^(-3:3);
freq = logspace(-3,3,1000);

% Inertial instrument responses in displacement to velocity
L4C_resp = zpk(-2*pi*[0 0 0],-2*pi*pair(1,45),1);
GS13_resp = zpk(-2*pi*[0 0 0],-2*pi*pair(1,45),1);
T240_resp = zpk(-2*pi*[0 0 0],-2*pi*pair(4.3E-3,45),1);

% Color table for plots
colors.trans.cps  = [0.0 0.0 1.0];
colors.trans.t240 = [0.0 1.0 1.0];
colors.trans.l4c  = [0.0 0.7 0.0];
colors.trans.gs13 = [0.0 0.7 0.0];
colors.trans.sum  = [1.0 0.0 0.0];

colors.rot.cps  = [0.5 0.5 1.0];
colors.rot.t240 = [0.5 1.0 1.0];
colors.rot.l4c  = [0.5 0.7 0.5];
colors.rot.gs13 = [0.5 0.7 0.5];
colors.rot.sum  = [1.0 0.5 0.5];

%%
addpath(seiTools)

%% Foton file name, plot location, figure name
if isempty(regexp(CHAMBER,'[1-6]', 'once')) % IF no numbers in chamber name
    CHAMBERTYPE = 'BSC';
    finalStageTag = '_ST2';
else
    CHAMBERTYPE = 'HAM';
    finalStageTag = '';
end
    
fileName = [filterDir IFO 'ISI' CHAMBER '.txt'];
plotDir   = [svnDir '/' CHAMBERTYPE '-ISI/' IFO '/' CHAMBER '/Filters/Figures/'];

%%
disp(['Loading ' fileName '...'])
tic
for iDOF = 1:length(DOF)
    if strcmp(CHAMBERTYPE,'BSC')
        % Stage 1 Blends
        bank = [CHAMBER,'_ST1_BLND_',DOF{iDOF},'_CPS_CUR'];
        Installed_ST1CPS(iDOF).c = tf(1);
        for  nn = 1:length(filterModules)
            module = filterModules(nn);
            [z,p,k] = readFilterzpk(fileName,bank,module);
            Installed_ST1CPS(iDOF).c = Installed_ST1CPS(iDOF).c*zpk(z,p,k);
        end
        
        bank = [CHAMBER,'_ST1_BLND_',DOF{iDOF},'_T240_CUR'];
        Installed_T240(iDOF).c = tf(1);
        name.st1 = [];
        name.st2 = [];
        for  nn = 1:length(filterModules)
            module = filterModules(nn);
            [z,p,k,named] = readFilterzpk(fileName,bank,module);
            Installed_T240(iDOF).c = Installed_T240(iDOF).c*zpk(z,p,k);
            if iDOF == 1
                name.st1 = regexprep(named,'\_',' ');
            end
        end
        
        bank = [CHAMBER,'_ST1_BLND_',DOF{iDOF},'_L4C_CUR'];
        Installed_L4C(iDOF).c = tf(1);
        for  nn = 1:length(filterModules)
            module = filterModules(nn);
            [z,p,k] = readFilterzpk(fileName,bank,module);
            Installed_L4C(iDOF).c = Installed_L4C(iDOF).c*zpk(z,p,k);
        end
        
        
        Comp_ST1CPS(iDOF).c = Installed_ST1CPS(iDOF).c;
        Comp_T240(iDOF).c   = Installed_T240(iDOF).c*T240_resp;
        Comp_L4C(iDOF).c    = Installed_L4C(iDOF).c*L4C_resp;
        
        Designed_ST1HP(iDOF).c = Comp_T240(iDOF).c + Comp_L4C(iDOF).c;
        Designed_ST1LP(iDOF).c = Comp_ST1CPS(iDOF).c;
        
        Installed_ST1CPS(iDOF).f = squeeze(freqresp(Installed_ST1CPS(iDOF).c,2*pi*freq));
        Installed_T240(iDOF).f   = squeeze(freqresp(Installed_T240(iDOF).c,2*pi*freq));
        Installed_L4C(iDOF).f    = squeeze(freqresp(Installed_L4C(iDOF).c,2*pi*freq));
        
        Comp_ST1CPS(iDOF).f = squeeze(freqresp(Comp_ST1CPS(iDOF).c,2*pi*freq));
        Comp_T240(iDOF).f   = squeeze(freqresp(Comp_T240(iDOF).c,2*pi*freq));
        Comp_L4C(iDOF).f    = squeeze(freqresp(Comp_L4C(iDOF).c,2*pi*freq));
        
        Designed_ST1HP(iDOF).f = squeeze(freqresp(Designed_ST1HP(iDOF).c,2*pi*freq));
        Designed_ST1LP(iDOF).f = squeeze(freqresp(Designed_ST1LP(iDOF).c,2*pi*freq));
    end
        
    cpsbank = [CHAMBER,finalStageTag,'_BLND_',DOF{iDOF},'_CPS_CUR'];
    gs13bank = [CHAMBER,finalStageTag,'_BLND_',DOF{iDOF},'_GS13_CUR'];
    
    Installed_ST2CPS(iDOF).c = tf(1);
    for  nn = 1:length(filterModules)
        module = filterModules(nn);
        [z,p,k,named] = readFilterzpk(fileName,cpsbank,module);
        Installed_ST2CPS(iDOF).c = Installed_ST2CPS(iDOF).c*zpk(z,p,k);
        if iDOF == 1
            name.st2 = regexprep(named,'\_',' ');
        end
    end
    
    Installed_GS13(iDOF).c = tf(1);
    for  nn = 1:length(filterModules)
        module = filterModules(nn);
        [z,p,k] = readFilterzpk(fileName,gs13bank,module);
        Installed_GS13(iDOF).c = Installed_GS13(iDOF).c*zpk(z,p,k);
    end
    
    Comp_ST2CPS(iDOF).c = Installed_ST2CPS(iDOF).c;
    Comp_GS13(iDOF).c   = Installed_GS13(iDOF).c*GS13_resp;
    
    Designed_ST2HP(iDOF).c = Comp_GS13(iDOF).c;
    Designed_ST2LP(iDOF).c = Comp_ST2CPS(iDOF).c;
    
    Installed_GS13(iDOF).f = squeeze(freqresp(Installed_GS13(iDOF).c,2*pi*freq));
    Installed_ST2CPS(iDOF).f = squeeze(freqresp(Installed_ST2CPS(iDOF).c,2*pi*freq));
    
    Comp_ST2CPS(iDOF).f = squeeze(freqresp(Comp_ST2CPS(iDOF).c,2*pi*freq));
    Comp_GS13(iDOF).f = squeeze(freqresp(Comp_GS13(iDOF).c,2*pi*freq));

    Designed_ST2HP(iDOF).f = squeeze(freqresp(Designed_ST2HP(iDOF).c,2*pi*freq));
    Designed_ST2LP(iDOF).f = squeeze(freqresp(Designed_ST2LP(iDOF).c,2*pi*freq));
end
thatWasAWhile = toc;
disp(['Done loading in ' num2str(thatWasAWhile) ' [sec] ...'])

%% 
disp('Plotting results ...')
figTag = [plotDir plotDate '_' IFO 'ISI' CHAMBER '_blendfilters_' name.st1 '_' name.st2];
figNum = 1;

if strcmp(CHAMBERTYPE,'BSC')
    %% Plot what comes out of Foton directly for ST1
    figure(figNum)
    figNames{figNum} = [figTag '_ST1_AsInstalledInFoton_XRY.pdf'];
    figNum = figNum + 1;
    subplot(211)
    ll = loglog(freq,abs([Installed_ST1CPS(1).f,...
                          Installed_T240(1).f,...
                          Installed_L4C(1).f,...
                          Installed_ST1CPS(3).f,...
                          Installed_T240(3).f,...
                          Installed_L4C(3).f]));
    grid on;
    title({[IFO 'ISI' CHAMBER ' ST1 "' name.st1 '" Blend Filters'];...
        'As Installed in Foton'},...
        'FontSize',16)
    set(ll,'LineWidth',3)
    set(ll(4:6),'LineStyle','--')
    set(ll(1),'Color',colors.trans.cps)
    set(ll(2),'Color',colors.trans.t240)
    set(ll(3),'Color',colors.trans.l4c)
    set(ll(4),'Color',colors.rot.cps)
    set(ll(5),'Color',colors.rot.t240)
    set(ll(6),'Color',colors.rot.l4c)
    xlabel('Frequency [Hz]')
    ylabel({'Magnitude';'[(nm/nm), (nm/s / m), (nrad/nrad), or (nrad/s / nrad)]'})
    axis([freqRange 1e-6 1e2])
    set(gca,'XTick',xTicks,'YTick',10.^(-6:2),'FontSize',16)
    
    subplot(212)
    ll = semilogx(freq,180/pi*angle([Installed_ST1CPS(1).f,...
        Installed_T240(1).f,...
        Installed_L4C(1).f,...
        Installed_ST1CPS(3).f,...
        Installed_T240(3).f,...
        Installed_L4C(3).f]));
    grid on;
    set(ll,'LineWidth',3)
    set(ll(4:6),'LineStyle','--')
    set(ll(1),'Color',colors.trans.cps)
    set(ll(2),'Color',colors.trans.t240)
    set(ll(3),'Color',colors.trans.l4c)
    set(ll(4),'Color',colors.rot.cps)
    set(ll(5),'Color',colors.rot.t240)
    set(ll(6),'Color',colors.rot.l4c)
    xlabel('Frequency [Hz]')
    ylabel('Phase [deg]')
    axis([freqRange -185 185])
    set(gca,'XTick',xTicks,'YTick',-180:45:180,'FontSize',16)
    legend('X Low Pass (CPS)', 'X Band Pass (T240)','X High Pass (L4C)',...
        'RY Low Pass (CPS)','RY Band Pass (T240)','RY High Pass (L4C)','Location','East')
    
    %% Plot the ST1 displacement sensor vs inertial sensor blend looking for complementarity
    figure(figNum)
    figNames{figNum} = [figTag '_ST1_DispVInert_Blend_XRY.pdf'];
    figNum = figNum + 1;
    subplot(211)
    ll = loglog(freq,abs([Designed_ST1LP(1).f ...
                          Designed_ST1HP(1).f ...
                          Designed_ST1LP(1).f + Designed_ST1HP(1).f...
                          Designed_ST1LP(3).f ...
                          Designed_ST1HP(3).f ...
                          Designed_ST1LP(3).f + Designed_ST1HP(3).f]));
    grid on;
    title({[IFO 'ISI' CHAMBER ' ST1 "' name.st1 '" Blend Filters'];...
        'Displacement LP vs Inertial HP, As Designed Complementarity'},...
        'FontSize',16)
    set(ll,'LineWidth',3)
    set(ll(4:6),'LineStyle','--')
    set(ll(1),'Color',colors.trans.cps)
    set(ll(2),'Color',colors.trans.l4c)
    set(ll(3),'Color',colors.trans.sum)
    set(ll(4),'Color',colors.rot.cps)
    set(ll(5),'Color',colors.rot.l4c)
    set(ll(6),'Color',colors.rot.sum)
    xlabel('Frequency [Hz]')
    ylabel('Magnitude [(nm/nm) or (nrad/nrad)]')
    axis([freqRange 1e-6 1e1])
    set(gca,'XTick',xTicks,'YTick',10.^(-6:1),'FontSize',16)
    
    subplot(212)
    ll = semilogx(freq,180/pi*angle([Designed_ST1LP(1).f ...
        Designed_ST1HP(1).f ...
        Designed_ST1LP(1).f + Designed_ST1HP(1).f...
        Designed_ST1LP(3).f ...
        Designed_ST1HP(3).f ...
        Designed_ST1LP(3).f + Designed_ST1HP(3).f]));
    grid on;
    set(ll,'LineWidth',3)
    set(ll(4:6),'LineStyle','--')
    set(ll(1),'Color',colors.trans.cps)
    set(ll(2),'Color',colors.trans.l4c)
    set(ll(3),'Color',colors.trans.sum)
    set(ll(4),'Color',colors.rot.cps)
    set(ll(5),'Color',colors.rot.l4c)
    set(ll(6),'Color',colors.rot.sum)
    xlabel('Frequency [Hz]')
    ylabel('Phase [deg]')
    axis([freqRange -185 185])
    set(gca,'XTick',xTicks,'YTick',-180:45:180,'FontSize',16)
    legend('X Displacement LP (CPS)', 'X Inertial HP (T240+L4C)','Sum',...
        'RY Displacement LP (CPS)', 'RY Inertial HP (T240+L4C)','Sum','Location','SouthEast')
    
    %% Plot the all ST1 complementary blends looking for complementarity
    figure(figNum)
    figNames{figNum} = [figTag '_ST1_Complementarity_XRY.pdf'];
    figNum = figNum + 1;
    subplot(211)
    ll = loglog(freq,abs([Comp_ST1CPS(1).f ...
                          Comp_T240(1).f ...
                          Comp_L4C(1).f ...
                          Comp_ST1CPS(1).f + Comp_T240(1).f + Comp_L4C(1).f ...
                          Comp_ST1CPS(3).f ...
                          Comp_T240(3).f ...
                          Comp_L4C(3).f ...
                          Comp_ST1CPS(3).f + Comp_T240(3).f + Comp_L4C(3).f]));
    grid on;
    title({[IFO 'ISI' CHAMBER ' ST1 "' name.st1 '" Blend Filters'];...
        'Displacement LP vs Inertial HP, As Designed Complementarity'},...
        'FontSize',16)
    set(ll,'LineWidth',3)
    set(ll([4 8]),'LineWidth',5)
    set(ll(5:8),'LineStyle','--')
    set(ll(1),'Color',colors.trans.cps)
    set(ll(2),'Color',colors.trans.t240)
    set(ll(3),'Color',colors.trans.l4c)
    set(ll(4),'Color',colors.trans.sum)
    set(ll(5),'Color',colors.rot.cps)
    set(ll(6),'Color',colors.rot.t240)
    set(ll(7),'Color',colors.rot.l4c)
    set(ll(8),'Color',colors.rot.sum)
    xlabel('Frequency [Hz]')
    ylabel('Magnitude [(nm/nm) or (nrad/nrad)]')
    axis([freqRange 1e-6 1e1])
    set(gca,'XTick',xTicks,'YTick',10.^(-6:1),'FontSize',16)
    
    subplot(212)
    ll = semilogx(freq,180/pi*angle([Comp_ST1CPS(1).f ...
                                     Comp_T240(1).f ...
                                     Comp_L4C(1).f ...
                                     Comp_ST1CPS(1).f + Comp_T240(1).f + Comp_L4C(1).f ...
                                     Comp_ST1CPS(3).f ...
                                     Comp_T240(3).f ...
                                     Comp_L4C(3).f ...
                                     Comp_ST1CPS(3).f + Comp_T240(3).f + Comp_L4C(3).f]));
    grid on;
    set(ll,'LineWidth',3)
    set(ll([4 8]),'LineWidth',5)
    set(ll(5:8),'LineStyle','--')
    set(ll(1),'Color',colors.trans.cps)
    set(ll(2),'Color',colors.trans.t240)
    set(ll(3),'Color',colors.trans.l4c)
    set(ll(4),'Color',colors.trans.sum)
    set(ll(5),'Color',colors.rot.cps)
    set(ll(6),'Color',colors.rot.t240)
    set(ll(7),'Color',colors.rot.l4c)
    set(ll(8),'Color',colors.rot.sum)
    xlabel('Frequency [Hz]')
    ylabel('Phase [deg]')
    axis([freqRange -185 185])
    set(gca,'XTick',xTicks,'YTick',-180:45:180,'FontSize',16)
    legend('X CPS LP', 'X T240 BP','X L4C HP','Sum',...
           'RY CPS LP', 'RY T240 BP','RY L4C HP','Sum','Location','SouthEast')
    
    %% Plot what comes out of Foton directly for ST1   
    figure(figNum)
    figNames{figNum} = [figTag '_ST1_AsInstalledInFoton_ZRZ.pdf'];
    figNum = figNum + 1;
    subplot(211)
    ll = loglog(freq,abs([Installed_ST1CPS(2).f,...
                          Installed_T240(2).f,...
                          Installed_L4C(2).f,...
                          Installed_ST1CPS(4).f,...
                          Installed_T240(4).f,...
                          Installed_L4C(4).f]));
    grid on;
    title({[IFO 'ISI' CHAMBER ' ST1 "' name.st1 '" Blend Filters'];...
        'As Installed in Foton'},...
        'FontSize',16)
    set(ll,'LineWidth',3)
    set(ll(4:6),'LineStyle','--')
    set(ll(1),'Color',colors.trans.cps)
    set(ll(2),'Color',colors.trans.t240)
    set(ll(3),'Color',colors.trans.l4c)
    set(ll(4),'Color',colors.rot.cps)
    set(ll(5),'Color',colors.rot.t240)
    set(ll(6),'Color',colors.rot.l4c)
    xlabel('Frequency [Hz]')
    ylabel({'Magnitude';'[(nm/nm), (nm/s / m), (nrad/nrad), or (nrad/s / nrad)]'})
    axis([freqRange 1e-6 1e2])
    set(gca,'XTick',xTicks,'YTick',10.^(-6:2),'FontSize',16)
    
    subplot(212)
    ll = semilogx(freq,180/pi*angle([Installed_ST1CPS(2).f,...
                                     Installed_T240(2).f,...
                                     Installed_L4C(2).f,...
                                     Installed_ST1CPS(4).f,...
                                     Installed_T240(4).f,...
                                     Installed_L4C(4).f]));
    grid on;
    set(ll,'LineWidth',3)
    set(ll(4:6),'LineStyle','--')
    set(ll(1),'Color',colors.trans.cps)
    set(ll(2),'Color',colors.trans.t240)
    set(ll(3),'Color',colors.trans.l4c)
    set(ll(4),'Color',colors.rot.cps)
    set(ll(5),'Color',colors.rot.t240)
    set(ll(6),'Color',colors.rot.l4c)
    xlabel('Frequency [Hz]')
    ylabel('Phase [deg]')
    axis([freqRange -185 185])
    set(gca,'XTick',xTicks,'YTick',-180:45:180,'FontSize',16)
    legend('Z Low Pass (CPS)', 'Z Band Pass (T240)','Z High Pass (L4C)',...
        'RZ Low Pass (CPS)','RZ Band Pass (T240)','RZ High Pass (L4C)','Location','East')
    
    %% Plot the ST1 displacement sensor vs inertial sensor blend looking for complementarity
    figure(figNum)
    figNames{figNum} = [figTag '_ST1_DispVInert_Blend_ZRZ.pdf'];
    figNum = figNum + 1;
    subplot(211)
    ll = loglog(freq,abs([Designed_ST1LP(2).f ...
                          Designed_ST1HP(2).f ...
                          Designed_ST1LP(2).f + Designed_ST1HP(2).f...
                          Designed_ST1LP(4).f ...
                          Designed_ST1HP(4).f ...
                          Designed_ST1LP(4).f + Designed_ST1HP(4).f]));
    grid on;
    title({[IFO 'ISI' CHAMBER ' ST1 "' name.st1 '" Blend Filters'];...
        'Displacement LP vs Inertial HP, As Designed Complementarity'},...
        'FontSize',16)
    set(ll,'LineWidth',3)
    set(ll(4:6),'LineStyle','--')
    set(ll(1),'Color',colors.trans.cps)
    set(ll(2),'Color',colors.trans.l4c)
    set(ll(3),'Color',colors.trans.sum)
    set(ll(4),'Color',colors.rot.cps)
    set(ll(5),'Color',colors.rot.l4c)
    set(ll(6),'Color',colors.rot.sum)
    xlabel('Frequency [Hz]')
    ylabel('Magnitude [(nm/nm) or (nrad/nrad)]')
    axis([freqRange 1e-6 1e1])
    set(gca,'XTick',xTicks,'YTick',10.^(-6:1),'FontSize',16)
    
    subplot(212)
    ll = semilogx(freq,180/pi*angle([Designed_ST1LP(2).f ...
                                     Designed_ST1HP(2).f ...
                                     Designed_ST1LP(2).f + Designed_ST1HP(2).f...
                                     Designed_ST1LP(4).f ...
                                     Designed_ST1HP(4).f ...
                                     Designed_ST1LP(4).f + Designed_ST1HP(4).f]));
    grid on;
    set(ll,'LineWidth',3)
    set(ll(4:6),'LineStyle','--')
    set(ll(1),'Color',colors.trans.cps)
    set(ll(2),'Color',colors.trans.l4c)
    set(ll(3),'Color',colors.trans.sum)
    set(ll(4),'Color',colors.rot.cps)
    set(ll(5),'Color',colors.rot.l4c)
    set(ll(6),'Color',colors.rot.sum)
    xlabel('Frequency [Hz]')
    ylabel('Phase [deg]')
    axis([freqRange -185 185])
    set(gca,'XTick',xTicks,'YTick',-180:45:180,'FontSize',16)
    legend('Z Displacement LP (CPS)', 'Z Inertial HP (T240+L4C)','Sum',...
           'RZ Displacement LP (CPS)', 'RZ Inertial HP (T240+L4C)','Sum','Location','SouthEast')
    
    %% Plot the all ST1 complementary blends looking for complementarity
    figure(figNum)
    figNames{figNum} = [figTag '_ST1_Complementarity_ZRZ.pdf'];
    figNum = figNum + 1;
    subplot(211)
    ll = loglog(freq,abs([Comp_ST1CPS(1).f ...
        Comp_T240(1).f ...
        Comp_L4C(1).f ...
        Comp_ST1CPS(1).f + Comp_T240(1).f + Comp_L4C(1).f ...
        Comp_ST1CPS(3).f ...
        Comp_T240(3).f ...
        Comp_L4C(3).f ...
        Comp_ST1CPS(3).f + Comp_T240(3).f + Comp_L4C(3).f]));
    grid on;
    title({[IFO 'ISI' CHAMBER ' ST1 "' name.st1 '" Blend Filters'];...
        'Displacement LP vs Inertial HP, As Designed Complementarity'},...
        'FontSize',16)
    set(ll,'LineWidth',3)
    set(ll([4 8]),'LineWidth',5)
    set(ll(5:8),'LineStyle','--')
    set(ll(1),'Color',colors.trans.cps)
    set(ll(2),'Color',colors.trans.t240)
    set(ll(3),'Color',colors.trans.l4c)
    set(ll(4),'Color',colors.trans.sum)
    set(ll(5),'Color',colors.rot.cps)
    set(ll(6),'Color',colors.rot.t240)
    set(ll(7),'Color',colors.rot.l4c)
    set(ll(8),'Color',colors.rot.sum)
    xlabel('Frequency [Hz]')
    ylabel('Magnitude [(nm/nm) or (nrad/nrad)]')
    axis([freqRange 1e-6 1e1])
    set(gca,'XTick',xTicks,'YTick',10.^(-6:1),'FontSize',16)
    
    subplot(212)
    ll = semilogx(freq,180/pi*angle([Comp_ST1CPS(1).f ...
        Comp_T240(1).f ...
        Comp_L4C(1).f ...
        Comp_ST1CPS(1).f + Comp_T240(1).f + Comp_L4C(1).f ...
        Comp_ST1CPS(3).f ...
        Comp_T240(3).f ...
        Comp_L4C(3).f ...
        Comp_ST1CPS(3).f + Comp_T240(3).f + Comp_L4C(3).f]));
    grid on;
    set(ll,'LineWidth',3)
    set(ll([4 8]),'LineWidth',5)
    set(ll(5:8),'LineStyle','--')
    set(ll(1),'Color',colors.trans.cps)
    set(ll(2),'Color',colors.trans.t240)
    set(ll(3),'Color',colors.trans.l4c)
    set(ll(4),'Color',colors.trans.sum)
    set(ll(5),'Color',colors.rot.cps)
    set(ll(6),'Color',colors.rot.t240)
    set(ll(7),'Color',colors.rot.l4c)
    set(ll(8),'Color',colors.rot.sum)
    xlabel('Frequency [Hz]')
    ylabel('Phase [deg]')
    axis([freqRange -185 185])
    set(gca,'XTick',xTicks,'YTick',-180:45:180,'FontSize',16)
    legend('Z CPS LP', 'Z T240 BP','Z L4C HP','Sum',...
           'RZ CPS LP', 'RZ T240 BP','RZ L4C HP','Sum','Location','SouthEast')
end

%% Plot what comes out of Foton directly for ST2
figure(figNum)
figNames{figNum} = [figTag finalStageTag '_AsInstalledInFoton_XRY.pdf'];
figNum = figNum + 1;
subplot(211)
ll = loglog(freq,abs([Installed_ST2CPS(1).f,...
                      Installed_GS13(1).f,...
                      Installed_ST2CPS(3).f,...
                      Installed_GS13(3).f]));
grid on;
title({[IFO 'ISI' CHAMBER ' ' regexprep(finalStageTag,'\_','') ' "' name.st2 '" Blend Filters'];...
       'As Installed in Foton'},...
       'FontSize',16)
set(ll,'LineWidth',3)
set(ll(3:4),'LineStyle','--')
set(ll(1),'Color',colors.trans.cps)
set(ll(2),'Color',colors.trans.gs13)
set(ll(3),'Color',colors.rot.cps)
set(ll(4),'Color',colors.rot.gs13)
xlabel('Frequency [Hz]')
ylabel({'Magnitude';'[(nm/nm), (nm/s / m), (nrad/nrad), or (nrad/s / nrad)]'})
axis([freqRange 1e-6 1e4])
set(gca,'XTick',xTicks,'YTick',10.^(-6:4),'FontSize',16)

subplot(212)
ll = semilogx(freq,180/pi*angle([Installed_ST2CPS(1).f,...
                                 Installed_GS13(1).f,...
                                 Installed_ST2CPS(3).f,...
                                 Installed_GS13(3).f]));
grid on;
set(ll,'LineWidth',3)
set(ll(3:4),'LineStyle','--')
set(ll(1),'Color',colors.trans.cps)
set(ll(2),'Color',colors.trans.gs13)
set(ll(3),'Color',colors.rot.cps)
set(ll(4),'Color',colors.rot.gs13)
xlabel('Frequency [Hz]')
ylabel('Phase [deg]')
axis([freqRange -185 185])
set(gca,'XTick',xTicks,'YTick',-180:45:180,'FontSize',16)
legend('X Low Pass (CPS)','X High Pass (GS13)',...
       'RY Low Pass (CPS)','RY High Pass (GS13)','Location','East')
   
%% Plot the all ST2 complementary blends looking for complementarity 
figure(figNum)
figNames{figNum} = [figTag finalStageTag '_Complementarity_XRY.pdf'];
figNum = figNum + 1;
subplot(211)
ll = loglog(freq,abs([Designed_ST2LP(1).f ...
                      Designed_ST2HP(1).f ...
                      Designed_ST2LP(1).f + Designed_ST2HP(1).f...
                      Designed_ST2LP(3).f ...
                      Designed_ST2HP(3).f ...
                      Designed_ST2LP(3).f + Designed_ST2HP(3).f]));
grid on;                
title({[IFO 'ISI' CHAMBER ' ' regexprep(finalStageTag,'\_','') ' "' name.st2 '" Blend Filters'];...
        'Displacement LP vs Inertial HP, As Designed Complementarity'},...
        'FontSize',16)
set(ll,'LineWidth',3)
set(ll(4:6),'LineStyle','--')
set(ll(1),'Color',colors.trans.cps)
set(ll(2),'Color',colors.trans.l4c)
set(ll(3),'Color',colors.trans.sum)
set(ll(4),'Color',colors.rot.cps)
set(ll(5),'Color',colors.rot.l4c)
set(ll(6),'Color',colors.rot.sum)
xlabel('Frequency [Hz]')
ylabel('Magnitude [(nm/nm) or (nrad/nrad)]')
axis([freqRange 1e-6 1e1])
set(gca,'XTick',xTicks,'YTick',10.^(-6:1),'FontSize',16)

subplot(212)
ll = semilogx(freq,180/pi*angle([Designed_ST2LP(1).f ...
                                 Designed_ST2HP(1).f ...
                                 Designed_ST2LP(1).f + Designed_ST2HP(1).f...
                                 Designed_ST2LP(3).f ...
                                 Designed_ST2HP(3).f ...
                                 Designed_ST2LP(3).f + Designed_ST2HP(3).f]));
grid on;
set(ll,'LineWidth',3)
set(ll(4:6),'LineStyle','--')
set(ll(1),'Color',colors.trans.cps)
set(ll(2),'Color',colors.trans.l4c)
set(ll(3),'Color',colors.trans.sum)
set(ll(4),'Color',colors.rot.cps)
set(ll(5),'Color',colors.rot.l4c)
set(ll(6),'Color',colors.rot.sum)
xlabel('Frequency [Hz]')
ylabel('Phase [deg]')
axis([freqRange -185 185])
set(gca,'XTick',xTicks,'YTick',-180:45:180,'FontSize',16)
legend('X Displacement LP (CPS)', 'X Inertial HP (GS13)','Sum',...
       'RY Displacement LP (CPS)', 'RY Inertial HP (GS13)','Sum','Location','SouthEast')   
   
%% Plot what comes out of Foton directly for ST2
figure(figNum)
figNames{figNum} = [figTag finalStageTag '_AsInstalledInFoton_ZRZ.pdf'];
figNum = figNum + 1;
subplot(211)
ll = loglog(freq,abs([Installed_ST2CPS(2).f,...
                      Installed_GS13(2).f,...
                      Installed_ST2CPS(4).f,...
                      Installed_GS13(4).f]));
grid on;
title({[IFO 'ISI' CHAMBER ' ' regexprep(finalStageTag,'\_','') ' "' name.st2 '" Blend Filters'];...
       'As Installed in Foton'},...
       'FontSize',16)
set(ll,'LineWidth',3)
set(ll(3:4),'LineStyle','--')
set(ll(1),'Color',colors.trans.cps)
set(ll(2),'Color',colors.trans.gs13)
set(ll(3),'Color',colors.rot.cps)
set(ll(4),'Color',colors.rot.gs13)
xlabel('Frequency [Hz]')
ylabel({'Magnitude';'[(nm/nm), (nm/s / m), (nrad/nrad), or (nrad/s / nrad)]'})
axis([freqRange 1e-6 1e4])
set(gca,'XTick',xTicks,'YTick',10.^(-6:4),'FontSize',16)

subplot(212)
ll = semilogx(freq,180/pi*angle([Installed_ST2CPS(2).f,...
                                 Installed_GS13(2).f,...
                                 Installed_ST2CPS(4).f,...
                                 Installed_GS13(4).f]));
grid on;
set(ll,'LineWidth',3)
set(ll(3:4),'LineStyle','--')
set(ll(1),'Color',colors.trans.cps)
set(ll(2),'Color',colors.trans.gs13)
set(ll(3),'Color',colors.rot.cps)
set(ll(4),'Color',colors.rot.gs13)
xlabel('Frequency [Hz]')
ylabel('Phase [deg]')
axis([freqRange -185 185])
set(gca,'XTick',xTicks,'YTick',-180:45:180,'FontSize',16)
legend('Z Low Pass (CPS)','Z High Pass (GS13)',...
       'RZ Low Pass (CPS)','RZ High Pass (GS13)','Location','East')
   
%% Plot the all ST2 complementary blends looking for complementarity 
figure(figNum)
figNames{figNum} = [figTag finalStageTag '_Complementarity_ZRZ.pdf'];
figNum = figNum + 1;
subplot(211)
ll = loglog(freq,abs([Designed_ST2LP(2).f ...
                      Designed_ST2HP(2).f ...
                      Designed_ST2LP(2).f + Designed_ST2HP(2).f...
                      Designed_ST2LP(4).f ...
                      Designed_ST2HP(4).f ...
                      Designed_ST2LP(4).f + Designed_ST2HP(4).f]));
grid on;                
title({[IFO 'ISI' CHAMBER ' ' regexprep(finalStageTag,'\_','') ' "' name.st2 '" Blend Filters'];...
        'Displacement LP vs Inertial HP, As Designed Complementarity'},...
        'FontSize',16)
set(ll,'LineWidth',3)
set(ll(4:6),'LineStyle','--')
set(ll(1),'Color',colors.trans.cps)
set(ll(2),'Color',colors.trans.l4c)
set(ll(3),'Color',colors.trans.sum)
set(ll(4),'Color',colors.rot.cps)
set(ll(5),'Color',colors.rot.l4c)
set(ll(6),'Color',colors.rot.sum)
xlabel('Frequency [Hz]')
ylabel('Magnitude [(nm/nm) or (nrad/nrad)]')
axis([freqRange 1e-6 1e1])
set(gca,'XTick',xTicks,'YTick',10.^(-6:1),'FontSize',16)

subplot(212)
ll = semilogx(freq,180/pi*angle([Designed_ST2LP(2).f ...
                                 Designed_ST2HP(2).f ...
                                 Designed_ST2LP(2).f + Designed_ST2HP(2).f...
                                 Designed_ST2LP(4).f ...
                                 Designed_ST2HP(4).f ...
                                 Designed_ST2LP(4).f + Designed_ST2HP(4).f]));
grid on;
set(ll,'LineWidth',3)
set(ll(4:6),'LineStyle','--')
set(ll(1),'Color',colors.trans.cps)
set(ll(2),'Color',colors.trans.l4c)
set(ll(3),'Color',colors.trans.sum)
set(ll(4),'Color',colors.rot.cps)
set(ll(5),'Color',colors.rot.l4c)
set(ll(6),'Color',colors.rot.sum)
xlabel('Frequency [Hz]')
ylabel('Phase [deg]')
axis([freqRange -185 185])
set(gca,'XTick',xTicks,'YTick',-180:45:180,'FontSize',16)
legend('Z Displacement LP (CPS)', 'Z Inertial HP (GS13)','Sum',...
       'RZ Displacement LP (CPS)', 'RZ Inertial HP (GS13)','Sum','Location','SouthEast')     
   
%% Print figures, if desired
if printFigs
    mergeCommand = ['pdfmerge ' figTag '.pdf'];
    
    for iFig = 1:length(figNames)
        figure(iFig)
        FillPage('w')
        IDfig(author)
        saveas(gcf,[figNames{iFig}])
        mergeCommand = [mergeCommand ' ' figNames{iFig}];
    end
    
    system(mergeCommand);
end
disp('Done.')