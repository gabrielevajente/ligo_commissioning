
%http://www.iris.edu/NRL/sensors/streckeisen/streckeisen_sts2_sensors.htm
%http://www.passcal.nmt.edu/content/instrumentation/sensors/sensor-comparison-chart/poles-and-zeroes#sts2_gen3

%copied pole zero model off of the web of STS2


%generation 3 	09/97 to present 	model # 997xx and later
PP = [ -1.33E+04 	0.00E+00
-1.05E+04 	1.01E+04
-1.05E+04 	-1.01E+04
-5.20E+02 	0.00E+00
-3.75E+02 	0.00E+00
-9.73E+01 	4.01E+02
-9.73E+01 	-4.01E+02
-1.56E+01 	0.00E+00
-3.70E-02 	3.70E-02
-3.70E-02 	-3.70E-02
-2.55E+02 	0.00E+00];
PP = PP(:,1) + i*PP(:,2);


ZZ = [0.00E+00 	0.00E+00
0.00E+00 	0.00E+00
-4.63E+02 	4.31E+02
-4.63E+02 	-4.31E+02
-1.77E+02 	0.00E+00
-1.52E+01 	0.00E+00];
 

ZZ = ZZ(:,1) + i*ZZ(:,2);

STS2_G3 = zpk(ZZ,PP,1);

STS2_G3 = STS2_G3/abs(freqresp(STS2_G3,2*pi*1));


%generation 2 	09/94 to 04/97 model #	99443 to 497xx


PPP = [-6.91E+03 	9.21E+03
-6.91E+03 	-9.21E+03
-6.23E+03 	0.00E+00
-4.94E+03 	4.71E+03
-4.94E+03 	-4.71E+03
-1.39E+03 	0.00E+00
-5.57E+02 	6.01E+01
-5.57E+02 	-6.01E+01
-9.84E+01 	4.43E+02
-9.84E+01 	-4.43E+02
-1.10E+01 	0.00E+00
-3.70E-02 	3.70E-02
-3.70E-02 	-3.70E-02
-2.55E+02 	0.00E+00];

PPP = PPP(:,1) + i*PPP(:,2);

ZZZ =[0.00E+00 	0.00E+00
0.00E+00 	0.00E+00
-5.91E+03 	3.41E+03
-5.91E+03 	-3.41E+03
-6.84E+02 	1.76E+02
-6.84E+02 	-1.76E+02
-5.55E+02 	0.00E+00
-2.95E+02 	0.00E+00
-1.08E+01 	0.00E+00];


ZZZ = ZZZ(:,1) + i*ZZZ(:,2);

STS2_G2 = zpk(ZZZ,PPP,1);

STS2_G2 = STS2_G2/abs(freqresp(STS2_G2,2*pi*1));

%1 	01/90 to 09/94  model # 	19001 to 99442

P = [-3.70E-02 	3.70E-02
-3.70E-02 	-3.70E-02
-1.60E+01 	0.00E+00
-4.17E+02 	0.00E+00
-1.87E+02 	0.00E+00
-1.01E+02 	4.02E+02
-1.01E+02 	-4.02E+02
-7.45E+03 	7.14E+03
-7.45E+03 	-7.14E+03];
P = P(:,1) + i*P(:,2);


Z = [0.00E+00 	0.00E+00
0.00E+00 	0.00E+00
-1.52E+01 	0.00E+00
-3.19E+02 	4.01E+02
-3.19E+02 	-4.01E+02];
Z = Z(:,1) + i*Z(:,2);

STS2_G1 = zpk(Z,P,1);

STS2_G1 = STS2_G1/abs(freqresp(STS2_G1,2*pi*1));

figure(44)

bode(STS2_G1,STS2_G2,STS2_G3,2*pi*logspace(-4,3,4454))
grid on
legend('Generation 1','Generation 2','Generation 3');
Note='The mat file contains the models for the different generation of STS2'

save STS2_Models.mat STS2_G1 STS2_G2 STS2_G3 Note