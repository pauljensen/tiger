function [names] = array2names(fmt,array,dim)

if nargin < 3 || isempty(dim)
    dim = 1;
end

names = arrayfun(@(x) sprintf(fmt,x),array,'Uniform',false);
if dim == 1
    names = names(:);
end

