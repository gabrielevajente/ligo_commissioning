%returns a zpk filter with a slope that corresponds to the constant phase
% if low < high the slope will be positive, phase gain
% if low > high the slope will be negitive, phase loss
% So bode(slopesetter(100,2,6,1,45)) will return a filter which has a slope
% of 1/sqrt(f) from 2 to 100Hz, with a maxium phase loss of 435 degrees
%************* remember that these are approximations *****************

%the order is how many zero pole pairs will be included, the more the
%smoother the filter, and it better be an integer > 1

%it seems to work for arbitrary positive phase, although the large the
%phase that you ask for the larger the descrepenc

function Z = slopesetter(low,high,order,Gain,phase);
   
order = order -1;  %because we start at zero
powerer = phase/90;
Step = exp((log(high)-log(low))/(order+powerer));
Ratio = Step^powerer;

POLES = low*Step.^(0:order);
ZEROS = Ratio*POLES;
   
Z = zpk(-2*pi*ZEROS,-2*pi*POLES,Gain);
return