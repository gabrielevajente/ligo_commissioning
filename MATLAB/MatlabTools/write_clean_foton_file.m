function write_clean_foton_file(filename)
%function write_clean_foton_file(filename)
% removes all the DESIGN strings from a foton file
% helps get rid of conflicts with foton
%
% BTL Jan 29, 2014

if ~exist(filename,'file')
    disp(['can not find file ',filename]);
    disp('Did you specify the full path?');
    error('no foton file found')
else
    copyfile(filename,[filename,'.bak']);
    disp('backing up file');
end


% These are the three patterns that we look for in the chans file
%header_pat      = ['### ',filt_name];
%module_pat      = ['MODULES.*',filt_name]; 
design_pat_end = '###                                                                          ###';
design_pat     = '# DESIGN';  %first 8 chars of a DESIGN thing
% BTL added module pat, as regular expression - is the filter in the model?



fid = fopen(filename,'r');

if fid == -1
    error(['Could not open specified file ',filename])
end


% Read in the whole text.  This is a hack.  If you know a better way,
% please email tarm@stanford.edu
%
% BTL July 19 2008, set the whitespace so that space is NOT a whitespace
%   this is because the foton file starts the lines of the SOS with
%   whitespace, so that it is more readable to humans. We will try to
%   preserve that feature.
complete_lines = textscan(fid,'%s','Delimiter','\n','Whitespace','');
complete_lines = complete_lines{1};

fclose(fid);


fid = fopen(filename,'w');

% loop through all of the lines and copy the old lines into the new file

% This code will rewrite the file without the DESIGN strings

% Code plan:
% for each line in the original file:
% 1) get the line,
% 2) decide if we should write the line back into the file
% 3) write the line if we should
%  
% BTL update, Jan 2014


in_design_segment    = false;
design_segents_found = 0;

for this_line_number = 1:length(complete_lines)

    % 1) get the line,
    this_line = complete_lines{this_line_number};
    
    % 2) decide if we should write the line back into the file
    % check the line to see if we are in a DESIGN segment
    if (in_design_segment == false)
        % watch for the beginning of a Design segment
        if (strncmpi(this_line, design_pat, 8))
            % we have started into a DESIGN segment
            design_segents_found = design_segents_found + 1;
            in_design_segment    = true;
            write_this_line      = false;
        else
            % we have NOT started one yet...
            in_design_segment = false;
            write_this_line   = true;
        end
    else
        % watch for the end of the design segment
        if (strncmpi(this_line, design_pat_end, 6))
            % we have reached the end
            in_design_segment = false;
            write_this_line   = true;
        else
            % still in there...
            % we have NOT started one yet...
            in_design_segment = true;
            write_this_line   = false;
        end
    end
    
    
    % 3) write the line if we should
    if write_this_line == true
        fprintf(fid,'%s\n',this_line);
    end
    
end

fclose(fid);
disp('success')
disp(['Removed DESIGN data for ',num2str(design_segents_found),' filter banks'])


%{
if found_header == 0
    disp(' ')
    disp('  There is a problem!')
    disp(['The module ',filt_name,' is defined, but'])
    disp('There is is not an empty slot for it in the foton file.')
    disp(['You should open the file ',filename])
    disp('with foton, make a trivial change, and save it again.')
    disp(' ')

    error(['No slot for filter ',filt_name,'. Use foton to resave ',filename])
end

%}

