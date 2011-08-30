function [str] = joinstr(c,spacer)
% JOINSTR  Concatenate a cell of strings with a spacer
%
%   [STR] = JOINSTR(C,SPACER)
%
%   Concatenate the strings in cell C, separating the strings
%   with SPACER.  If SPACER is not given, no separation is placed
%   between elements of C (SPACER = '').

if nargin < 2
    spacer = '';
end

if ~isa(c,'cell')
    str = c;
    return
end

C = cell(1,2*length(c)-1);
for i = 1 : length(c)
    C{2*i-1} = c{i};
    if i < length(c)
        C{2*i} = spacer;
    end
end

str = [C{:}];
