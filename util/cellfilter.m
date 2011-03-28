function [filtered,locs,tf] = cellfilter(f,C)
% CELLFILTER  Return a subset of a cell array
%
%   [FILTERED,LOCS,TF] = CELLFILTER(F,C)
%
%   Returns the elements of C for which F(C{i}) is true.  The locations of
%   the elements are LOCS.  TF is a logical indexing array such that 
%   FILTERED = C(TF) = C(LOCS).

tf = cellfun(f,C);
filtered = C(tf);

if nargout == 2
    locs = find(tf);
end

