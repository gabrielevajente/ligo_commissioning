function [coe,s] = quack_to_rule_them_all(gomo,Fs,Method,name,label,subblock, turnon, ramptime)
% quack_to_rule_them_all  SEI version of quack
% function [coe,s] =quack_to_rule_them_all(gomo,Fs,Method,name,label,subblock, turnon, ramptime)
% 
% Foton Discrete Time Filter Maker
% This function takes as arguments, 
% gomo   : a matlab 'sys' object defining the filter
% Fs     : the sample freq (samples per second) 
%
% Example:
% [z,p,k] = ellip(6,1,40,2*pi*35,'s');
% goo = zpk(z,p,k);
%
% [coe,s] = quack_to_rule_them_all(goo, 4096,'T','ITMX_ST1_DAMP_X','damp');
%
% name: the name of the CDS filter module, as used by foton,
% i.e. the filter name minus the IFO and Subsystem, 
% e.g. 'ITMX_ST1_DAMP_X'  (where the full channel is S1:ISI-ITMX_ST1_DAMP_X )
%
% label: the text to appear in the medm screen for the subblock
% e.g. 'damp'
%
% It returns 
% coe: the digital filter coefficients in the order
%        they go in the CDS standard filter modules.
%        i.e. LSC FE, ASC FE, DSC, MSC, HPI .  
% s  : It also returns the a string that can be written to a foton chans file.
%
%
% New features in this version include a new method 'D', which you can use
% if you have already done your control design digitally, or have manually
% dicretized the controller.
%
% if called with the optional form
% [coe,s] =quack_to_rule_them_all2(gomo,Fs,Method,name,label, SUBBLOCK)
% then it puts the filter into the 'subblock' element of the 10 element 
% filter bank. Otherwise, it goes into the first one.
%   The subblocks are numbered 0 to 9.
%
% if called with the additional optional form
% [coe,s] =quack_to_rule_them_all2(gomo,Fs,Method,name,label,subblock, TURNON)
%  then you can specify a turnon rule. The two defined rules are:
%  'immediate' which is the default, foton code 21
%         -  Input switch will switch with output switch. When filter
%         output switch goes to ?OFF?, all filter history variables will be set to zero.
%         - output Immediate. The output will switch on or off as soon as commanded.
%      or
%  'zerocrossing' which turns on the filter when close enough - foton code 24
%         -  Input switch will switch with output switch. When filter
%         output switch goes to ?OFF?, all filter history variables will be set to zero.
%         - output Zero Crossing: The output will switch when the filter
%         input crosses zero. 
%    defines 300 counts as 'close enough' and 2 sec (clock cycles was 8192, now
%    2* Fs) until the filter will switch anyway. (per Vincent's testing on SEI)
%      or
%  'ramp' which ramps up the filter gain - foton code 22
%         -  Input switch will switch with output switch. When filter
%         output switch goes to ?OFF?, all filter history variables will be set to zero.
%         - output ramp
%      the Default ramp time is 5 sec. To use a different ramp time,
%      include that as the 8th argument, defined in Seconds.
%      e.g. to have an 11 second ramp, you could call as:
%  [coe,s] = quack_to_rule_them_all(goo, 4096,'D','ITMX_ST1_DAMP_X','damp',0,
%  'ramp', 5);
%
% updated to run with RCG by B Lantz on April 20 2011
% 1) confirm that it accepts 'gain-only' stages.
%    these should have a gain, and 1 SOS whose cooefs are all 0.
% 2) re-instated ability to omit the subblock number.
% 3) update the help.
%
% update by BTL to add the turnon input.
%
% update by BTL to increase precision 
%  of gain and coeff's 16 significant figures
%
% update by BTL on Aug 22, 2012
%   change 'zerocrossing' timeout to 2 * Fs from 8192
%   add 'ramp' option, set to 2 sec default, or user input
%
%   NOTE - remember that if this is called by autoquack, then autoquack
%   defines the turnon and the ramp explicitly, even if you do not.

if nargin == 5
    subblock = 0;
    turnon = 'immediate';
    ramptime = 5;
elseif nargin == 6
    turnon = 'immediate';
    ramptime = 5;
elseif nargin == 7;
    ramptime = 5;
elseif nargin == 8;
    %ok
else
    error('quack_to_rule_them_all needs at least 5 input arguments')
end

if strncmpi(turnon, 'immediate',3)
    switch_type    = 21;
    switch_tol     = 0;
    switch_timeout = 0;
elseif strncmpi(turnon, 'zerocrossing', 3);
    switch_type    = 24;
    switch_tol     = 300;
    switch_timeout = 2 * Fs;  % was 8192;
elseif strncmpi(turnon, 'ramp', 3);
    switch_type    = 22;
    switch_tol     = ramptime * Fs;  % 5 second ramp;
    switch_timeout = 0;
else
    error('if turnon is specified, it must be ''immediate'', ''ramp'', or ''zerocrossing''')
end    

if strcmp(Method,'D')  % use Method = 'D' if you have already discretized
    gah = gomo;
else
    dig_method_str = {'tustin';'foh';'zoh';'matched';'prewarp'};
    digitization = strmatch(Method,['T';'F';'Z';'M';'P']);
    dig_method = dig_method_str{digitization};

    if  strmatch(Method,'P')
        gah = zpk(c2d(ss(gomo),1/Fs,'prewarp',2*pi*0.5));
    else
        gah = zpk(c2d(ss(gomo),1/Fs,dig_method));
    end
end


[zd,pd,kd] = zpkdata(gah,'v');
% SOSing the digital zpk

[sos,gs] = zp2sos(zd,pd,kd);
[g,ca] = sos_shuffle(sos);
if g == 0
    coe = 0;
    s='';
    disp('g should not equal 0')
else
   coe = real([gs ca']);
   % produce formatted output
   labelroot = label;
   sublabel = ['a','b','c','d','e','f','g','h','i','j'];
   %fprintf(1, '%134c%c\n', ' ', '#');
   
   if strcmp(label, name)
       % number of sos
       nsos = (length(coe)-1)/4;
       % number of modules of 10 sos
       nmod = ceil(nsos/10);
   else
       nmod = 1;
   end
   
   s = '';
   for j = 0:(nmod-1)
        nlower = (j*40+6);
        nupper = min(length(coe)-3,nlower+32);
        ns = (nupper-nlower)/4+2;

        if j == 0
            s = [s, sprintf( '\n')];
        end

        %s = [s,sprintf( 'NAME # 21 1 0 0  LABEL   ')];
        
        if strcmp(label, name) && nmod > 1
            newlabel = strcat(labelroot,'_',sublabel(j+1));
            %s = [s,sprintf( '%s %d 21 %d 0 0  %s   ', ...
            s = [s,sprintf( '%s %d %d %d %d %d  %s   ', ...
                name, j+subblock, switch_type, ns, switch_tol, switch_timeout, newlabel)]; 
        
        else
            s = [s,sprintf( '%s %d %d %d %d %d  %s   ', ...
                name, subblock, switch_type, ns, switch_tol, switch_timeout, label)]; 
           % s = [s,sprintf( '%s %d 21 %d 0 0  %s   ',name,subblock,ns,label)];
        end
        
%        if abs(coe(1)) < 1e-11   %BTL added warning 
%            disp('WARNING for ')
%            disp(['Filter ',name,', subblock ', subblock,'label ', label])
%            disp('The gain is less than 1e-11, which sometimes causes numerical issues')
%        end

        
        if j == 0
           s = [s,string_16sigfig(coe(1))];       %was %20.12f
           s = [s,string_16sigfig(coe(2:5))];     %was %20.14f
           s = [s,sprintf( '\n')];
        else
           s = [s,sprintf( '1.000000000000')];  %if more than 1 module is needed.
           s = [s,string_16sigfig(coe((nlower-4):(nlower-1)))];   % was %20.14f
           s = [s,sprintf( '\n')];
        end           
        for n = nlower:4:nupper
           s = [s,sprintf( '%24c %20c', ' ', ' ')];
           s = [s,string_16sigfig(coe(n:n+3))];      % was %20.14f
           s = [s,sprintf( '\n')];
        end
        
        %{
        if j == 0
           s = [s,sprintf( '%20.12f', coe(1))]; 
           s = [s,sprintf( '%20.14f', coe(2:5))];
           s = [s,sprintf( '\n')];
        else
           s = [s,sprintf( '1.000000000000')];
           s = [s,sprintf( '%20.14f', coe((nlower-4):(nlower-1)))]; 
           s = [s,sprintf( '\n')];
        end           
        for n = nlower:4:nupper
           s = [s,sprintf( '%24c %20c', ' ', ' ')];
           s = [s,sprintf( '%20.14f',coe(n:n+3))];
           s = [s,sprintf( '\n')];
        end
        %}

   end
end


