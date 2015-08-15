function list=flatten(mat)
% list=flatten(mat) list is the flattened matrix

list=reshape(mat',1,size(mat,1)*size(mat,2));