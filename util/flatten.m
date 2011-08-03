function [list] = flatten(lists)
% FLATTEN  Flatten a cell of cells into a single cell.
%
%   >> A = FLATTEN({{1,2},3,{4}})
%   A = 
%       [1]  [2]  [3]  [4]

list = [lists{:}];
