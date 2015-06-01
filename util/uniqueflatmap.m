function S = uniqueflatmap(f,A)
% UNIQUEFLATMAP  Shortcut for UNIQUE(FLATTEN(MAP(f,A)))
%
%   UNIQUEFLATMAP(F,A)
%   UNIQUEFLATMAP('prop',A)
%
%   If f is a function handle, return
%       unique(flatten(map(f,A)))
%
%   If f is a character string, it is treated as a property or structure value
%       unique(flatten(map(@(x) x.(f), A)))
%
%   A can be either a cell or array, but the result of map(f,A) will always be
%   a cell (a cell-of-cells).  The function f does not need to return a cell --
%   see FLATTEN for details.
%
%   See UNIQUE for class support for the output of f.

if ischar(f)
    f = @(x) x.(f);
end

S = unique(flatten(map(f,A)));
