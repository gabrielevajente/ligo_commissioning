function [Mat err]=read_matrix_values(chan, matrix)
% Adapted BTL Fill_matrix_values to read those values.
% HP 09/15/14

msize = size(matrix);
for row = 1:msize(1)
    for col = 1:msize(2)
        Channel_Name=[chan, '_', num2str(row),'_', num2str(col)];
       [err val]=system(['caget -t ', Channel_Name]);
       Mat(row,col)=str2num(val);
       if err == 1
                   cprintf([1 0 0],['Unable to retreive ' ]); fprintf('\n'); error=0;
       end
    end
end
