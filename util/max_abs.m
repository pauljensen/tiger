function [maxabs] = max_abs(varargin)
% MAX_ABS  Maximum absolute value in a set of vectors
%
%   [MAXABS] = MAX_ABS(...)
%
%   MAX_ABS(A,B,C,...) finds MAX(|A|,|B|,|C|,...), the single largest
%   absolute value in any of the given vectors.
%
%   Examples:
%   >> max_abs([1 2 11],[-12 5 3])
%   ans = 
%       12

cands = cellfun(@(x) max(abs(x)),varargin);
maxabs = max(cands);

