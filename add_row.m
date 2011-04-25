function [tiger] = add_row(tiger,A,ctype,b,name,ind,indtype)
% ADD_ROW  Add a row to a TIGER model structure
%
%   [TIGER] = ADD_ROW(TIGER,N)
%   [TIGER] = ADD_ROW(TIGER,A,CTYPE,B,NAME,IND,INDTYPE)
%
%   Add a row to an existing structure, updating the corresponding 
%   vectors.  The following default values are used:
%       A        row of zeros
%       CTYPE    '='
%       B        0
%       NAME     'ROWi', where i is the row index
%       IND      0
%       INDTYPE  ' '
%
%   If called as ADD_ROW(TIGER,N), N rows are added with the default
%   values.  If only a single value is given for each argument, it will
%   be repeated for all new rows.

[m,n] = size(tiger.A);
loc = m+1;

if nargin < 2 || isempty(A)
    A = [];
elseif length(A) == 1
    A = zeros(A,n);
end

if nargin < 3 || isempty(ctype), ctype = '='; end

if nargin < 4 || isempty(b), b = 0; end

if nargin < 5 || isempty(name)
    name = {};
elseif isa(name,'char')
    name = {name};
end

if nargin < 6 || isempty(ind), ind = 0; end

if nargin < 7 || isempty(indtype), indtype = ' '; end

N = max([length(name),  ...
         length(ctype), ...
         length(b),     ...
         size(A,1),     ...
         length(ind),   ...
         length(indtype)]);

A = expand_to(A,[N n]);
ctype = fill_to(ctype,N);
b = fill_to(b,N);
ind = fill_to(ind,N);
indtype = fill_to(indtype,N);
if length(name) < N
    if length(name) == 1
        name = array2names(name{1},loc:loc+N-1);
    else
        name = array2names('ROW%i',loc:loc+N-1);
    end
end

locs = loc + (0:N-1);

tiger.A(locs,:) = A;
tiger.ctypes(locs) = ctype;
tiger.b(locs) = b;
tiger.rownames(locs) = name;
tiger.ind(locs) = ind;
tiger.indtypes(locs) = indtype;

tiger = check_tiger(tiger);
