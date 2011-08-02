function [locs] = argf(f,x,N)
% ARGF Return the index vector for a function
%
%   [LOCS] ARGF(F,X) returns [~,LOCS] = F(X).  If called as ARGF(F,X,N),
%   a maximum of N arguments are returned.

if nargin < 3 || isempty(N)
    N = 1;
end

if isempty(x)
    locs = [];
else
    [~,locs] = f(x);
    locs = locs(1:min([N length(locs)]));
end
