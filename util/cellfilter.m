function [filtered,locs,tf] = cellfilter(f,C)

tf = cellfun(f,C);
filtered = C(tf);

if nargout == 2
    locs = find(tf);
end

