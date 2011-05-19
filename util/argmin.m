function [locs] = argmin(x,N)

if nargin < 2
    N = 1;
end

locs = argf(@min,x,N);
