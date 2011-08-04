function [list] = struct2list(s)
% STRUCT2LIST  Convert a structure to a parameter list
%
%   [LIST] = STRUCT2LIST(S)
%
%   Example:
%   >> S.A = 1;
%   >> S.B = 'test';
%   >> struct2list(S)
%   ans = 
%       'A'   [1]   'B'   'test'

names = fieldnames(s);
Nnames = length(names);

list = cell(1,2*Nnames);
for i = 1 : Nnames
    list{2*(i-1)+1} = names{i};
    list{2*i} = s.(names{i});
end

