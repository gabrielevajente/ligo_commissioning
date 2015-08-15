% this function compute :
% {H1;H2;H3}      =  [Sensor_matrix] * {X;Y;Z;RX;RY;RZ}
% or 
% {V1;V2;V3}      =  [Sensor_matrix] * {X;Y;Z;RX;RY;RZ}


function Sensor_matrix=Sensor(Posi_sens_1,Direc_sens_1,rotation)

if nargin <3
   corner_angle=[0 120 240];  % corner_angle are the three angular positions of sensors
                             % from the axis of the first corner
else
    corner_angle = rotation;
end
%calcualte geoMatCToS : Displacements at origin to Displacements in Sensors
  
for n=1:length(corner_angle)            % computation in each corner 
    rMat=rotMat(corner_angle(n));         % rMat is the  matrix of rotation from 
                                          % the corner 1 to the corner n.
                                 
    Direc_sens=Direc_sens_1*rMat';   % Direc_sens is the sensor direction in the corner n.                                                               
    Posi_sens=rMat*Posi_sens_1;      % Posi_sens is the sensor position in the corner n.                                                                     
    Displacement=crossTens(rMat*Posi_sens_1);  % Displacement is the displacement in the corner n 
                                               % due to a angular rotation : 
                                               % crossTens (Rx;Ry;Rz)
    Global_disp=[eye(3) -Displacement]; 
    % Global Displacement is the vector of displacement in the corner n 
    % (due to translation and rotation) : 
    % {Xn;Yn;Zn}  = Global_disp * {X;Y;Z;RX;RY;RZ}                      
    Sensor_value=[Direc_sens]*Global_disp; 
    % Sensor_value: the displacement in corner n : {Xn;Yn;Zn}
    % is projected on the sensor direction [Direc_sens]    
    Sensor_matrix(n,:)=Sensor_value;
    % Sensor_value is successively H1,H2,H3 then V1,V2,V3
end 
return