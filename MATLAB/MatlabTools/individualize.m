function new_data_struct = individualize(generic_data_struct, module)
% individualize  converts a generic SEI autoquack datastructure into a one for a specific platform
%  specific_data_struct = individualize(generic_data_struct, 'module')
%  generic_data_struct and specific data struct are autoquack filter data
%  structures.
%  except, 
%  the names in the generic data struct all start with xxx instead of a
%  chamber, e.g. generic_BSCdampers(1).name = 'xxx_ST1_DAMP_X'
%
%  individualize() will replace the 'xxx' with the string in the 'MODULE'
%  parameter. 
%  
%  e.g. if you run this on the case above,
% ITMX_dampers = individualize(generic_BSCdampers, 'ITMX');
%
% then ITMX_dampers(1).name = 'ITMX_ST1_DAMP_X'
%
% Brian Lantz, Nov 21, 2011

if ~ischar(module)
    error('module must be a string, e.g. ''ITMX''');
end
module = upper(module); % sigh.

new_data_struct = generic_data_struct;

for ii = 1:length(generic_data_struct);
    old_name = generic_data_struct(ii).name;
    new_name = strrep(old_name, 'xxx', module);
    if strcmp(new_name, old_name)
        warning(['string xxx not fould in element ',num2str(ii)]);
    end
    new_data_struct(ii).name = new_name;
end

