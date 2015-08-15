function [ F Data] = Extract_Data_ASCII( ASCII_File, Header_Lines , Is_Complex)
%  Loads Data from ASCII File
%  HP - 09/20/2012

%% Loading
fid           = fopen(ASCII_File) ;
Nb_Points_c   = textscan(fid, '%s','delimiter','/n');
Nb_Points     = length(Nb_Points_c{:});
fclose(fid);

fid           = fopen(ASCII_File) ;
% Preallocation of variables
tmp_Freq      = cell(Nb_Points,1);
tmp_Data_Re    = cell(Nb_Points,1);
tmp_Data_Im    = cell(Nb_Points,1);

% Data retreival
for Freq_Count = 1:Nb_Points
    if Freq_Count==1
        tmp_Freq(Freq_Count)    = textscan(fid, '%f', 1, 'headerLines', Header_Lines);
        tmp_Data_Re(Freq_Count)  = textscan(fid, '%f', 1);
        if Is_Complex
            tmp_Data_Im(Freq_Count)  = textscan(fid, '%f', 1);
        end
    else
        tmp_Freq(Freq_Count)    = textscan(fid, '%f', 1, 'headerLines', 1);
        tmp_Data_Re(Freq_Count)  = textscan(fid, '%f', 1);
        if Is_Complex
            tmp_Data_Im(Freq_Count)  = textscan(fid, '%f', 1);
        end
    end
    
    F(Freq_Count)  = tmp_Freq{Freq_Count};
    Data_Re(Freq_Count)= tmp_Data_Re{Freq_Count}./sqrt(2);
    Data=Data_Re;
    if Is_Complex
    Data_Im(Freq_Count)= tmp_Data_Im{Freq_Count}./sqrt(2);
    Data=Data_Re+i*Data_Im;
    end
end

fclose(fid);
end

