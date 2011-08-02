function [locs] = argmin(x,N)
% ARGMIN Return the arg-minimum of a function
%
%   [LOCS] = ARGMIN(X) returns the indices of the minimum values in X.
%   If called as ARGMIN(X,N), a maximum of N indices are returned.

if nargin < 2
    N = 1;
end

locs = argf(@min,x,N);
