function [x] = expand_to(x,N,dim)
% EXPAND_TO  Expand a vector to length N
%
%   [X] = EXPAND_TO(X,N,DIM)
%
%   Expands the vector X to length N by filling with zeros.  If X is a
%   matrix, it is expanded to an N by N matrix.
%
%   If X is empty, a vector of zeros is created.  If DIM = 1 (default), 
%   the result is a column vector.  If DIM = 2, the a row vector is
%   returned.

if nargin < 4 || isempty(dim)
    dim = 1;
end
    
assert(nargin >= 2, 'at least two arguments required');

if isempty(x)
    if dim == 1
        x = zeros(N,1);
    else
        x = zeros(1,N);
    end
end

if min(size(x)) <= 1
    if length(x) < N
        x(N) = 0;
    end
else
    if any(size(x) < N)
        x(N,N) = 0;
    end
end
