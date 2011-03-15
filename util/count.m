function [n] = count(v)
% COUNT  Count the number of nonzero elements in a vector

n = length(find(v));
