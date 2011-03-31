function [matches,locs,tf] = find_like(regex,C)
% FIND_LIKE  Find matches in a cell of strings
%
%   [MATCHES,LOCS,TF] = FIND_LIKE(REGEX,C)
%
%   Returns the elements of C that match the regular expression REGEX.
%   The locations of the elements are LOCS.  TF is a logical indexing 
%   array such that MATCHES = C(TF) = C(LOCS).

f = @(x) ~isempty(regexp(x,regex,'once'));
[matches,locs,tf] = cellfilter(f,C);
