function fill_matrix_values(chan_name, matrix)
% This function takes the channel name of a matrix and fills it in with the
% matrix of values passed as the second argument
%
% If you don't pass a matrix that is the appropriate size, ezcawrite will
% display an error for each bad cell.  The error makes the function pause
% for about 10 seconds and then it continues on.
%
% updated to unix() from system(), and
% caput() from ezcawrite(),
% BTL DEC, april 19, 2011
% 
% writes as JAn 2011 convention
% matrixname_rowcolumn
%
% Vincent updated to run with new name_row_col convention.


msize = size(matrix);
for row = 1:msize(1)
    for col = 1:msize(2)
       system(['caput ', chan_name, '_', num2str(row),'_', num2str(col),...
           ' ', num2str(matrix(row,col))]); 
    end
end
