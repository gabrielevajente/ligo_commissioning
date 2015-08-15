% This function computes and saves the acquisition parameters in one structure
% VL - June 14, 2011

function Parameters = Acquisition_Parameters_Powerspectra(F_resolution,Overlap_per_cent,F_s,GPS_TIME,Average)

nb_points_FFT=round(F_s/F_resolution);
nb_points_Window=(nb_points_FFT);
Window_time=nb_points_Window./F_s;
nb_points_Overlap=Overlap_per_cent.*nb_points_Window/100;
Measurement_length=(Average.*nb_points_Window-(Average-1).*nb_points_Overlap)./F_s;

Parameters.F_s=F_s;
Parameters.F_resolution=F_resolution;
Parameters.Overlap_per_cent=Overlap_per_cent;
Parameters.Average=Average;
Parameters.F_resolution=F_resolution;
Parameters.nb_points_FFT=nb_points_FFT;
Parameters.nb_points_Window=nb_points_Window;
Parameters.Window_time=Window_time;
Parameters.nb_points_Overlap=nb_points_Overlap;
Parameters.Measurement_length=Measurement_length;
Parameters.GPS_TIME=GPS_TIME;
Temp=[];
for Counter_1=1:length(GPS_TIME)
    Temp=[Temp; gpsinvert(GPS_TIME(Counter_1))];
end
Parameters.Time=Temp;