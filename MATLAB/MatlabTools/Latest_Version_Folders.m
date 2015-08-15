function [ Latest_Version ] = Latest_Version_Folders( Folders_List )
% Latest_Version finds the latest version within a folder list

% List of Updates
% ---------------
%   - HP 2014/06/09 - initial version

for ii=1:length(Folders_List)
    Current_Folder=char(Folders_List(ii));
    if length(Current_Folder)>=7
        if strcmp(Current_Folder(1:7),'Version')
            if str2num(Current_Folder(9))
            Versions(ii)=str2num(Current_Folder(9));
            end
        end
    end
end
Latest_Version=['Version_' num2str(max(Versions))];
end

