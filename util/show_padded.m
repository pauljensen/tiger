function [str] = show_padded(str1,str2,width,pad)
% SHOW_PADDED  Show padded strings
%
%   SHOW_PADDED(STR1,STR2,WIDTH,PAD)
%   [STR] = SHOW_PADDED(...)
%
%   Prints STR1 and STR2, separated by PAD, repeated enough times to give
%   an overall length of WIDTH.
%
%   If called with a return argument, the padded string is returned, not
%   printed.

if nargin < 4 || isempty(pad)
    pad = '.';
end
if nargin < 3 || isempty(width)
    width = 70;
end

assert(nargin >= 2, 'SHOW_PADDED requires two arguments');

pad_width = width - length(str1) - length(str2);
padding = repmat(pad,1,pad_width);

str = sprintf('%s%s%s',str1,padding,str2);
if nargout == 0
    fprintf('%s\n',str);
end

