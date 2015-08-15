% Filter_Split = Filter_Module_Split(Filter,Number_Of_FM)
% Breaking one filter into several Filter module (filter already discretized - z domain)
% VL - December 20, 2012 - Initial rev: 6571
%
%  need to make sure that complex pairs stay together -6/5/13  
%

function Filter_Split = Filter_Module_Split(Filter,Number_Of_FM)

% Exctracting poles and zeros
[z,k] = zero(Filter);
[p] = pole(Filter);
Ts=Filter.Ts;

% Resorting Poles and Zeros
p=sort(p); Num_Poles=length(p);
z=sort(z); Num_Zeros=length(z);

real_p = p(imag(p) == 0);
imag_p = p(imag(p) ~= 0);

real_z = z(imag(z) == 0);
imag_z = z(imag(z) ~= 0);


Num_Modules=ceil(Num_Poles/20);
if Num_Modules == 0  %there has to be a better way to do this
    Num_Modules = 1;
end
if Num_Modules>Number_Of_FM
    cprintf([1 0 0],['There are too many poles and zeros relative too the number of filter module you plan to use. You need ' num2str(Num_Modules) ,' filter modules.']);fprintf('\n')
else
    for zz=1:Number_Of_FM
        newpees = [];     newzees = [];  %initialize temp variable to hold poles and zeros for current filter modlule (FM)
        if length(real_p) > 0            % are there any real poles
            if length(real_p) <= 20      % less then 20?
                newpees = real_p;        % if so stick them all into this FM
                real_p = [];             % get rid of used poles (ick)
            else
                newpees = real_p(1:20);        % if more then 20 take the first 20
                real_p = real_p(21:end);       % get rid of used poles (ick)
            end
        end 
        remaining_p_spots = 20-length(newpees);                      % how many spots left
        if length(imag_p) > remaining_p_spots                        % if there are more complex poles then spots
            newpees =[newpees; imag_p(1:2*floor(remaining_p_spots/2))];      % make sure that we are taking them in pairs (i think that this will work)
            imag_p = imag_p((1+2*floor(remaining_p_spots/2)):end);        % get rid of used poles (ick)
        else
            newpees =[newpees; imag_p];                  % else use up all of the complex poles
            imag_p = [];                                 % get rid of used poles (ick)
        end
        current_pees = length(newpees);                     % how many poles in current FM
        if length(real_z) > 0                                % are there any real zeros
            if length(real_z) > current_pees                  % are there more real zeros then # poles in FM
                newzees = real_z(1:current_pees);            % if so take the first current pees
                real_z = real_z((1+current_pees):end);          % get rid of used zeross (ick)
            else
                newzees = real_z;       %else use all of the real zeros
                real_z = [];            % get rid of used zeross (ick)
            end
        end
        remaining_z_spots = current_pees -length(newzees);                      % how many spots left
        if length(imag_z) > remaining_z_spots                            % if there are more complex zeros then spots
            newzees =[newzees; imag_z(1:2*floor(remaining_z_spots/2))];      % make sure that we are taking them in pairs (i think that this will work)
            imag_z = imag_z((1+2*floor(remaining_z_spots/2)):end);        % get rid of used zeross (ick)
        else
            newzees =[newzees; imag_z];                   % else use up all of the complex zeros
            imag_z = [];                                 % get rid of used zeros (ick)
        end
        
        imag(sum(newpees))
        imag(sum(newzees))
       % test to make sure that the filter is good
       % if imag(sum(newpees)) ~= 0 ||  imag(sum(newzees)) ~= 0
       %     error('Bad Filter Conversion -----  Crashing Now')
       % end
        
        %if zz<Num_Modules
            Filter_Split(zz) = zpk(newzees,newpees,1,Ts);
        %elseif zz==Num_Modules
        %    Filter_Split(zz)=zpk(newzees,newpees,k,Ts);
        %else
        %    Filter_Split(zz)  = zpk([],[],1,Ts);
        %end
    end
end
  number_of_used_modlues = 0;
  for nn = 1:Number_Of_FM
      if   isempty(zero(Filter_Split(nn))) && isempty(pole(Filter_Split(nn)))
      else
          number_of_used_modlues =  number_of_used_modlues + 1;
      end
  end
  if number_of_used_modlues == 0
       number_of_used_modlues = 1;
          %error('Serious Confusion in Filter Spliting -----  Crashing Now')
  end
     
      


  GAIN = abs(k)^(1/number_of_used_modlues);
  for jj = 1:number_of_used_modlues
      if jj == 1
          Filter_Split(jj) = sign(k)*GAIN*Filter_Split(jj);
      else
          Filter_Split(jj) = GAIN*Filter_Split(jj);
      end
  end
  if length(real_z) > 0 || length(real_p) > 0 length(imag_z) > 0 || length(imag_p) > 0 
      error('There are left over poles and/or zeros ---HowW Sad------- Crashing now')
  end

end
