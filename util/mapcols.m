function [mapped] = mapcols(f,M,nrows)
% MAPCOLS  Apply a function to columns in a matrix
%
%   [MAPPED] = MAPCOLS(F,M) applies the function F to each column in M:
%       MAPPED(:,i) = F(M(:,i)) for each i
%
%   MAPCOLS(F,M,NROWS) specifies the number of rows returned by F.

if nargin < 3 || isempty(nrows)
    nrows = size(M,1);
end

ncols = size(M,2);
mapped = zeros(nrows,ncols);
for i = 1 : ncols
    mapped(:,i) = f(M(:,i));
end
