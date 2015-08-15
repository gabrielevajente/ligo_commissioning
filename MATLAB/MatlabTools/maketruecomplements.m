function [lp_final, hp_final] = maketruecomplements(lp_initial, hp_initial, check_results)
%maketruecomplememts  turns prototype filters into true complementary filters
%  simple function which creates a true pair of complementary filters from
%  a prototype pair of filters, and removes repeated and nearly repeated
%  poles and zeros. 
%  
%call as  
%  [lp_final, hp_final] = maketruecomplements(lp_initial, hp_initial)
% 
%  lp_initial and hp_initial are the initial lowpass and highpass filters
%  (each is a sys).
%
%  lp_final = reduce(lp_initial/(lp_initial + hp_initial)) and 
%  hp_final = reduce(hp_initial/(lp_initial + hp_initial)) 
%
%  the reduce is shorthand for the removal of repeated poles and zeros
%  which are "close". this function is still a bit dodgy. the default
%  tolerance is 0.02, ie the pole, p, and zero, z, get removed if 
%  abs(z-p)./abs(p) < tol
%
% it can be called with the optional third argument to turn on and off the
% monitor plots and intermediate zero-pole calculations, as
% 
% [lp_final, hp_final] = maketruecomplements(lp_initial, hp_initial, check_flag)
% where check_flag is either true or false,
%  true prints all the stuff, and false does not
%
% $Id: maketruecomplements.m 125 2008-07-31 15:49:03Z seismic $
%
% NOTE : this is depricated code - PLEASE use minreal instead
% BTL May 5, 2014


%{  
% here is a pair to test on
lp_initial = myellip_z2(0.821,3,2,40,100);  % notch at 2 Hz

hp_initial = zpk(-2*pi*[0,0,0],-2*pi*[.020, .3*[1+2i, 1-2i]/sqrt(5)],1);
%}

if nargin == 2
    check_results = false;  % if true, we will print up a bunch of check stuff
end

disp(' ' )
disp(' WARNING - maketruecomplements is depricated code')
disp(' we prefer minreal, e.g.')
disp('        minreal_tol = 1e-2;')
disp('        lp_comp = minreal(LP_proto/ (LP_proto + HP_proto), minreal_tol);')
disp('        hp_comp = minreal(HP_proto/ (LP_proto + HP_proto), minreal_tol);')
disp('BTL May 5, 2014')
dbstack  % tell the user where the call came from
disp(' ')


DC_lp_initial = evalfr(lp_initial,0);
if abs(DC_lp_initial - 1) > .01
    disp('WARNING')
    disp(' your low pass initial filter')
    disp(' does not seem to go to 1 at low frequencies')
    disp(' this will cause strange behavior in the final filters')
end

HF_hp_initial = evalfr(hp_initial,1e4);
if abs(HF_hp_initial - 1) > .01
    disp('WARNING')
    disp(' your high pass initial filter')
    disp(' does not seem to go to 1 at high frequencies')
    disp(' this will cause strange behavior in the final filters')
end



lp_norm = lp_initial/(hp_initial + lp_initial);

if(max(real(pole(lp_norm)))) > 0
    disp('  ERROR')
    disp('the normalized low pass is not stable!')
    disp('there are poles at:')
    disp(num2str(pole(lp_norm)))
    lp_final = 0;
    hp_final = 0;
    return
end

% make sure the lp_initial and hp_initial are 1 at the ends

% remove repeated poles and zeros

tol = .02;	% within 2% 

zz = 1e-10*round(1e10*sort(zero(lp_norm)));  % strip off numerical issues with imag parts near 0
pp = 1e-10*round(1e10*sort(pole(lp_norm)));

DC_poles = find(pp == 0);
if ~isempty(DC_poles)
    disp('ERROR')
    disp('there should not be any poles at DC')
    lp_final = 0;
    hp_final = 0;
    return
end

    
zz_lp_initial = zz;
pp_lp_initial = pp;

for nn = length(zz):-1:1	% count backwards so we can remove the zeros as we go
	diff = abs(zz(nn)-pp)./abs(pp);
	target = min(find(diff < tol));	% min removes trouble from repeated roots
	if ~isempty(target)
		pp = [pp(1:target-1);pp(target+1:end)];
		zz = [zz(1:nn-1);zz(nn+1:end)];
	end
end
% this can break if you don't keep complex pairs together, for example,
% this will fail if there is a single real zero near a complex pole pair.
% or a complex zero between 2 complex poles, and the cancellations aren't
% symmetric

if check_results 
    disp('For the LOW pass filter')
    disp('  initial poles were:')
    disp(num2str(pp_lp_initial))
    disp(' ')
    disp('  final poles are:')
    disp(num2str(pp))
    disp(' ')
    disp('  initial zeros were:')
    disp(num2str(zz_lp_initial))
    disp(' ')
    disp('  final zeros are:')
    disp(num2str(zz))

end

kk = prod(abs(pp))/prod(abs(zz));

lp_final = zpk(zz,pp,kk);


%%%%%  fix the high pass part, also
hp_norm = hp_initial/(hp_initial + lp_initial);

if(max(real(pole(hp_norm)))) > 0
    disp('  ERROR')
    disp('the normalized high pass is not stable!')
    disp('there are poles at:')
    disp(num2str(pole(hp_norm)))
    lp_final = 0;
    hp_final = 0;
    return
end

zz = 1e-10*round(1e10*sort(zero(hp_norm)));
pp = 1e-10*round(1e10*sort(pole(hp_norm)));

DC_poles = find(pp == 0);
if ~isempty(DC_poles)
    disp('ERROR')
    disp('there should not be any poles at DC')
    lp_final = 0;
    hp_final = 0;
    return
end

    
zz_hp_initial = zz;
pp_hp_initial = pp;

for nn = length(zz):-1:1	% count backwards so we can remove the zeros as we go
	diff = abs(zz(nn)-pp)./abs(pp);
	target = min(find(diff < tol));	% min removes trouble from repeated roots
	if ~isempty(target)
		pp = [pp(1:target-1);pp(target+1:end)];
		zz = [zz(1:nn-1);zz(nn+1:end)];
	end
end
% this can break if you don't keep complex pairs together, for example,
% this will fail if there is a single real zero near a complex pole pair.
% or a complex zero between 2 complex poles, and the cancellations aren't
% symmetric

if check_results 
    disp('For the HIGH pass filter')
    disp('  initial poles were:')
    disp(num2str(pp_hp_initial))
    disp(' ')
    disp('  final poles are:')
    disp(num2str(pp))
    disp(' ')
    disp('  initial zeros were:')
    disp(num2str(zz_hp_initial))
    disp(' ')
    disp('  final zeros are:')
    disp(num2str(zz))

end


if length(zz) ~= length(pp)
	disp('error in reducing the high pass filter')
    disp(' the number of zeros and poles don''t match')
end

hp_final = zpk(zz,pp,1);

if check_results
	ff = logspace(-3,2,1000);
	ww = 2*pi*ff;
	FR_lp = squeeze(freqresp(lp_final,ww));
	FR_hp = squeeze(freqresp(hp_final,ww));
	
	figure
    subplot(211)
	ll = loglog(ff,abs(FR_lp),ff,abs(FR_hp),ff,abs(FR_lp+FR_hp));
    title('Complementary Filters')
    set(ll(1),'LineWidth',2)
    set(ll(2),'LineWidth',2)
    set(ll(3),'LineWidth',2)
    legend('Low Pass', 'High Pass', 'Sum','Location','NorthWest')
    ylabel('Magnitude')
    xlabel('Frequency (Hz)')
	axis([.005 50 1e-3 3])
	grid on
    
    subplot(212)
    ll = semilogx(ff,180/pi*unwrap(angle(FR_lp)), ff , 180/pi*unwrap(angle(FR_hp)),ff,180/pi*unwrap(angle(FR_lp+FR_hp)));
    set(ll(1),'LineWidth',2)
    set(ll(2),'LineWidth',2)
    set(ll(3),'LineWidth',2)
    ylabel('Phase')
    xlabel('Frequency (Hz)')
    xlim([.005 50])
    grid on
    disp(['The max real pole is ',num2str(max(real(pole(lp_final + hp_final))))])
    IDfig
    FillPage('w')
end
