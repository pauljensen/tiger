function [tiger] = add_column(tiger,name,vartype,lb,ub,obj,A)
% ADD_COLUMN  Add a column to a TIGER model structure
%
%   [TIGER] = ADD_COLUMN(TIGER,N)
%   [TIGER] = ADD_COLUMN(TIGER,NAME,CTYPE,LB,UB,OBJ,A)
%
%   Add a column to an existing structure, updating the corresponding
%   vectors.  The following default values are used:
%       NAME     'VARi', where i is the column index
%       VARTYPE  'b'
%       LB       0
%       UB       1
%       OBJ      0
%       A        column of zeros
%
%   If called as ADD_COLUMN(TIGER,N), N columns are added with the default
%   values.  More than one name can be given; if only a single value is
%   given for the other arguments, it will be repeated for all new 
%   columns.

[m,n] = size(tiger.A);
loc = n+1;

if nargin < 2 || isempty(name)
    name = sprintf('VAR%i',loc);
elseif isa(name,'double')
    name = array2names('VAR%i',loc:loc+name-1);
end
name = assert_cell(name);
N = length(name);

if nargin < 3 || isempty(vartype)
    vartype = 'b';
end
vartype = fill_to(vartype,N);

if nargin < 4 || isempty(lb)
    lb = 0;
end
lb = fill_to(lb,N);

if nargin < 5 || isempty(ub)
    ub = 1;
end
ub = fill_to(ub,N);

if nargin < 6 || isempty(obj)
    obj = 0;
end
obj = fill_to(obj,N);

if nargin < 7 || isempty(A)
    A = zeros(m,N);
end

locs = loc + (1:N);

tiger.varnames(locs) = name;
tiger.vartypes(locs) = vartype;
tiger.lb(locs) = lb;
tiger.ub(locs) = ub;
tiger.obj(locs) = obj;
tiger.A(:,locs) = A;

