function [mapped] = maprows(f,M,ncols)
% MAPROWS  Apply a function to rows in a matrix
%
%   [MAPPED] = MAPROWS(F,M) applies the function F to each row in M:
%       MAPPED(i,:) = F(M(i,:)) for each i
%
%   MAPCOLS(F,M,NCOLS) specifies the number of columns returned by F.

if nargin < 3 || isempty(ncols)
    ncols = size(M,2);
end

nrows = size(M,1);
mapped = zeros(nrows,ncols);
for i = 1 : nrows
    mapped(i,:) = f(M(i,:));
end
