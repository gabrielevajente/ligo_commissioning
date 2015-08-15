% Email_Measurements_Done(Unit_ID,mailing_list,GPS_Time_Start,Done)
% VL - February 17, 2012

function Email_Measurements(Unit_ID,mailing_list,GPS_Time_Start,Done)
if Done==1
    GPS_Time_Finish=gps_now;
    Date_str_Finish=gpsinvert(GPS_Time_Finish);
end

Date_str_Start=gpsinvert(GPS_Time_Start);

mail = 'testing.sei@ligo.mit.edu';
password = 'seismic';

server = 'newligo.mit.edu';
props = java.lang.System.getProperties;
props.setProperty('mail.smtp.port','25');
props.setProperty('mail.smtp.auth','true');
setpref('Internet','E_mail',mail);
setpref('Internet','SMTP_Server',server);
setpref('Internet','SMTP_Username',mail);
setpref('Internet','SMTP_Password',password);


if Done==1
    for Counter_1=1:length(mailing_list)
        sendmail(mailing_list(Counter_1), ['Measurements done on ' Unit_ID ], {'All,';'';['Measurements on ', Unit_ID,':']; ['Started at GPS:', num2str(GPS_Time_Start), ' - ', Date_str_Start ,' and finished at GPS:', num2str(GPS_Time_Finish), ' - ', Date_str_Finish,'--'];'The seismic team'});
    end

else
    for Counter_1=1:length(mailing_list)
        sendmail(mailing_list(Counter_1), ['Measurements starting on ' Unit_ID ], {'All,';'';['Measurements on ', Unit_ID,':']; ['Started at GPS:', num2str(GPS_Time_Start), ' - ', Date_str_Start,'--'];'The seismic team'});
    end  
end

