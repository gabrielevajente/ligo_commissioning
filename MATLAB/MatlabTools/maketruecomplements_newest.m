 
function [lp_final, hp_final final_blend_freq blend_angle] = maketruecomplements(lp_initial, hp_initial, check_results,blend_freq)
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

%{  
% here is a pair to test on
lp_initial = myellip_z2(0.821,3,2,40,100);  % notch at 2 Hz

hp_initial = zpk(-2*pi*[0,0,0],-2*pi*[.020, .3*[1+2i, 1-2i]/sqrt(5)],1);
%}

if nargin == 2
    check_results = false;  % if true, we will print up a bunch of check stuff
end

if nargin < 4
     blend_freq = 0.5;
end
   
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
    beep;pause(0.2);beep;pause(0.2);beep;pause(1);beep
    lp_final = 0;
    hp_final = 0;
   error('Ending maketruecomplents functions');
end

% make sure the lp_initial and hp_initial are 1 at the ends

% remove repeated poles and zeros

tol = .02;	% within 2% 

Tol = 1E-10;
zz = Tol*round(sort(zero(lp_norm))/Tol);  % strip off numerical issues with imag parts near 0
pp = Tol*round(sort(pole(lp_norm))/Tol);

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
% 
% for nn = length(zz):-1:1	% count backwards so we can remove the zeros as we go
% 	diff = abs(zz(nn)-pp)./abs(pp);
% 	target = min(find(diff < tol));	% min removes trouble from repeated roots
% 	if ~isempty(target)
% 		pp = [pp(1:target-1);pp(target+1:end)];
% 		zz = [zz(1:nn-1);zz(nn+1:end)];
% 	end
% end
% this can break if you don't keep complex pairs together, for example,
% this will fail if there is a single real zero near a complex pole pair.
% or a complex zero between 2 complex poles, and the cancellations aren't
% symmetric

 [lp_norm new_zz new_pp new_gg] =   strip(lp_norm,1E-2 ) ;



if check_results 
    disp('For the LOW pass filter')
    disp('  initial poles were:')
    disp(num2str(pp_lp_initial))
    disp(' ')
    disp('  final poles are:')
    disp(num2str(new_pp))
    disp(' ')
    disp('  initial zeros were:')
    disp(num2str(zz_lp_initial))
    disp(' ')
    disp('  final zeros are:')
    disp(num2str(new_zz))

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
    beep;pause(1);beep;pause(0.2);beep;pause(0.2);beep 
    
    if 1 == 1 %try something very squirrilly
        PP = pole(hp_norm);
        [ZZ,GG] = zero(hp_norm);
        Real_Index = find(real(PP)>0);
        PP(Real_Index) = -PP(Real_Index);
        hp_norm = zpk(ZZ,PP,GG);
    else
        lp_final = 0;
        hp_final = 0;
        return
    end
    
end

 
zz = Tol*round(sort(zero(hp_norm))/Tol);
pp = Tol*round(sort(pole(hp_norm))/Tol);

DC_poles = find(pp == 0);
if ~isempty(DC_poles)
    disp('ERROR')
    disp('there should not be any poles at DC')
    lp_final = 0;
    hp_final = 0;
    return
end

%      
%     
zz_hp_initial = zz;
pp_hp_initial = pp;

 [hp_norm new_zz new_pp new_gg] =   strip(hp_norm,1E-2 ) ;
% for nn = length(zz):-1:1	% count backwards so we can remove the zeros as we go
% 	diff = abs(zz(nn)-pp)./abs(pp);
% 	target = min(find(diff < tol));	% min removes trouble from repeated roots
% 	if ~isempty(target)
% 		pp = [pp(1:target-1);pp(target+1:end)];
% 		zz = [zz(1:nn-1);zz(nn+1:end)];
% 	end
% end
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
    disp(num2str(new_pp))
    disp(' ')
    disp('  initial zeros were:')
    disp(num2str(zz_hp_initial))
    disp(' ')
    disp('  final zeros are:')
    disp(num2str(new_zz))

end

if length(zz) ~= length(pp)
	disp('error in reducing the high pass filter')
    disp(' the number of zeros and poles don''t match')
end

if ~isreal(sum(zz)) || ~isreal(sum(pp))
    cprintf([0.75 0 0],'none matched pole/zero pairs\n')
    x = input('input something orother')
end
    

hp_final = zpk(zz,pp,1);

if check_results
    figure(17);
    bode(hp_norm, hp_initial,lp_initial,lp_final);
    legend('hp norm','hp initial','lp initial','lp final')
    grid on
    title('High Pass Input Filters');
end


 
	ff = logspace(log10(blend_freq/1000),log10(blend_freq*1000),1400);
	ww = 2*pi*ff;
	FR_lp = squeeze(freqresp(lp_final,ww));
	FR_hp = squeeze(freqresp(hp_final,ww));
	
    if 1 == 0
        load temp
        lp_resp =  squeeze(freqresp(lp,ww));
         hp_resp =  squeeze(freqresp(hp,ww));
    end
    
    blend_index_L = max(find(abs(FR_lp)>=abs(FR_hp)));
    blend_index_H = min(find(abs(FR_hp)>=abs(FR_lp)));
     
    if  blend_index_H - blend_index_L ~= 1
        WARN = 1;        
        blend_index  = [blend_index_L blend_index_H];
    else       
         WARN = 0;
         blend_index  = blend_index_L;
    end
    final_blend_freq = ff(blend_index);
    LP_Phase = 180*unwrap(angle(FR_lp))/pi;
    HP_Phase = 180*unwrap(angle(FR_hp))/pi;
    
    HP_Phase = HP_Phase - 360*round(HP_Phase(end)/360);
    LP_Phase = LP_Phase - 360*round(LP_Phase(1)/360);
    
    
    blend_angle =LP_Phase(blend_index) -  HP_Phase(blend_index);
    if length(blend_angle) > 1
          error('Multiple Crossings please fix');
    end
%%
 if check_results
    if nargin > 3
        xrange = blend_freq*[1/300 300];
    else
        xrange = blend_freq*[1E-3 3];
    end
	figure(3)
    subplot(211)
	ll = loglog(ff,abs(FR_lp),...
                ff,abs(FR_hp),...
                ff,abs(FR_lp+FR_hp),...
                ff(blend_index),abs(FR_lp(blend_index)),'kx',...
                'linewidth',2,'markersize',15);
    title('Complementary Filters','fontname','Blackadder ITC','fontsize',30,...
        'color',[0 1 0.8],'fontweight','bold')
   
    legend('Low Pass', 'High Pass', 'Sum','Location','NorthWest')
    ylabel('Magnitude','fontname','Cuckoo','fontsize',24,...
        'color',[0.5 0.7 0.8],'fontweight','bold')
   
    %xlabel('Frequency (Hz)','fontname','Cuckoo','fontsize',24,...
     %   'color',[0.5 0.7 0.8],'fontweight','bold')
	set(gca,'XLim', xrange,'YLim',[1E-4 10]);
	grid on
     text(blend_freq,0.002,['The blend frequency is ',num2str(ff(blend_index),3),'Hz'],...
              'fontname','Bauhaus 93','fontsize',20,'color',[0 0 0.8])
     if WARN
         text(blend_freq,0.040,['There might be multiple filter crossings'],...
              'fontname','Nipple','fontsize',16,'color',[1 0 0.8])
     end
    
    if 1 == 0
        hold on
        H = loglog(ff,abs(lp_resp),'--',ff,abs(hp_resp),'--','linewidth',2);
        set(H(1),'color',[1 0.5 0]);
        set(H(2),'color',[0.5 0 1]);
    end
    
    subplot(212)
    ll = semilogx(ff, LP_Phase,...
                  ff, HP_Phase,...
                  ff,180/pi*unwrap(angle(FR_lp+FR_hp)),...
        'linewidth',2);
    if abs(blend_angle) > 179.9
          text(blend_freq/50,20,['The blend angle is BAD! ',num2str(blend_angle,4),' degrees'],...
              'fontname','Blazed','fontsize',24,'color',[1 0 0],'BackgroundColor',[1 1 0]);
    else
        text(0.3,20,['The blend angle is ',num2str(blend_angle',4),' degrees'],...
              'fontname','Bauhaus 93','fontsize',20,'color',[0 0 0.8])
    end
    if sum(real(zero(lp_final+hp_final))>0)>0
         text(blend_freq/150,-160,['There are positive plane zeros in the sum, this is BAD!!'],...
              'fontname','Blazed','fontsize',20,'color',[1 0 0],'BackgroundColor',[1 1 0]);
    end
        
    
    ylabel('Phase','fontname','Cuckoo','fontsize',24,...
        'color',[0.5 0.7 0.8],'fontweight','bold')
    xlabel('Frequency (Hz)','fontname','Cuckoo','fontsize',24,...
        'color',[0.5 0.7 0.8],'fontweight','bold')
    xlim(xrange)
    set(gca,'ytick',-720:45:720);
    grid on
    disp(['The max real pole is ',num2str(max(real(pole(lp_final + hp_final))))])
    %IDfig
%    FillPage('w')
%%

    figure(4)
    LP_Z = zero(lp_final)/(2*pi);
    LP_P = pole(lp_final)/(2*pi);
    HP_Z = zero(hp_final)/(2*pi);
    HP_P = pole(hp_final)/(2*pi);
    
    plot(real(LP_Z),imag(LP_Z),'bX',...
         real(HP_Z),imag(HP_Z),'rX',...
         real(LP_P),imag(LP_P),'bO',...
         real(HP_P),imag(HP_P),'rO',...
         'linewidth',3,'markersize',16);
    grid on 
    legend('Low Pass Zeros','High Pass Zeros','Low Pass Poles','High Pass Poles',2);
      title('Poles-Zeros for Filters','fontname','Blackadder ITC','fontsize',30,...
        'color',[0 1 0.8],'fontweight','bold')
   
     
    ylabel('Imanginary Part (Hz)','fontname','Cuckoo','fontsize',24,...
        'color',[0.5 0.7 0.8],'fontweight','bold')
     xlabel('Real Part (Hz)','fontname','Cuckoo','fontsize',24,...
        'color',[0.5 0.7 0.8],'fontweight','bold')
    
%%
end