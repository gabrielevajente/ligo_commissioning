% Vaccuum_Pressure_Value =  Vaccuum_Pressure(Chamber)
% This function returns the  pressure measured at the Chamber
% VL - May 21, 2012
function Vaccuum_Pressure_Value =  Vaccuum_Pressure(Chamber)
Pressure_Sensor_Name=Vaccuum_Sensors_LHO(Chamber);
Z1 = '';
clear temp
for Counter_1=1:50
    while isempty(str2num(Z1))
        [flag Z1] = system(['ezcaread -n ', Pressure_Sensor_Name]);
    end
    temp(Counter_1)=str2num(Z1);
    Z1 = '';
end
Vaccuum_Pressure_Value = mean(temp);
disp(['The pressure at ',Chamber,' is ',num2str(Vaccuum_Pressure_Value), ' torr.'])