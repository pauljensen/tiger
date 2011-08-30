function [filtered,locs,tf] = cellfilter(f,C,inverse)
% CELLFILTER  Return a subset of a cell array
%
%   [FILTERED,LOCS,TF] = CELLFILTER(F,C)
%   [FILTERED,LOCS,TF] = CELLFILTER(F,C,INVERSE)
%
%   Returns the elements of C for which F(C{i}) is true.  The locations of
%   the elements are LOCS.  TF is a logical indexing array such that 
%   FILTERED = C(TF) = C(LOCS).
%
%   If INVERSE is true, then elements are returned when F(C{i}) is not 
%   true.  The default is INVERSE = false.

if nargin < 3
    inverse = false;
end

if inverse
    F = @(x) ~f(x);
else
    F = f;
end

tf = cellfun(F,C);
filtered = C(tf);

if nargout >= 2
    locs = find(tf);
end

