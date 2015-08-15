function status = quackcheck(discreteZPKfilter)
% QUACKCHECK  see if a discrete time zpk filter will be converted to foton
% status = quackcheck(discreteZPKfilter)
% status is 1 if it is OK, 0 if not OK
% status is optional
% prints helpful messages!
% 
% BTL, JSK, HOS, March 27 2008
%
% $Id: quackcheck.m 125 2008-07-31 15:49:03Z seismic $


[zd,pd,kd] = zpkdata(discreteZPKfilter,'v');
% SOSing the digital zpk

[sos,gs] = zp2sos(zd,pd,kd);
[gain,ca] = sos_shuffle(sos);
if gain == 0
    disp('gain should not equal 0')
    first_check = 0;
else
    disp(' ')
    disp('   gain OK')
    first_check = 1;
end

coe = real([gs ca']);
number_sos = (length(coe)-1)/4;

if number_sos > 10  % too many sections
    disp(' there are too many sections')
    disp([' number is ',num2str(number_sos)])
    second_check = 0;
else
    disp(['There are ',num2str(number_sos),' sections (which is OK)'])
    second_check = 1;
end

if nargout ==1
    status = first_check * second_check;
end

