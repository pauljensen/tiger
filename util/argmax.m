function [locs] = argmax(x,N)

if nargin < 2
    N = 1;
end

locs = argf(@max,x,N);
