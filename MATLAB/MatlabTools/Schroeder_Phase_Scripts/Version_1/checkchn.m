function [err_msg, contr] = checkchn(chan)
warning off
path('/ligo/svncommon/SeiSVN/seismic/Common/MatlabTools', path);
path('/data/bnewbold/src/SeismicSVN/seismic/Common/MatlabTools', path);
warning on

%%%%CODE FOR ERRORS%%%%
%01  -  Channel not found or permission denied to the file
%02  -  Channel not active (not enabled and/or commented out)
%03  -  Channel is enabled and should be working
%04  -  File path not in the program
%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%Quest for the File%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%
if  iscell(chan)
    chandis = chan{1};
else
    chandis=sprintf(chan); %Forces input to be a string, safeguard
end
chan_mod=regexprep(chandis, '[^\w]', ''); %Take out all the weird characters
err_msg='';
site_str=chan_mod(1:2); %Take the first two letters. This will either be M1, H1, H2, X1, X2, L1
sys_str=chan_mod(3:5); %Example: SEI, BCS, SUS


fname=strcat(site_str,sys_str, '.ini');

switch site_str
    case 'M1'
        switch sys_str
            case {'SEI', 'PDE'} %For aneirein (however that is spelled)
                fpath=strcat('/cvs/cds/mit/chans/daq/', fname);
            case {'BCS', 'HPI', 'IOP', 'ISI', 'SUS'} %For athens
                fpath=strcat('/opt/rtcds/mit/', lower(site_str), '/chans/daq/', fname);  %=================
            otherwise
                contr=04;
                err_msg='The file directory for this channel has not been accounted for.';
                return
        end
    case {'L1', 'X2'} %For llo
        fpath=strcat('/opt/llo/',site_str,'/chans/', fname);
    case {'H1', 'H2', 'X1'} %For lho
        fpath=strcat('/opt/lho/', site_str,'/chans/', fname);
    otherwise
        contr=04;
        err_msg='The file directory for this channel has not been accounted for.';
        return
end
        
 

%Opens the channel specified
fid=fopen(fpath); 

%Checks to see if a file was succesfully opened
if fid==-1
    err_msg='File not found or permission denied';
    contr=01;
    return
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%Quest to Find the Channel%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Move the pointer past the intial paragraph of the file (assuming all files
%have the same set-up)
n=0;
while n<10
    kword=fgetl(fid);
    n=n+1;
end

%Search for the channel specified while temporarily storing a line of
%data for each channel
kword_mod=regexprep(kword, '[^\w]', '');
sameword=strcmp(chan_mod, kword_mod); 
while sameword == 0 %While we haven't found the channel we're looking for, keep looking
    if ~feof(fid)  %Only look if we haven't reached the end of the file yet
        kword=fgetl(fid);
        kword_mod=regexprep(kword, '[^\w]', '');
        sameword=strcmp(chan_mod, kword_mod);
    else  %Stop looking once we've reached the end of the file
        err_msg='The end of the file has been reached. This channel has not been found.';
        contr=01;
        sameword=1; %Change this to =1 so that we don't have an infinite loop.
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%Quest to See if Active%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Now with the channel found, check to see if it is commented out or not 
if kword_mod(1)==chan_mod(1) %Only do this if we have found the right channel
    if kword(1)=='#' %If the channel is commented out...
        err_msg='This channel exists but is not active. (Commented out)';
        contr=02;
    elseif kword(1)=='[' %If the channel is NOT commented out...
        err_msg='This channel should be active. (NOT commented out)';
        contr=03;
    end
else
    return
end

%Check to see if acquire is 1.
acq='acquire'; %Setting up our search term
acqsearch=0;

%If we haven't reached the end of the file yet
if ~feof(fid)
    while acqsearch == 0 
        kword=fgetl(fid);
        kword_mod=regexprep(kword, '[^\w]\d+', ''); %Takes only the string characters and the # sign (if there is one)
        if kword_mod(1)=='#' %Gets rid of # sign so that MATLAB can compare
            kword_mod=strrep(kword_mod, '#', '');
        end
        acqsearch=strcmp(acq, kword_mod);
    end
else %If we have reached the end of the file, returns the error message above
    return
end

%Gets the data (1 or 0) from the acquire string
stracq_num=regexprep(kword, '\D', '');
acq_num=str2num(stracq_num); %Convert from string to number

%Here, we use [] to concatenate the strings so that the user can know why
%the channel is not active (acquire=1 and/or commented out)
if acq_num==1 %Return the value of acquire
    err_msg=[err_msg, char(10), 'Acquire: 1.'];
    if contr==03
        return
    else
        contr=02;
    end
else
    err_msg=[err_msg, char(10), 'Acquire: 0.'];
    contr=02;
end

%%%%Quest Completed%%%%
%Closes the current file
fclose(fid);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%