% Which_Version(which_program,Program_name) tells you which version of the scripts (Generic or not) you
% are currently running
% VL - May 15, 2012

function Version_str=Which_Version(Which_Program,Program_name)
current_path=pwd;
Full_Path = which(Program_name);
Full_Path = Full_Path(1:max(strfind(Full_Path,'/')));
cd(Full_Path)

% [flag Location] = unix('ls -la');
% Version=strfind(Location,'Version');
% 
% if isempty(Version)
    [flag Location] = unix('pwd');
    Location = strcat(Location, '/');
    Version=strfind(Location,'Version');
% end    
Slash=strfind(Location,'/');
Version_str=Location(1,Version:Slash(min(find(Slash>Version(1))))-1);

if strcmp(Which_Program,'M')
    cprintf([0 0.1 0.8],['You are running the main script "', Program_name,'" from the ',Version_str,' folder.']);
elseif strcmp(Which_Program,'G')
    cprintf([0 0.1 0.8],['You are running the generic script "', Program_name, '" from ',Version_str,' folder.']);
elseif strcmp(Which_Program,'P')
    cprintf([0 0.1 0.8],['You are running the plot script "', Program_name,'" from ',Version_str,' folder.']);    
else
    cprintf([0 0.1 0.8],['You are running ', Program_name, ' from the ', Version_str,' folder.']);
end
fprintf('\n');
cd(current_path)
end