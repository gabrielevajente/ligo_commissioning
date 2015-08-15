% [y, t] = get_comb_timeseries(fs, fRes, Nrep, fMin, fMax, filter)
% [y, t] = get_comb_timeseries(fs, fRes, Nrep, fMin, fMax)
% [y, t] = get_comb_timeseries(fs, fRes, Nrep, vAmp)
%   returns the time series of a signal with a frequency comb
%
% fs - sample rate of resulting time series
% fRes - frequency resolution (comb interval)
% Nrep - number of signal repetitions
%
% specify minimum and maximum frequency in equal amplitude comb
%   fMin - lowest frequency in the comb
%   fMax - highest frequency in the comb
%
% or give vector of comb amplitudes
%   vAmp - amplitude of each component fRes:fRes:fs / 2
%          vAmp is Nf x 1 where Nf = fs / (2 * fRes) - 1
%          vAmp can be complex, if real random phases are assigned
%
% NOTES:
% fRes is rounded to an integer fraction of fs / 2
%   Nf = round(fs / (2 * fRes));
%   fRes = fs / (2 * Nf);
%
% The resulting time series has Nrep / fRes data points,
% with the signal repeating every 1 / fRes seconds.
%
%   September 29, 2010  RKM
%   Add in an option for making the frequencies amplitudes non-uniform
%   need to include fMin, fMax, filter
%           or      fMin, fMax, amplitude vector
%
%  December 5 2011 RKM
%  Remove fRes from returned values add yMax, which is the scaling value
%  applied to the time series to give a max vaule of 1



function [y, t, yMax] = get_comb_timeseries(fs, fRes, Nrep, varargin)

  % number of frequencies in FFT
  Nf = round(fs / (2 * fRes));
  fRes = fs / (2 * Nf);
  f = (1:Nf)' * fRes;

  % comb amplitudes
  if length(varargin) == 1
    % set amplitudes from argument
    vAmp = varargin{1};
    if length(vAmp) ~= Nf
      error('vAmp must be Nf x 1 (Nf = %d)', Nf);
    end
    
    % phases
    phi = zeros(Nf, 1);
    randPhi = all(isreal(vAmp)); % use random phases if data is real
  else
    % set amplitudes between fMin and fMax to 1
    fMin = varargin{1};
    fMax = varargin{2};
    
    nMin = round(fMin / fRes);
    nMax = round(fMax / fRes);
    
    if nMin < 1
      error('fMin must be greater than fRes')
    end
    if nMax < nMin
      error('fMax must be greater than fMin')
    end
    
    vAmp = zeros(Nf, 1);
    %add in variable amplitude options
    if length(varargin) == 2
        vAmp(nMin:nMax) = 1;
    else
        if strcmpi(class(varargin{3}),'zpk') | ...
                strcmpi(class(varargin{3}),'tf') | ...
                strcmpi(class(varargin{3}),'ss')
            amplitude_filter = varargin{3};
            vAmp(nMin:nMax) = squeeze(abs(freqresp(amplitude_filter,2*pi*f(nMin:nMax))));
        elseif length(varargin{3}) == (nMax-nMin + 1)
             vAmp(nMin:nMax) = abs(varargin{3});
        elseif length(varargin{3}) == Nf
            vAmp = abs(varargin{3});
        else
            error('Bad amplitude specifier');
        end
    end
    % generate phases using the Schroeder algorithm
    kSch = (1:nMax)' - 1;
    phi = zeros(Nf, 1);
    phi(1:nMax) = pi * kSch .* (kSch - 1) / nMax;
    
    % these tricks seem to help
    randPhi = (fMax - fMin) < 10 * fRes && Nf < 1e4;  % few lines, try random phases
    phi = phi * nMax / (nMax - nMin + 1); % spread things out some
  end
  if nMin == nMax %we are asking for a single frequency
      phi = phi*0;
      phi(nMax) = -pi/2;
  end
  % amplitudes and phases for inverse FFT
  x = vAmp(:) .* exp(i * phi);
  x(end) = vAmp(end);       % last component (at fs / 2) must be real
  
  % take inverse FFT, with conjugates to make result real
  y = ifft([0; x(1:end-1); conj(x(end:-1:1))]);

  % look for lower max with random phases?
  yMax = max(abs(y));  
  if randPhi
    for n = 1:5
      phi = 2 * pi * rand(size(phi));
     
      % build another y
      x = vAmp(:) .* exp(i * phi);
      x(end) = vAmp(end);
      y_n = ifft([0; x(1:end-1); conj(x(end:-1:1))]);
      yMax_n = max(abs(y_n));
      
      % if this is better, keep it
      if yMax_n < 0.99*yMax  %to prevent some rounding errors
	yMax = yMax_n;
	y = y_n;
      end
    end
  end
  
  % scale to unit magnitude
  y = y / yMax;

  % make repetitions
  y = repmat(y, Nrep, 1);
  
  % make time axis, if requested
  t = (0:1:(length(y) - 1))' / fs;
