% Pressure_Sensor_List=Vaccuum_Sensors_LHO(Chamber)
% This function returns the Pressure sensor name at the chamber
% VL - May 21, 2012
function Pressure_Sensor_Name=Vaccuum_Sensors_LHO(Chamber)
switch Chamber
    case {'BSC8','ITMY'}
        Pressure_Sensor_Name='HVE-LY:Y2_180BTORR';
    case {'BSC6','ETMY'}
        Pressure_Sensor_Name='HVE-EY:Y3_410BTORR';
end