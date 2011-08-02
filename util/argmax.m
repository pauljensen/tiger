function [locs] = argmax(x,N)
% ARGMAX Return the arg-maximum of a function
%
%   [LOCS] = ARGMAX(X) returns the indices of the maximum values in X.
%   If called as ARGMAX(X,N), a maximum of N indices are returned.

if nargin < 2
    N = 1;
end

locs = argf(@max,x,N);
