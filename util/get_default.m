function [val] = get_default(struc,name,default)
% GET_DEFAULT  Get a field value with a default options.
%
%   [VAL] = GET_DEFAULT(STRUC,NAME,DEFAULT)
%
%   Returns STRUC.(NAME) if NAME is a fieldname in structure STRUC.
%   Otherwise, returns DEFAULT.  If DEFAULT is not given, it is set
%   to [].

if nargin == 2
    default = [];
end

if isfield(struc,name)
    val = struc.(name);
else
    val = default;
end