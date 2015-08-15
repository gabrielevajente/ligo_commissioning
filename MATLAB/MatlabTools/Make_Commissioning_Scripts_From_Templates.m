function Make_Commissioning_Scripts_From_Templates(Sub_System, Current_Chamber,Current_IFO, Template_Chamber, Template_IFO, Script_Version)
% Function that copies/renames the control scripts from a template chamber
% into the folder of the current unit

disp(['- Creating the commissioning scripts for ' Current_IFO '-' Current_Chamber ' from ' Template_IFO '-' Template_Chamber ' Scripts version ' num2str(Script_Version)])
%% Copying Templated inot current Unit
Current_Path   = ['/ligo/svncommon/SeiSVN/seismic/' Sub_System '/' Current_IFO  '/' Current_Chamber  '/Scripts/Control_Scripts/Version_' num2str(Script_Version) '/'];
Templates_Path = ['/ligo/svncommon/SeiSVN/seismic/' Sub_System '/' Template_IFO '/' Template_Chamber '/Scripts/Control_Scripts/Version_' num2str(Script_Version) '/'];
cd(Current_Path(1:end-10))
if exist([Current_Path(1:end-10) '/Version_' num2str(Script_Version)],'dir' )
    Warning=sprintf(['Warning: The following folder already exists,\n' Current_Path '\n']);
    disp(Warning);
else
    copyfile(Templates_Path,Current_Path)
    %% Going to current path and adapting filenames and content
    cd(Current_Path)
    Files = dir('*.m');
    disp(['------------------------------------------------------']);
    for Counter_2=1:length(Files)
        %% File Names
        Original_Name   = Files(Counter_2).name ;
        New_Name        = strrep(Original_Name, Template_Chamber , Current_Chamber);
        New_Name        = strrep(New_Name, Template_IFO, Current_IFO);
        if strcmp(New_Name,Original_Name)==0
            movefile(Original_Name, New_Name);
        end
        %% File Content
        New_Name_temp=[New_Name(1:end-2) '.temp'];     % Turn .m into .temp
        disp(['----- Processing : ' New_Name_temp ' ------']);
        movefile(New_Name, New_Name_temp); %Put the content of .m into .temp file
        
        % Read .temp and correct line by line. each line is saved into the .m file that was emptied at the begining of the process
        fid=fopen(New_Name_temp,'r');
        fid_2=fopen(New_Name,'w+');
        fid=fopen(New_Name_temp,'r+');
        while(~feof(fid))
            s=fgetl(fid);
            s=strrep(s,Template_Chamber,Current_Chamber);
            s=strrep(s,Template_IFO    ,Current_IFO);
            fprintf(fid_2,'%s\r\n',s);
        end
        fclose(fid);
        fclose(fid_2);
    end
    
    %% Delete temporary files
    Temp_Files = dir('*.temp');
    for jj=1:length(Temp_Files)
        delete(Temp_Files(jj).name)
    end
    
    cprintf([0.1 0.65 0],['Unit-Specific Control Scripts renamed for ' Current_IFO '-' Current_Chamber]),cprintf('\n\n');
    cprintf([0.1 0.65 0],['- The commissioning scripts for ' Current_IFO '-' Current_Chamber ' were successfully created from ' Template_IFO '-' Template_Chamber ' Scripts version ' num2str(Script_Version)]),cprintf('\n\n');
end
end