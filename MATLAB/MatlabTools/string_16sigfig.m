function string = string_16sigfig(input)
% string_16sigfig  converts a number to sting with 16 significant figures
% has 4 leading spaces (or 3 with mn, pads 0s on the right of the decimal point if
% required.
%
% string_16sigfig(12) returns
% '    12.00000000000000' and
% string_16sigfig(0.00123) returns
% '    0.001230000000000000'
% like %1.16g, but never gives you exponentials.
%
% is num is a vector of numbers, then the output is 
% the concatination of the strings for each number
%
%e.g. string_16sigfig([1234.5678901234567890, 0.12, -12])
%ans =
%'    1234.567890123457    0.1200000000000000'

% for use with quack
% Brian Lantz, Aug 2, 2012
% Rich M added the 0 check, BTL made the zero check print lots of zeros,
%    which is more like foton.

nums = length(input);
string = '';

for index = 1:nums
    num = input(index);
    % how many digits to the right of the decimal point?
    if num == 0
        string = [string ,'   0.0000000000000000'];
    else
        digits = 15 - floor(log10(abs(num)));
        format_string = ['   % 1.',num2str(digits),'f'];
        this_string = sprintf( format_string, num);
        string = [string,this_string];
    end
end



