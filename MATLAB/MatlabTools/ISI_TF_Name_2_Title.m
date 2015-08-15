function [Title, Description, Date]=ISI_TF_Name_2_Title(TF_Name)
% Takes the Name a trunsfer function and makes a formated title out of it.
% HP May 8th 2013

%---------------------------
% Formated Title - No Date
%---------------------------
Undsc_Description=TF_Name(1:end-19)                             ;
Description=regexprep(Undsc_Description,'_',' ')                ;

%---------------------------
% Date formated for Title
%---------------------------
Undsc_Date=TF_Name(end-13:end-4)                                ;
DD          = Undsc_Date(end-1:end)                             ;
MM          = Undsc_Date(end-4:end-3)                           ;
YYYY        = Undsc_Date(1:4)                                   ;
Date_Num    = datenum(str2num(YYYY),str2num(MM),str2num(DD))    ;
[ x Month ] = month(Date_Num)                                   ;
Date        = [  Month ' ' DD ' ' YYYY ]                         ;

%---------------------------
% Formated Title - with date
%---------------------------
Title=[Description ' - ' Date]                                  ;