function [locs] = argf(f,x,N)

if nargin < 3 || isempty(N)
    N = 1;
end

if isempty(x)
    locs = [];
else
    [~,locs] = f(x);
    locs = locs(1:min([N length(locs)]));
end
