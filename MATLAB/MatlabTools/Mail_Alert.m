function []=Mail_Alert( Send , Measurement_Type , Duration , IFO , Chamber , Subsystem,  Tester , State )
% Function emails recipients with TF measurement information
% ... When the measurement starts and when it finished
% HP - 08/23/2012 - initial version
% HP - 06/12/2013 - addition of the "Subsystem" input argument, details
% below.

% # Input Parameters #
%    -Send             = Boolean that states wether to send the email alert or not 
%        -1:Send
%        -0:Do not send
%    -Measurement_Type = string e.g. 'TF L2L' 'TF C2C' 'LZMP'
%    -Duration         = double for the estimated duration of the measurement in
%     hours.
%    -Chamber          = string e.g. 'HAM3'
%    -Subsystem        = string e.g. 'HAM_ISI', or 'HAM_HEPI'
%    -IFO              = string e.g. 'L1'
%    -Tester           = string, person who runs the test. Good to add phone numbner
%    -State            = boolean, state of the measurement
%        -1:running
%        -0:Finished


% # Example #
% Mail_Alert( 1 , 'TF L2L' , 3.5 , 'H1', 'HAM1'  , 'John Doe (623-444-1234)' , 1 )
% ...sends the following email:
%   sender: HAM1-ISI
%   title: Measurment Running
%       IFO:                                    H1
%       Type of measurment:                     TF L2L
%       Estimated duration:                     3.5h
%       Measurment performed by:                John Doe (623-444-1234)
 

if Send==true
    %% Mailing Options
    List_Name = [ 'Mailing_List_' IFO '_' regexprep(Subsystem,'-','_') '_Testing.m'];
    Load_List = [ 'List = ''' List_Name ''';'];
    eval (Load_List);
    Sent_From    = [Chamber '-ISI'];

    setpref('Internet','E_mail',Sent_From)
    setpref('Internet','SMTP_Server','bepex.ligo-wa.caltech.edu');

    %% Mail Subject & Content
    if State==1
        Subject = 'Measurement Running';
        Content     = [ ['IFO:                                      ',IFO], 10 ,...
                        ['Type Of Measurement:                      ',Measurement_Type], 10 ,...
                        ['Estimated duration:                       ',num2str(Duration), 'h'], 10 ,...
                        ['Measurent performed by:                   ',Tester ] ];
    Message = '"Measurement Start" Alert Sent to: ';

    elseif State==0
        Subject = 'Measurement Finshed';
        Content     = [ ['IFO:                                      ',IFO], 10 ,...
                        ['Type Of Measurement:                      ',Measurement_Type], 10 ,...
                        ['Measurent performed by:                   ',Tester ] ];
    Message = '"Measurement Stop" Alert Sent to:';
    end  


    %% Sending to Mailing List            
    for Recipient=1:length(List)
        sendmail(List(Recipient),Subject,Content)
    end
disp('**************************************** ');
disp(Message);
disp(List);
disp('**************************************** ');
end