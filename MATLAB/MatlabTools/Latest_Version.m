function [ Latest_Version_Number ] = Latest_Version( Scanned_Folder )
% Latest_Version check the folders in a given path and returns what the
% latest Vesion availabe is as a Character.
% This function is used to make sure that we always load the correct SEI paths on Matlab.
% HP - Nov 05 2013

Sub=Subfolders(Scanned_Folder);

k=1;
for ii=1:length(Sub)
    Folder_Name=Sub{ii};
    if strcmp(Folder_Name(1:end-2),'Version')
        if str2num(Folder_Name(end))
            Versions(k)=str2num(Folder_Name(end));
            k=k+1;
        end
    end
end

if exist('Versions')
    Latest_Version_Number = num2str(max(Versions));
else
    Latest_Version_Number = '- No Version Folder Found';
end

