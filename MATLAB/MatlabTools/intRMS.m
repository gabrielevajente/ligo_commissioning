function [RMS] = intRMS(ASD_Data, Freq)
%function [RMS] = intRMS(RMSSD_Data, Freq vector or bin width in Hz)
% intRMS takes a data vector that is in the form of an ASD (Root Mean
% Square Spectral Density) and does a right to left integration of the RMS
% values. This way, any point on the plot is the integration of the RMS
% from that frequency to the end of the vector
%
% DEC 2011.11.15 (with BTL help)
%

% OK, now find out if the second input is a bandwidth or frequency
if length(Freq) == 1;
    BW      = Freq;
    BW_vect = BW * [1:length(ASD_Data)];
elseif length(Freq)~= length(ASD_Data)
    disp( 'ERROR - The lengths of the ASD vector and Frequency vector must match')
    disp(['The ASD vector is          : ', num2str(length(ASD_Data))])
    disp(['Whereas the Freq vector is : ', num2str(length(Freq))])
    RMS = NaN;
    return
else
    BW_diff = diff(Freq);               %calculate the bin widths
    BW_bins = [BW_diff, BW_diff(end)];  %match the length of the ASD
    BW_vect = BW_bins(end:-1:1);        %flip the vector for right to left
end

% Now do the real calulation
RMS_rev = sqrt(cumsum(BW_vect .* ASD_Data(end:-1:1) .^ 2));
RMS     = RMS_rev(end:-1:1);

% Now finish the function
return