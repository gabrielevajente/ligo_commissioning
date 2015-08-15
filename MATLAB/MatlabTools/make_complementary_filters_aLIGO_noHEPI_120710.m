function [lp_comp_filter, hp_comp_filter] = make_complementary_filters_aLIGO_noHEPI_120710(DOF)
%make_complementary_filters_aLIGO_noHEPI_120710(DOF)  makes complementary blend filters for aLIGO HAM ISI
% trys to make some stage 1 BS-ISI blends for x5 at .35 Hz for x, y, z, rz
%
% call as
% [lp_comp_filter, hp_comp_filter] = make_complementary_filters_aLIGO_noHEPI_120710(DOF)
% lp_comp_filter and hp_comp_filter are sys filters, lowpass and highpass
% complementary filters (add to 1) 
% DOF is the degree of freedom, and can be 'X', 'Y', 'Z', 'rX', 'rY' or 'rZ'
% note that X = Y and  rX = rY.
%
% BTL July 10, 2012
%

minreal_tol = 1e-2;  % at this level, I've not seen any trouble.
% 5e-2 generates sum which can be a few percent away from 1 (no trouble,
% but can be noticed by careful inspection)

if (strncmpi(DOF, 'rX', 2) || strncmpi(DOF, 'rY', 2))
    
    %             (freq,order,ripple,stopDB,zQ)
    thing1     = myellip_z2(.35,2,2,10,3)* 10^(2/20); % was .35,2,2,12,3
    poles      = -2*pi*[pair(2,0) 8];  % [pair(2,0) 8];
    zeros      = -2*pi*[];
    gain       = abs(prod(poles))./abs(prod(zeros));
    
    more_poles = zpk(zeros,poles,gain);
    LP_proto   = thing1 * more_poles;

    tilt_HP_temp        = 1 - LP_proto;
    tilt_moreHP_filter  = myhpellip_z(.15, 2, 1, 10, 3)*10^(1/20);
    tilt_HPellip        = myhpbutter(0.010, 3);  % 0.01 Hz, 3 pole hp butterworth filter
    % BTL changed from a 2 to a 3 pole on Oct 21, 2011 per J Kissel's warnings
    HP_proto            = tilt_HP_temp * tilt_moreHP_filter * tilt_HPellip;


    lp_comp_filter = minreal(LP_proto/ (LP_proto + HP_proto),minreal_tol);
    hp_comp_filter = minreal(HP_proto/ (LP_proto + HP_proto),minreal_tol);
    
    if 1
        figure
        bode(tilt_HP_temp,tilt_moreHP_filter,tilt_HPellip,HP_proto);
        title('parts of the tilt high pass prototype')
        legend('base','more LF zeros','more LF isolation','total')
        
        freq = logspace(log10(.001),log10(50),500);
        w = 2*pi*freq;
        LP_FR = squeeze(freqresp(lp_comp_filter ,w));
        HP_FR = squeeze(freqresp(hp_comp_filter ,w));
        figure
        ll=loglog(...
            freq, abs(LP_FR),...
            freq, abs(HP_FR));
        title('Complementary Blend Filters for HAM RX and RY, 111021','FontSize',14)
        set(ll,'LineWidth',2)
        set(gca,'FontSize',14)
        xlim([.001 50])
        ylim([1e-6 10])
        xlabel('Frequency (Hz)')
        ylabel('Magnitude (arb)')
        legend('CPS (HAMISI\_111021)','GS13 (HAMISI\_111021)','Location','South')
        grid on        
        FillPage('t')
        IDfig
    end
    
elseif (strncmpi(DOF, 'X', 1) || strncmpi(DOF, 'Y', 1))

    %% dip at .67, pushing on corner freq...
    %X_disp_ellip = myellip_z2(.40,2,2,10,10)* 10^(2/20);

    %X_disp_ellip = myellip_z2(.35,2,1,10,10)* 10^(1/20);   % before march 12, 2009
    %X_more_poles = zpk([],-2*pi*[1,4*[1+1i, 1-1i]/sqrt(2)],(2*pi*1)*(2*pi*4)^2);
    X_disp_ellip = myellip_z2(.20,2,1,12,10)* 10^(1/20);
    X_more_poles = zpk([],-2*pi*[1.0,4*[1+1i, 1-1i]/sqrt(2)],(2*pi*1.0)*(2*pi*4)^2);


    X_LP_proto = X_disp_ellip * X_more_poles;

    X_HP_temp        = 1 - X_LP_proto;
    X_moreHP_filter  = myhpellip_z(.08,2,0.7,10,3)*10^(0.7/20);
    X_HPbutter       = myhpbutter(0.013,3);  % 0.01 Hz, 3 pole hp butterworth filter
    X_HP_proto       = X_HP_temp * X_moreHP_filter * X_HPbutter;

    lp_comp_filter = minreal(X_LP_proto/ (X_LP_proto + X_HP_proto), minreal_tol);
    hp_comp_filter = minreal(X_HP_proto/ (X_LP_proto + X_HP_proto), minreal_tol);

    if 1
        figure
        bode(X_HP_temp, X_moreHP_filter, X_HPbutter, X_HP_proto);
        title('parts of the X high pass prototype')
        legend('HP base','HP more zeros','even more zeros','total')
        
        freq = logspace(log10(.001),log10(50),300);
        w = 2*pi*freq;
        LP_FR = squeeze(freqresp(lp_comp_filter ,w));
        HP_FR = squeeze(freqresp(hp_comp_filter ,w));
        figure
        ll=loglog(...
            freq, abs(LP_FR),...
            freq, abs(HP_FR));
        set(ll,'LineWidth',2)
        %axis([.04 20 1e-3 5])
        
        title('Complementary Blend Filters for HAM X and Y, 111021','FontSize',14)
        set(gca,'FontSize',14)
        xlim([.001 50])
        ylim([1e-6 10])
        xlabel('Frequency (Hz)')
        ylabel('Magnitude TF')
        legend('CPS (HAMISI\_111021)','GS13 (HAMISI\_111021)','Location','South')
        grid on
        FillPage('t')
        IDfig
    end
    
elseif strncmpi(DOF, 'rZ',2)
    %% this is the new stuff from march 12, 2009, BTL
    RZ_disp_ellip = myellip_z2(.25,2,1,25,5)* 10^(1/20);
    RZ_more_poles = zpk([],-2*pi*[1.1*[1+1i, 1-1i]/sqrt(2),8],(2*pi*1.1)^2 * (2*pi*8));
    RZ_LP_proto   = RZ_disp_ellip * RZ_more_poles;

    RZ_HP_temp        = 1 - RZ_LP_proto;
    RZ_moreHP_filter  = zpk(0,-2*pi*.02,1);
    RZ_HPbutter       = myhpbutter(0.04,2);
    RZ_HP_proto       = RZ_HP_temp * RZ_HPbutter * RZ_moreHP_filter;

    lp_comp_filter = minreal(RZ_LP_proto/ (RZ_LP_proto + RZ_HP_proto), minreal_tol);
    hp_comp_filter = minreal(RZ_HP_proto/ (RZ_LP_proto + RZ_HP_proto), minreal_tol);

 
  
    if 1
        figure
        bode(RZ_HP_temp,RZ_HPbutter,RZ_moreHP_filter,RZ_HP_proto);
        title('parts of the RZ high pass prototype')
        legend('HP base','HP more zeros','even more zeros','total')

        freq = logspace(log10(.001),log10(50),300);
        w = 2*pi*freq;
        LP_FR = squeeze(freqresp(lp_comp_filter ,w));
        HP_FR = squeeze(freqresp(hp_comp_filter ,w));
        figure
        ll=loglog(...
            freq, abs(LP_FR),...
            freq, abs(HP_FR));
        set(ll,'LineWidth',2)
        %axis([.04 20 1e-3 5])

        title('Complementary Blend Filters for HAM RZ, 111021','FontSize',14)
        set(gca,'FontSize',14)
        xlim([.001 50])
        ylim([1e-6 10])
        xlabel('Frequency (Hz)')
        ylabel('Magnitude TF')
        legend('CPS (HAMISI\_111021)','GS13 (HAMISI\_111021)','Location','South')
        grid on        
        FillPage('t')
        IDfig
        
    end


elseif strncmpi(DOF, 'Z', 1)
%    Z_disp_ellip = myellip_z2(.3,2,1,13,10)* 10^(1/20);  % before march 12
    Z_disp_ellip = myellip_z2(.3,2,1,23,5)* 10^(1/20);  % after march 12, 2009 BTL
    Z_more_poles = zpk([],-2*pi*[1,4*[1+1i, 1-1i]/sqrt(2)],(2*pi*1)*(2*pi*4)^2);
    Z_LP_proto   = Z_disp_ellip * Z_more_poles;

    
    Z_HP_temp        = 1 - Z_LP_proto;

    % this one is better, less amp of the disp sensor, and less geo noise at 0.1
    Z_moreHP_filter  = zpk(0,-2*pi*.02,1);
    Z_HPbutter       = myhpbutter(0.04,2);
    Z_HP_proto       = Z_HP_temp * Z_HPbutter * Z_moreHP_filter;

    lp_comp_filter = minreal(Z_LP_proto/ (Z_LP_proto + Z_HP_proto), minreal_tol);
    hp_comp_filter = minreal(Z_HP_proto/ (Z_LP_proto + Z_HP_proto), minreal_tol);
 
  
    if 1
        figure
        bode(Z_HP_temp,Z_HPbutter,Z_moreHP_filter,Z_HP_proto);
        title('parts of the Z high pass prototype')
        legend('HP base','more zeros','more filter','total')

        freq = logspace(log10(.001),log10(50),300);
        w = 2*pi*freq;
        LP_FR = squeeze(freqresp(lp_comp_filter ,w));
        HP_FR = squeeze(freqresp(hp_comp_filter ,w));
        figure
        ll=loglog(...
            freq, abs(LP_FR),...
            freq, abs(HP_FR));
        set(ll,'LineWidth',2)
        %axis([.04 20 1e-3 5])

        title('Complementary Blend Filters for HAM Z, 111021','FontSize',14)
        set(gca,'FontSize',14)
        xlim([.001 50])
        ylim([1e-6 10])
        xlabel('Frequency (Hz)')
        ylabel('Magnitude TF')
        legend('CPS (HAMISI\_111021)','GS13 (HAMISI\_111021)','Location','South')
        grid on        
        FillPage('t')
        IDfig
        
    end

else
    disp(' Error, make_complementary_filters must be called with a DOF argument')
    disp(' options are: ''X'', ''Y'', ''Z'', ''rX'', ''rY'', or ''rZ''')
    lp_comp_filter = 0; hp_comp_filter = 0;
end



    
    
    
    
    