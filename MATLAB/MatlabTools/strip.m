%remove overlapping poles and zeros 
function [new_filt new_zz new_pp new_gg] = strip(filty,tol,rescale) 

 if nargin > 2  %prescale the filter, rescale needs to be a cell
     filty = prescale(filty,rescale);
 end
 norm_freq = 1E-2;
 norm_gain =  abs(freqresp(filty,2*pi*norm_freq));
% warning('off','Control:transformation:StateSpaceScaling'); %#ok<WNOFF>
warning off
%   [zz gg]  = zero(filt);
%  pp = pole(filt);
 [zz,pp,gg] = zpkdata(filty,'v');
 warning on
 %warning('on','Control:transformation:StateSpaceScaling'); 

 % there has to be a better way to do this, but I'm not sure how, cellfun looked good but doesn't work on ss
 numdim = length(size(filty));
 if numdim == 2
     if sum(size(filty)) == 2  %one filter one input one output
         start_poles = pp;
         start_zeros = zz;
         start_gain = gg;
         current_poles = start_poles;
         current_zeros = start_zeros;
         [new_filt  current_poles current_zeros current_gain] = reduce_poles( current_zeros,current_poles, start_gain,norm_gain ,norm_freq,tol );
         %  new_filt(jj) = zpk(current_poles, current_zeros, current_gain);
         new_pp = current_poles ;
         new_zz = current_zeros ;
         new_gg = current_gain ;
     else
         for jj = 1:size(filty,1)
             for kk = 1:size(filty,2)
                 start_poles = pp{jj,kk};
                 start_zeros = zz{jj,kk};
                 start_gain = gg(jj,kk);
                 current_poles = start_poles;
                 current_zeros = start_zeros;
                 if any(real(current_poles) > 0)
                     beep
                 end
                 try
                     %                          [jj kk]
                     [new_filt(jj,kk) current_poles current_zeros current_gain] = reduce_poles( current_zeros,current_poles,start_gain,norm_gain(jj,kk),norm_freq,tol );
                 catch
                     cprintf([0 0 1],['whoops in loop ',num2str([jj kk]),'\n'])
                 end
                 % new_filt(jj,kk) = zpk(current_poles, current_zeros, current_gain);
                 new_pp{jj,kk} = current_poles ;
                 new_zz{jj,kk} = current_zeros ;
                 new_gg(jj,kk) = current_gain ;
             end
         end
     end
     else
         error('OOPS')
     end
     
 
  

return
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [new_filt zz pp gg] = reduce_poles(zz,pp,gg,norm_gain,norm_freq,tol)
  start_zz = zz;
  start_pp = pp;
  start_gg = gg;
  if isempty(zz) && isempty(pp)
      new_filt = tf(0);
      return
  end
  if 1 == 6
      %%
      figure(9546)
      bode(zpk(zz,pp,gg));
      grid on
      %%
  end

Tol = 1E-4;
zz  = Tol*round(esort(zz)/Tol);  % strip off numerical issues with imag parts near 0
pp =  Tol*round(esort(pp)/Tol);  %esort sorts by the real part
%round and sort
if imag(sum(pp)) ~= 0 || imag(sum(zz)) ~= 0
    error('BAD Rounding');
end

if any(real(pp) > 0)
    cprintf([0.7 0 0],'\n \n \n \nTHERE are POSITIVE PLANE POLES')
    Max_Pole = max(real(pp));
    III = find(real(pp) == Max_Pole);
    cprintf([0.7 0.7 0],['Maxium positive pole at ',num2str(pp(III(1))),' \n'])
    %error('crashing');
    %return
end
num_zero_zeros = sum(zz == 0);
num_zero_poles = sum(pp == 0);
zz = zz(zz~=0);
pp = pp(pp~=0);
if num_zero_zeros > num_zero_poles   %LP
    zz =  [zeros(num_zero_zeros-num_zero_poles,1);zz];
else    %more poles at zero then zeros at zero                             %HP or flat
    pp = [zeros(num_zero_poles-num_zero_zeros,1);pp];
end

num_zero_zeros = sum(zz == 0);

counter = length(zz);
counter_counter = 0;
old_counter = counter;


while counter > 0
 %for nn = length(zz):-1:(num_zero_zeros+1)	% count backwards so we can remove the zeros as we go
%      if nn == 559
%          d = 0;
%      end
% counter
%  if counter == 163
%      beep
%  end
if old_counter == counter
    counter_counter = counter_counter +1;
    if counter_counter >10
        error('crashed in strip');
    end
end
% if counter < 32
%     r = 1;
% end
old_counter = counter;
     current_zero = zz(counter);
     %find pole closest to this zero
     if isreal(current_zero)  
         real_poles_index = find(imag(pp)==0);
         diff = current_zero - pp(real_poles_index);
         target_short = find(min(diff)== diff);
         target = real_poles_index(target_short);
     else
         complex_poles_index = find(imag(pp)~=0);
         diff = current_zero - pp(complex_poles_index);
         target_short = find(min(diff)== diff);
         target = complex_poles_index(target_short);
     end         
         
    if length(target) > 1
         Imag_diff = imag(pp(target)-current_zero);
         target = target(min(Imag_diff)== Imag_diff);  %repalced a find here
         target = target(1);
     end
     
     %target = find(diff < tol, 1 );	% min removes trouble from repeated roots
     if  abs(diff(target_short)/abs(current_zero)) < tol
         if isreal(current_zero) && isreal(pp(target))  %real pole/zero
              removed_pole  = pp(target);
              removed_zero  = zz(counter);
           pp = [pp(1:target-1);pp(target+1:end)];
           zz = [zz(1:counter-1);zz(counter+1:end)];
            
           counter = counter -1;
         elseif ~isreal(current_zero) && ~isreal(pp(target)) %imaginary pole/sero
              removed_pole = pp(target);
              pp = [pp(1:target-1);pp(target+1:end)];  %remove overlapping pole
              %Indexed = find(min(pp - conj(removed_pole))  == (pp - conj(removed_pole)));
              Indexed = find(pp == conj(removed_pole));
              if isempty(Indexed)
                  error('couldn-t find conj pair for pole')
              end
              Indexed = Indexed(1); %if there are multiple poles at the same value
              removed_pole(2) = pp(Indexed(1));
              if imag(sum(removed_pole)) > 0
                  error('pole removeal error')
              end
               pp = [pp(1:Indexed(1)-1);pp(Indexed(1)+1:end)];  %remove conjugate of overlapping pole
              
               
               removed_zero = current_zero;
               zz = [zz(1:counter-1);zz(counter+1:end)]; %remove zero
              Indexed = find(min(zz- conj(current_zero))  == (zz - conj(current_zero)));
              removed_zero(2) = zz(Indexed(1));
               try
               zz= [zz(1:Indexed(1)-1);zz(Indexed(1)+1:end)];% remove conjugate of zero
               catch
                   disp('oops')
               end
               counter = counter -2;
         else  %pole and zero are real and complex
             counter = counter -1;
         end
         if abs(imag(sum(zz))) > 0 || abs(imag(sum(pp))) > 0
             error(['goofed up the zero/pole reduction at ',num2str(counter)])
         end
     else
         counter = counter -1;
          removed_pole =[];
          removed_zero = [];
     end
%      [removed_pole removed_zero]
 end
%  
%  %remove silly large poles and zeros
%  zz = zz(abs(zz) < 2*pi*5E3);
%  pp = pp(abs(pp) < 2*pi*5E3);
 
 if length(zz) > length(pp)
     cprintf([0.7 0 0.3],'warning more zeros then poles\n')
 end
     
     
 
 try
     if ~isempty(zz)&& (imag(sum(pp)) ~= 0 || imag(sum(zz)) ~= 0)
        disp('phooey')
        error('Bad reduction')
     end

    if isempty(pp) && isempty(zz)
        new_filt = tf(0);
    else
         new_filt = zpk(zz,pp,gg);
    end
catch
    error('???');
end
if gg ~= 0
    if isnan(freqresp(new_filt,2*pi*norm_freq))
        new_filt = tf(0);
    else
        new_filt = new_filt*norm_gain/abs(freqresp(new_filt,2*pi*norm_freq)) ;
        [warnmsg, msgid] = lastwarn;
        if strcmp(msgid,'Control:ltiobject:SingularDescriptor')
          error('Need to figure out why, and how we got here')
        end
    end
end

[zzz gg] = zero(new_filt);

if 1 == 111
    figure(54)
    plot(real(start_zeros),imag(start_zeros),'bO',...
         real(start_poles),imag(start_poles),'bX',...
         real(zz),imag(zz),'rO',...
         real(pp),imag(pp),'rX',...
         'linewidth',3,'markersize',14);
     grid on
end



return
