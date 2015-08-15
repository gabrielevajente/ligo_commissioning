% this is an example script which uses the vectfit4.m routine to fit the
% old (S6 and before) HEPI sensor correction path (FIR and IIR
% complementary filters) to an IIR filter. The output is in 3 formats:
%   a) vectfit itself outputs in the state space (ss) format
%   b) this is then converted to zpk format using zpkdata
%   c) this routine then calls quack3andahalf to output SOS coefficients
%   which can be copied into foton
%
% vectfit is free to use for non-commercial uses, and the authors of the
% code request that the following citations be used when vecfit is used in
% scientific work:
%
% [1] B. Gustavsen and A. Semlyen, "Rational approximation of frequency       
%     domain responses by Vector Fitting", IEEE Trans. Power Delivery,        
%     vol. 14, no. 3, pp. 1052-1061, July 1999.                                
% [2] B. Gustavsen, "Improving the pole relocating properties of vector
%     fitting", IEEE Trans. Power Delivery, vol. 21, no. 3, pp. 1587-1592,
%     July 2006.   
%

% [3] D. Deschrijver, M. Mrozowski, T. Dhaene, and D. De Zutter,
%     "Macromodeling of Multiport Systems Using a Fast Implementation of
%     the Vector Fitting Method", IEEE Microwave and Wireless Components 
%     Letters, vol. 18, no. 6, pp. 383-385, June 2008.
%
% vectfit4.m and quack3andahalf.m are located in the Common/MatlabTools/
% directory of the seismic svn (amongst other places)
%
% the FIR coefficients this script loads are also in that directory, in the
% file oldhepifir.txt
color_order
rads = 180/pi;
printfigs = 0;
fs = 4096;
f = logspace(-3,2,1e4);
%% FIR_X_DF(3)
z1 = [(-1.52579e-05 + 1i*1.52588e-05); (-1.52579e-05 - 1i*1.52588e-05); 3.05186e-05; -0.113097; -0.376991];
p1 = [(-0.0287995 + 1i*0.024327); (-0.0287995 - 1i*0.024327); -0.00363372; -0.0376988; -0.391157];
k1 = 0.999996; % z, p, k from the foton s-plane

[z1,p1,k1] = bilinear(z1,p1,k1,fs); % c2d
[sos1, g1] = zp2sos(z1,p1,k1);
g1 = real(g1);

fr1 = g1*sos2freqresp(sos1,2*pi*f,fs);
% df_data = g1*sosfilt(sos1,df_data);
%% FIR_X_DF(4)
z2 = [(0 + 1i*726.745); (0 - 1i*726.745)];
p2 = [(-30.8135 + 1i*122.921); (-30.8135 - 1i*122.921); -63.5343];
k2 = 1.93181; % z, p, k from the foton s-plane
[z2,p2,k2] = bilinear(z2,p2,k2,fs); % c2d
[sos2, g2] = zp2sos(z2,p2,k2);
g2 = real(g2);
fr2 = g2*sos2freqresp(sos2,2*pi*f,fs);
% df_data = g2*sosfilt(sos2,df_data);

%% HEPI FIR
fircoef = load('oldhepifir.txt');
fr3 = freqz(fircoef,1,f,2);

% df_data = decimate(df_data, fs/2,'FIR'); % Down-sampling the data
% df_data = filter(fircoef, 1, df_data);      % Filter the data
% df_data = interp(df_data, fs/2);         % Upper-sampling the data

%% FIR_X_UF(2)
z4 = [(-0.879646 +1i*12.5355); (-0.879646 - 1i*12.5355); -0.0753982; -0.11781];
p4 = [(-0.8947 + 1i*1.72158); (-0.8947 - 1i*1.72158); (-37.3678 + 1i*5.06479); (-37.3678 - 1i*5.06479); -0.0713864; -0.13866; -70.9108];
k4 = 2678.58; % z, p, k from the foton s-plane

[z4,p4,k4] = bilinear(z4,p4,k4,fs); % c2d

[sos4, g4] = zp2sos(z4,p4,k4);
g4 = real(g4);

fr4 = g4*sos2freqresp(sos4,2*pi*f,fs);
% df_data = g3*sosfilt(sos3,df_data);

%% Parallel FIR_X_CF path
z5 = [-5.16536e-08; -1.40035e-06; 1.44706e-06; -2.32051; -30.1587; -47.1218; -68.045];
p5 = [(-0.8947 + 1i*1.72157); (-0.8947 - 1i*1.72157); (-37.3677 + 1i*5.06478); (-37.3677 - 1i*5.06478); -0.0713858; -0.13866; -70.9108];
k5 = 1.00001; % z, p, k from the foton s-plane
[z5,p5,k5] = bilinear(z5,p5,k5,fs); % c2d
[sos5, g5] = zp2sos(z5,p5,k5);
g5 = real(g5);

fr5 = g5*sos2freqresp(sos5,2*pi*f,fs);

% cf_data = g5*sosfilt(sos5,cf_data);

%% DF-FIR-UF 
df_fr = fr1.*fr2.*fr3.*fr4;

cf_fr = fr5;

complementary = abs(df_fr).*exp(1i*angle(df_fr)) + abs(cf_fr).*exp(1i*angle(cf_fr));
% data = 5*(df_data + cf_data); % factor 5 comes from additional path

%% vectfit call
INPUT = complementary;
N = 60; %order of approximation
poles = logspace(-1.5,log10(fs/4),N);   %make sure poles are below the Nyquist

% weight = ones(size(z));
weight = 1./f;

opts.relax = 1;      % Use vector fitting with relaxed non-triviality constraint
opts.stable = 1;     % Enforce stable poles
opts.asymp = 3;      % Include both D, E in fitting    
opts.skip_pole = 0;  % Do NOT skip pole identification
opts.skip_res = 0;   % Do NOT skip identification of residues (C,D,E) 
opts.cmplx_ss = 1;   % Create complex state space model

opts.spy1 = 0;       % No plotting for first stage of vector fitting
opts.spy2 = 3;       % Create magnitude plot for fitting of f(s) 
opts.logx = 1;       % Use logarithmic abscissa axis
opts.logy = 1;       % Use logarithmic ordinate axis 
opts.errplot = 1;    % Include deviation in magnitude plot
opts.phaseplot = 1;  % Also produce plot of phase angle (in addition to magnitiude)
opts.legend =1;      % Do include legends in plots
opts.fignum = 1;

errss = [];
disp('vector fitting...')
[SER,poles,rmserr,fit] = vectfit4(INPUT,1i*2*pi*f,poles,weight,opts); 
errss = [errss rmserr];

for kk = 1:5
    [SER,poles,rmserr,fit] = vectfit4(INPUT,1i*2*pi*f,poles,weight,opts);
    errss = [errss rmserr];
    pause(0.1)
end

disp('Done.')

A = full(SER.A);
B = SER.B;
C = SER.C;
D = SER.D;
E = SER.E;

%% get zeros and poles
[z,p,k] = zpkdata(ss(A,B,C,D),'v');
z = round(z*1e9)/1e9;  p = round(p*1e9)/1e9;

if printfigs ==1
    orient landscape
    print -dpsc firfit.ps
end
fir_fit = zpk(z,p,k);

%save fit
First.f = f;
First.z = z;
First.k = k;
First.p = p;
First.Input = INPUT;
First.fir_fit = fir_fit;
First.Comment = '60 pole/zero fit of what we have now';

save FIR_TIF First
 
%% try fitting again with fiddled data (1Hz cutoff)
fo = 1;
Index = find(f>fo,1);
Diddle =1 + (First.Input(Index)-1)*(exp(-(f-fo)));
NEW_Input = First.Input;
NEW_Input(Index:end) = Diddle(Index:end);

Index = find(f>0.1,1);
GOAL = NEW_Input;
GOAL(Index:end) = 1;


errss = [];
disp('vector fitting...')
[SER,poles,rmserr,fit] = vectfit4(NEW_Input,1i*2*pi*f,poles,weight,opts); 
errss = [errss rmserr];

for kk = 1:5
    [SER,poles,rmserr,fit] = vectfit4(NEW_Input,1i*2*pi*f,poles,weight,opts);
    errss = [errss rmserr];
    pause(0.1)
end

disp('Done.')

A = full(SER.A);
B = SER.B;
C = SER.C;
D = SER.D;
E = SER.E;

%  get zeros and poles
[z,p,k] = zpkdata(ss(A,B,C,D),'v');
z = sort(z);
p = sort(p);
z = round(z*1e9)/1e9;  p = round(p*1e9)/1e9;


 %save new fit
Second.f = f;
Second.z = z;
Second.k = k;
Second.p = p;
Second.Input = NEW_Input;
Second.fir_fit = fir_fit;
Second.Comment = '60 pole/zero fit of a modified what we have now exp(-(f-1Hz))';


save FIR_TIF Second -append

%% now screw around with poles and zeros
if imag(z(3)) == 0
    z(1:3) = 0;  %
else
    z(1:4) = 0;
end

  min_fit = minreal(zpk(z,p,k),1E-3);
 minfitresp = transpose(squeeze(freqresp( min_fit ,2*pi*Second.f)));
[zz kk] = zero(min_fit);
pp = pole(min_fit);

 %save new fit
Third.f = f;
Third.z = zz;
Third.k = kk;
Third.p = pp;
Third.Input = NEW_Input;
Third.fir_fit =  min_fit;
Third.Comment = 'moved 3 zeros to zero and ran minreal to get 32 poles/zeros';


save FIR_TIF Third -append

       
%% try fitting again with fiddled data (0.1Hz cutoff)
fo = 0.1;
Index = find(f>fo,1);
Diddle =1 + (First.Input(Index)-1)*(exp(-10*(f-fo)));
NEW_Input = First.Input;
NEW_Input(Index:end) = Diddle(Index:end);

 

errss = [];
disp('vector fitting...')
[SER,poles,rmserr,fit] = vectfit4(NEW_Input,1i*2*pi*f,poles,weight,opts); 
errss = [errss rmserr];

for kk = 1:5
    [SER,poles,rmserr,fit] = vectfit4(NEW_Input,1i*2*pi*f,poles,weight,opts);
    errss = [errss rmserr];
    pause(0.1)
end

disp('Done.')

A = full(SER.A);
B = SER.B;
C = SER.C;
D = SER.D;
E = SER.E;

%  get zeros and poles
[z,p,k] = zpkdata(ss(A,B,C,D),'v');
z = sort(z);
p = sort(p);
z = round(z*1e9)/1e9;  p = round(p*1e9)/1e9;
new_fit = zpk(z,p,k);


 %save new fit
Fourth.f = f;
Fourth.z = z;
Fourth.k = k;
Fourth.p = p;
Fourth.Input = NEW_Input;
Fourth.fir_fit = new_fit;
Fourth.Comment = '60 pole/zero fit of a "GOAL" == 1 >0.1Hz';


save FIR_TIF Fourth -append      
      




 %%
  newfitresp = transpose(squeeze(freqresp(zpk(z,p,k) ,2*pi*Second.f)));
  fitresp = transpose(squeeze(freqresp(zpk(Second.z,Second.p,Second.k),2*pi*Second.f)));
   goalresp = transpose(squeeze(freqresp(new_fit,2*pi*Second.f)));

 
figure(91)
%subplot(211)
 HHH =   loglog(f,abs(Second.Input),...
          f,abs(fitresp),...
          f,abs(newfitresp),...
           f,abs(minfitresp),...
           f,abs(goalresp),...
            f,100*abs(GOAL- First.Input),...
          f,100*abs(GOAL-fitresp),...
          f,100*abs(GOAL-newfitresp),...
           f,100*abs(GOAL-minfitresp),...
             f,100*abs(GOAL - goalresp),...
          'linewidth',3);
      grid on
        legend('Input','Fit','Diddled Fit','Min Fit','Goal Fit',...
                '100*Initial Error',...
                '100*(GOAL-Fit(Ryan))',...
                '100*(GOAL- Diddled Fit)',...
               ['100*(GOAL- Min Fit) ' ,num2str(length(pp)),' poles'],...
               '100*(GOAL- Goal Fit)',...
                4)
           set(HHH(6:10),'linestyle','--')
   xlabel('Frequency(Hz)','fontsize',24,'fontname','Stays In The Cave!','color',[0.5 0.0 0.75]);
   ylabel('Magnitude','fontsize',24,'fontname','Stays In The Cave!','color',[0.5 0.0 0.75]);
     title('IIR Fit to our FIR','fontsize',24,'fontname','SpookyMagic','color',[0 0.4 0.75]);
% subplot(212)
%  semilogx(f,rads*angle(Second.Input),...
%           f,rads*angle(fitresp),...
%           f,rads*angle(newfitresp),...
%            f,rads*angle(minfitresp),...
%             f,rads*angle(goalresp),...
%            f,100*(rads*angle(GOAL)- First.Input),...
%            f,100*(rads*angle(GOAL)- rads*angle(fitresp)),...
%            f,100*(rads*angle(GOAL)-rads*angle(newfitresp)),...
%            f,100*(rads*angle(GOAL)-rads*angle(minfitresp)),...
%           'linewidth',3);
%       grid on
%      
%       set(gca,'YLim',[-190 190],'ytick',-180:30:180);
%  legend('Input','Fit','Diddled Fit','Min Fit','Goal Fit',...
%                 '100*Initial Error','100*(GOAL-Fit)','100*(GOAL- Diddled Fit)',...
%                '100*(GOAL- Min Fit)',4)
      




      
%% impulse response
figure(2)
[y,t] = impulse(zpk(z,p,k));
plot(t,y,'linewidth',2)
grid on
set(gca,'fontsize',20,...
    'fontname','times',...
    'fontweight','bold')
xlabel('time [sec]')
ylabel('amplitude')
title('impulse response')

if printfigs == 1
    orient landscape
    print -dpsc -append firfit.ps 
    system(['ps2pdf firfit.ps firfit.pdf']);
end

 
 %% to be copied into foton
% disp(['SOS coefficients to be put into Foton'])
% quack3andahalf(zpk(z,p,k),fs);

