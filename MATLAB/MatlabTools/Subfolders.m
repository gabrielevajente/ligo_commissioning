function [ Subfolders_List ] = Subfolders( Folder_Path)
% This function lists the subfolders in Folder_Path
% It does not return ".", "..", and ".svn"

Folder_Content_Cell                                          = dir(Folder_Path);
id_Subfolder                                                 = [Folder_Content_Cell.isdir];
Subfolders_List                                              = {Folder_Content_Cell(id_Subfolder).name};
Subfolders_List(ismember(Subfolders_List,{'.','..','.svn'})) = []; 

end
