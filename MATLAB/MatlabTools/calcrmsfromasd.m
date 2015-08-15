function rms = calcrmsfromasd(freq,amplitude)

freq = freq(:);
amplitude = amplitude(:);
binWidth = [freq(2) - freq(1); freq(2:end) - freq(1:end-1)];
binWidth = binWidth(:);
power = amplitude.^2;

rms = flipud(sqrt(cumsum(flipud(power.*binWidth))));