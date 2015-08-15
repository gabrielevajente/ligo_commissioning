function write_filter_coe(filename, filter_string)
%function write_filter_coe(filename, filter_name, filter_string)
% Modifies the chans list in filename so that the filter corresponding to
% filter_name is replaced by filter_string
%
% filename should be a string containing the name of the foton filter file 
% to be modified
%
% filter_string should be a string (made by quack for example) that has all
% of the appropriate labels and coeffients in it.
%
% see also get_filt_names, get_chans_filename, get_sample_freq, autoquack
%
% LAL Aug 2007
%
% updated by BTL on July 16 2008
% to fix the "delete the last line" error
%
% updated BTL july 19 2008 to preserve whitespace, fix break-on-last-line error
%
% updated BTL april 28 2011 to read new foton format
% and updated again at line 113 to read the whole line of an existing
% filter, and ignore the end, rather than just read the beginning.
% 
% BTL update on Aug 16, 2012
% 1) removed bad code to insert fresh header - Adding new header is not
%    trivial, because they are supposed to be in order.
% 2) Instead, just print an error if the header is not present
% 3) Also watch to be sure the filter is in the MODULE section.
%    If not there, then the filter is probably misspelled, because 
%    the MODULES are inserted automatically by the make process.

test_mode = false;

% make sure the input string ends with a newline - BTL, May 2, 2011
%  
% NOTE - all the other lines need to have the newline appended in the sprintf
%  BUT NOT the FILTER_STRING
% the filter string is assumes to have the newline already attached.
% crazy

last_char = filter_string(end);
if ~strcmp(last_char, sprintf('\n'))
    filter_string = [filter_string,sprintf('\n')];  % append a newline if needed
    if test_mode == true
        disp('adding new line to the filter string')
        disp(filter_string)
    end
end

% some of the filters START with a newline - 
% which is crazy, and is breaking stuff.
% look for this, and if true, remove it...
% BTL June 14, 2011

first_char = filter_string(1);
if strcmp(first_char, sprintf('\n'))
    filter_string = filter_string(2:end);  % delete leading newline if needed
    if test_mode == true
        disp('removing newline from beginning of the filter string')
        disp(filter_string)
    end
end

% BTL fixed this line to read the whole input string, and ignore the end.
% the %*[^\n] goes to the end.
% 
% DEC discovered that this file breaks when the filter_string is two
% lines...
% ITMX_ST1_DAMP_RX 0 21 2 0 0  Damp_S1         0.000544498013   -1.78108374714041    0.78115080540956    0.00000000000000   -1.00000000000000
%                                                -1.99913224950778    0.99913262583999   -1.99566125731809    0.99567064930945
% such as the above...
% try to discover why and modify it...
% Perhaps try changing the  %*[^\n] to  %*[^\r] which is carriage return
% instead of new line...in the debugging window this seems to work...give
% it a try because I'm tired and want to go home...
%
% June 14, 2011 - BTL:
% it seems that the trick is to go ALL THE WAY TO THE END 
% \n doesn't work, becase sometimes there is a \n before the end (there is
% one after every line)
% there are not any \r in the string, so strread keeps reading up to the end.
% you could use a z, also, because it's all numbers.
% there should be a way to tell strread to just go to the end, but I don't
% know what it is.

[filt_name filt_subblock filt_nlines filt_label] = strread(filter_string,...
    '%s %d %*d %d %*d %*d %s %*[^\r]');
filt_name = filt_name{1};
filt_label = filt_label{1};

if test_mode == true
    disp(['filter name is: ',filt_name])
    disp(['subblock num is: ',num2str(filt_subblock)])
    disp(['number of lines (second order sections) is: ',num2str(filt_nlines)])
    disp(['filter label is: ',filt_label])
end

% These are the three patterns that we look for in the chans file
header_pat      = ['### ',filt_name];
comment_end_pat = ['###                                                                          ###'];
module_pat      = ['MODULES.*',filt_name]; 
% BTL added module pat, as regular expression - is the filter in the model?

% the recycle thing is an easy way to do some backups
r = recycle;
recycle on
% copyfile(filename,[filename,'.bak']);

% put the original file into the .bak, 
% then delete and rebuild the original.

backup_file =  [filename, '.bak'];
[status,result] = unix(['cp ' filename ' ' backup_file]);


fid = fopen(backup_file,'r');

if fid == -1
    error(['Could not open specified file ',filename])
end

% move the delete, only delete original if we can open the backup.
% BTL Aug 16, 2012

delete(filename);
recycle(r)

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
[status,result] = unix(['rm ' backup_file]);


fid = fopen(filename,'w');

% loop through all of the lines and copy the old lines into the new file
% this used to be  j < length(complete_lines), BTL July 16, 2008.

% This code will insert or replace exactly 1 filter subblock.

% Code plan:
% scan though the foton file until you get to the filter module:
%  at the module, 
%  1) rewrite the header info - mark header as 'found'
%  2) scan through the module until you get to place to 
%     insert or replace the existing subblock
%  3) replace or insert the subblock
%  4) write out the rest of the file
%
%  
% BTL update, AUg 2012
% if you get to the end, and have not found the header,
%   send a message to the user.

found_module = 0;  % look for the fiter name in the list of modules 
% at the top of the foton file, if not here, fitler is not in the simulink 
% diagram

found_header = 0; % put this OUTSIDE the loop...
% look for filter slot in the file, if not here, need to open with foton

j = 1;
while j <= length(complete_lines)
    
    % print and increment
    %disp(complete_lines{i})
    fprintf(fid,'%s\n',complete_lines{j});
    % watch for the module to be defined - BTL, Aug 16, 2012
    if ~isempty(regexp(complete_lines{j}, module_pat, 'match'))
        found_module = 1;
    end
    
    j = j + 1;
    if j > length(complete_lines)   
        break  % if we just wrote the last line, stop before we generate an error.
    end
    
    
    % if we get to the header pattern...
    if (strncmp(header_pat,complete_lines{j},length(header_pat)))
        found_header = 1;  
        % print the header
        %disp(complete_lines{i})
        if test_mode == true
            disp(['found filter module at line ',num2str(j)])
        end

        fprintf(fid,'%s\n',complete_lines{j});    % fprint the header
        if test_mode == true; disp([num2str(j),': ',complete_lines{j}]); end
        j = j + 1;
        
        % and print the lines of comments that follow it, which are NOT the
        % end of the comment

        while ~strcmp(comment_end_pat,complete_lines{j})
            fprintf(fid,'%s\n',complete_lines{j});
            if test_mode == true; disp([num2str(j),': ',complete_lines{j}]); end
            j = j + 1;
        end
        % and print the end of the comment
        fprintf(fid,'%s\n',complete_lines{j});    % added a newline here...
        if test_mode == true; disp([num2str(j),': ',complete_lines{j}]); end

        j = j + 1;
       
        % finished replacing the header
        % now we start looking for the place to insert the subblock
        
        while 1
            try
            filter_line = complete_lines{j};
            catch
                print('doh')
            end
            % if there is no filter here, put ours
            if isempty(filter_line) %

                %disp('---------inserting new filter------')
                %disp(filter_string)
                fprintf(fid, '%s',filter_string);
                break
            end

            % NAME subblock 21 nlines 0 0 LABEL
            % now parse the next line that has the filter and filter info
            % the %*[^\n] at the end just reads to the end of the line, BTL
            % April 29, 2011
            [cur_name cur_subblock cur_nlines cur_label] = strread(filter_line,...
                '%s %d %*d %d %*d %*d %s %*[^\n]');
            try
            cur_name = cur_name{1};
            cur_label = cur_label{1};
            catch
                print('duh')
            end

            % if there is a filter in the subblock we want, insert our new
            % filter, skip over the old lines in the old file, and continue
            if cur_subblock == filt_subblock

                % if we're trying to replace an automatically generated
                % subblock, raise an error
                if strcmp(cur_name, cur_label(1:end-2)) && ~strcmp(cur_label, filt_label)
                    if (cur_label(end)-cur_subblock == 97)
                        disp('********')
                        disp(['Warning on ',filt_name,'_filter_',num2str(filt_subblock),...
                            filt_label,': Should not be replacing automatically created subblock ',...
                            cur_label]);
                        disp('********')
                    end
                end
                %disp(' -------> matching subblock. replace <-----')
                %disp(filter_string)
                fprintf(fid,'%s',filter_string);
                %disp(' -------> end replace <-------')

                % now fast forward over the filter that is currently in place
                j = j + cur_nlines;
                %disp(['------- fastforward ',num2str(cur_nlines),' lines------'])
                break;    % break out of match, now go back and replace the rest of the file.

                % if the filter we're looking at goes into a subblock before ours,
                % copy it into the new file and keep going
            elseif cur_subblock < filt_subblock

                %disp('----- skip this filter ----')
                %     cheap workaround...
                %     fprintf(fid, '\n');  % this inserts a blank line, removed by BTL on May 2, 2011
                % this is correct, BTL...
                for n = 1:cur_nlines - 1
                    %disp(complete_lines{i})
                    fprintf(fid, '%s\n',complete_lines{j});
                    j = j + 1;
                end
                %disp(complete_lines{i})
                fprintf(fid, '%s\n',complete_lines{j});  % added the \n here, BTL May 2, 2011
                j = j + 1;
                %disp('----end skip----')

                % else our subblock is bigger than the one here  so we need to copy
                % our new string in before copying the rest of the old file
            elseif cur_subblock > filt_subblock
                %disp('---------inserting filter------')
                %disp(filter_string)
                fprintf(fid, '%s',filter_string);
                %disp('----end insert ----')
                break

            else
                disp('oops.........');
                disp(complete_lines{j});
                whos
                break
            end
        
        end
    end
		%disp([num2str(j) ' of ' num2str(length(complete_lines))])
end

%fprintf(fid, '%s',complete_lines{j});
fclose(fid);

if found_module == 0
    disp(' ')
    disp('  There is a problem!')
    disp(['The module ',filt_name,' does not seem to be defined for your system.'])
    disp('There is probably a typo.')
    disp(' ')
    error(['Filter ',filt_name,' not in simulink diagram for ',filename])
end

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

