function out_flag = isdiscrete(filter_name)
% isdiscrete  returns a 1 is the filter is discrete time
% call as out_flag = isdiscrete(filter_name)
%
% $Id: isdiscrete.m 125 2008-07-31 15:49:03Z seismic $

Ts = get(filter_name,'Ts');
  if Ts == 0
      out_flag = 0;
  elseif Ts >= 0
      out_flag = 1;
  else
      error('Negitive time steps??? what univerise are we living in?');
  end
% 
% 
% val = get(filter_name,'Variable');
% if val == 's'
%     out_flag = 0;
% elseif val =='z'
%     out_flag = 1;
% end
