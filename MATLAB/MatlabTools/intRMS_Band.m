function [RMS_Band_Total, RMS_Band, Freq_Band] = intRMS_Band(ASD_Data, Freq, FreqStart, FreqStop)
%function [RMS_Band_Total, RMS_Band, Freq_Band] = intRMS_Band(RMSSD_Data, Freq, FreqStart - Hz, FreqStop - Hz)
% intRMS takes a data vector that is in the form of an ASD (Root Mean
% Square Spectral Density) and does a right to left integration of the RMS
% values between the frequencies specified in FreqStart and FreqStop in Hz.
%
% DEC 2011.11.15 (with BTL help)
%

% Check that the frequency start and stop points match
if FreqStart > FreqStop
    ind_1 = FreqStop;
    ind_2 = FreqStart;
else
    ind_1 = FreqStart;
    ind_2 = FreqStop;
end

% Now create the vector subset to keep
    i_1   = find(Freq >= ind_1); 
    i_2   = find(Freq <= ind_2);
Freq_Band = Freq(i_1(1):i_2(end));
Data_Band = ASD_Data(i_1(1):i_2(end));

if length(Freq) ~= length(ASD_Data)
    disp( 'ERROR - The lengths of the ASD vector and Frequency vector must match')
    disp(['The ASD vector is          : ', num2str(length(ASD_Data))])
    disp(['Whereas the Freq vector is : ', num2str(length(Freq))])
    RMS_Band = NaN;
    return 
else
    BW_diff   = diff(Freq_Band);               %calculate the bin widths
    BW_bins   = [BW_diff, BW_diff(end)];  %match the length of the ASD
    BW_vect   = BW_bins(end:-1:1);        %flip the vector for right to left
end

% Now do the real calulation
RMS_rev = sqrt(cumsum(BW_vect .* Data_Band(end:-1:1) .^ 2));
RMS     = RMS_rev(end:-1:1);

% Now finish the function
RMS_Band_Total  = RMS(1);
RMS_Band        = RMS;

return