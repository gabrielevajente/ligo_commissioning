% Save_All_Plots(Save_Folder)
% Save_Folder - Optional:
%   Folder in which to save the .pdf file.
%   e.g.   '/ligo/svncommon/SeiSVN/seismic/HAM-ISI/H1/HAM2/Data/'
%   Note: The last '/' caracter is very important. The pdf will only have 1
%   page if this carater is missing. if using pwd, Safe_Folder should be
%   set to: [pwd '/']
%
% Saves all opended figures
% ... In Currrent folder
% ... as dated .ps and convert to .pdf
%
% Note: the conversion from ps to pdf is made by a program called "ps2pdf"
% wich comes from the matlab website.
%
%List of modifications:
% HP - October 26th 2012
% HP - May 8th 2012 - Made it a function, and added the scaling factors.
% HP - Oct 08 2013 - added comment to remind not to forget to use '/' as
% as the last character for Save_Folder, which pwd does not.
% HP - Nov 15th 2013 - Removed "Format" input parameter and mase
% "Save_Folder" Optional.

function Save_All_Plots(Save_Folder)

if exist('Save_Folder')==0
    Save_Folder=[pwd '/'];
end

Handles           = sort(findobj('Type','figure'));
Number_of_Figures = length(Handles);
Name              = input('Filename: ');
Date              = datestr(now,'_yyyy_mm_dd');

% set(Handles(1),'PaperPositionMode','Auto')
Format='a2';
Scaling=2;
xSize=29.0*Scaling;
ySize=20*Scaling;

Print=['print(Handles(1),''-dpsc2'',''-r300'',''-painters'',''' Name Date '.ps'')'];
eval(Print)
disp(['There are ' num2str(Number_of_Figures) ' figures opened']);

for aa=1:3
    set(Handles(1),'PaperUnits','centimeters')
    set(Handles(1),'PaperSize', [xSize ySize])
    set(Handles(1),'PaperPosition',[0 0 xSize ySize]/2)
    set(Handles(1),'PaperOrientation','portrait')
    orient(Handles(1),'landscape');
    
    
    
    for ll=1:Number_of_Figures
        %      set(Handles(ll),'PaperPositionMode','Auto')
        set(Handles(ll),'PaperUnits','centimeters')
        set(Handles(ll),'PaperSize', [xSize ySize])
        set(Handles(ll),'PaperPosition',[0 0 xSize ySize]/2)
        set(Handles(ll),'PaperOrientation','portrait')
        orient(Handles(ll),'landscape');
        
        Print=['print(Handles(' num2str(ll) '),''-append'',''-dpsc2'',''-r300'',''-painters'',''' Save_Folder Name Date '.ps'')'];
        eval(Print)
    end
    
    aa=aa+1;

ps2pdf('psfile', [Name Date '.ps'], 'pdffile', [Save_Folder Name Date '.pdf'], 'gspapersize', Format)
delete([Name Date '.ps']);
end

disp('pdf rendering is complete')

end