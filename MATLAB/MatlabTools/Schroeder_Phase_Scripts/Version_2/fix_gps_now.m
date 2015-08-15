function fix_gps_now

path1 = getenv('PATH');
path1 = [path1 ':/ligo/apps/linux-x86_64/ligotools/bin/'];
setenv('PATH', path1);
 

try
    ttt =  gps_now;
   cprintf([0 0 1],['Refreshed Envoirnmental path, hopefully gps_now now works, current gps time is: ',num2str(ttt,11),'\n\n']);
catch
     cprintf([1 0.4 0.3],['!!!!! GPS REFRESH HAS FAILED !!!!'\n\n']);
end
    