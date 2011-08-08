function [tiger,varname] = add_column(tiger,name,vartype,lb,ub,obj,A)
% ADD_COLUMN  Add a column to a TIGER model structure
%
%   [TIGER,VARNAME] = ADD_COLUMN(TIGER,N)
%   [TIGER,VARNAME] = ADD_COLUMN(TIGER,NAME,VARTYPE,LB,UB,OBJ,A)
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
%
%   The return value VARNAME is the name(s) of the columns added.

[m,n] = size(tiger.A);
loc = n+1;

if nargin < 2 || isempty(name)
    name = {};
elseif isa(name,'double')
    name = zeros(1,name);  % holder until filled after calculating N
elseif isa(name,'char')
    name = {name};
end

if nargin < 3 || isempty(vartype), vartype = 'b'; end

if nargin < 4 || isempty(lb), lb = 0; end

if nargin < 5 || isempty(ub), ub = 1; end

if nargin < 6 || isempty(obj), obj = 0; end

if nargin < 7 || isempty(A), A = [];  end

N = max([length(name), ...
         length(lb),   ...
         length(ub),   ...
         length(obj),  ...
         size(A,2),    ...
         length(vartype)]);
         
if length(name) < N || isa(name,'double')
    % TODO:  add to names instead of replace
    name = array2names('VAR%i',loc:loc+N-1);
end
vartype = fill_to(vartype,N);
lb = fill_to(lb,N);
ub = fill_to(ub,N);
obj = fill_to(obj,N);
A = expand_to(A,[m N]);

locs = loc : loc + N-1;

tiger.varnames(locs) = name;
tiger.vartypes(locs) = vartype;
tiger.lb(locs) = lb;
tiger.ub(locs) = ub;
tiger.obj(locs) = obj;
tiger.A(:,locs) = A;

% expand the Q, Qd, and Qc fields
if isfield(tiger,'Q') && ~isempty(tiger.Q)
    tiger.Q(n+N,n+N) = 0;
end
if isfield(tiger,'Qd') && ~isempty(tiger.Qd)
    tiger.Qd(n+N,n+N) = 0;
end
if isfield(tiger,'Qc') && ~isempty(tiger.Qc)
    tiger.Qc.w(n+N) = 0;
    tiger.Qc.c(n+N) = 0;
end 

tiger.param.fixedvar(end+(1:N)) = false;

tiger = check_tiger(tiger);

if nargout > 1
    varname = name;
end



