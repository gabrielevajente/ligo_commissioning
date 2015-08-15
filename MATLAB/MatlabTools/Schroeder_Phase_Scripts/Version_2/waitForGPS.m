% waitForGPS(tGPS, isVerbose)
%   pause until the specified GPS time
%   isVerbose = true (the default) will result in a message indicating
%     the duration of the pause (if the duration is > 2)

function waitForGPS(tGPS, isVerbose)

  if nargin < 2
    isVerbose = true;
  end

  % get new gps time
  tNow = gps_now; %changing from gps_now to just gps for use in linux
  
  % this should only take one loop...
  while tNow < tGPS
    if isVerbose && tGPS - tNow > 2
      disp(sprintf('%.1f: Pausing %.1f seconds until %.1f', ...
        tNow, tGPS - tNow, tGPS));
    end
    pause(tGPS - tNow)

    % get new gps time
    tNow = gps_now;
  end
