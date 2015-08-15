% load with retry
%   this is useful for files that are being updated by another process

function data = loadWithRetry(filename)

  % try a few times to load the file
  nTry = 0;
  isOk = false;
  while nTry < 3 && ~isOk
    nTry = nTry + 1;
    try
      data = load(filename);
      isOk = true;
    catch
      % load failed, wait and try again
      isOk = false;
      fprintf(['Having trouble loading %s.\n', ...
        '%d tries failed.  Retrying...\n'], filename, nTry);
      pause(2)
    end
  end
  
  % try one last time, and produce error on failure
  if ~isOk
    data = load(filename);
  end
  
  % if no output argument, put data in caller space
  if nargout == 0
    fn = fieldnames(data);
    for n = 1:numel(fn)
      assignin('caller', fn{n}, data.(fn{n}))
    end
  end
  
end
