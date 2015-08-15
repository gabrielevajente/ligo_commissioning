%
% tGPS = gps_now
%   returns current GPS time with sub-second precision
%   see also gps, where floor(gps_now) == gps

function tGPS = gps_now

  % should get this from CONFIG
  %cmd = '/opt/apps/Linux/mDV/time_util/gps_now';
cmd = 'tconvert now';
  % run gps_now binary
  [rv, rslt] = system(cmd);

  % check the return value for errors
  if rv ~= 0
    error(['gps_now failed: command was\n%s\n' ...
           'response was\n%s'], cmd, rslt);
  end

  % parse return string
  tGPS = str2double(rslt);
  
  % make sure value is reasonable
  if tGPS < 1e8 || tGPS > 1e10
    error(['gps_now gave an unreasonable result: command was\n%s\n' ...
           'response was\n%s'], cmd, rslt);
  end
