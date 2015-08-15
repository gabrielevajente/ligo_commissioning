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
%
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

printfigs = 0;

fs = 2048;

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
z = complementary;

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
opts.spy2 = 2;       % Create magnitude plot for fitting of f(s) 
opts.logx = 1;       % Use logarithmic abscissa axis
opts.logy = 1;       % Use logarithmic ordinate axis 
opts.errplot = 1;    % Include deviation in magnitude plot
opts.phaseplot = 1;  % Also produce plot of phase angle (in addition to magnitiude)
opts.legend =1;      % Do include legends in plots
opts.fignum = 7;

errss = [];
disp('vector fitting...')
[SER,poles,rmserr,fit] = vectfit4(z,1i*2*pi*f,poles,weight,opts); 
errss = [errss rmserr];

for kk = 1:5
    [SER,poles,rmserr,fit] = vectfit4(z,1i*2*pi*f,poles,weight,opts);
    errss = [errss rmserr];
    pause(0.06)
end

disp('Done.')

A = full(SER.A);
B = SER.B;
C = SER.C;
D = SER.D;
E = SER.E;

%% get zeros and poles
[z,p,k] = zpkdata(ss(A,B,C,D),'v');
z = round(z*1e6)/1e6;  p = round(p*1e6)/1e6;

if printfigs ==1
    orient landscape
    print -dpsc firfit.ps
end
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
disp(['SOS coefficients to be put into Foton'])
[soscoef] = quack3andahalf(zpk(z,p,k),fs);
