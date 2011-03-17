function [c] = assert_cell(str)
% ASSERT_CELL  Assert that variable is a cell array.
%
%   [C] = ASSERT_CELL(STR)
%   
%   Checks that STR is a cell array.  If it is not (i.e., if it is a
%   single string), then converts it to a cell array of length one.

if isempty(str)
    c = {};
elseif ~isa(str,'cell')
    c = {str};
else
    c = str;
end
