function [tiger] = bind_var(tiger,vars,inds,varargin)
% BIND_VAR  Bind variables to a indicator variable
%
%   [TIGER] = BIND_VAR(TIGER,VARS,INDS,...params...)
%
%   For each variable v in VARS and corresponding indicator I in INDS,
%   adds constraints such that
%       LB*I <= v <= UB*I
%   Thus, if I=0, v must equal 0.  The values LB and UB are given by the
%   following parameters:
%       (default)  LB = min(TIGER.lb), i.e. the lowest lower bound in the
%                  entire model.  UB = max(TIGER.ub), the largest upper
%                  bound in the model.
%       'tight'    If true, the upper and lower bounds for v are used.
%                  This may be more numerically stable, but can add
%                  complications if the variable bounds are changed later,
%                  as these changes will not be reflected in the binding
%                  constraints.
%       'lb','ub'  Number specifying LB and UB; these are used for every
%                  variable.

p = inputParser;
p.addParamValue('tight',false);
p.addParamValue('lb',[]);
p.addParamValue('ub',[]);
p.parse(varargin{:});

tight = p.Results.tight;
default_lb = p.Results.lb;
default_ub = p.Results.ub;
if isempty(default_lb)
    default_lb = min(tiger.lb);
end
if isempty(default_ub)
    default_ub = max(tiger.ub);
end

[~,vars,~] = convert_ids(tiger.varnames,vars);
[~,inds,~] = convert_ids(tiger.varnames,inds);

N = length(vars);

n = size(tiger.A,2);
A = sparse([],[],[],2*N,n,2*n);
rownames = cell(2*N,1);
b = zeros(2*N,1);
ctypes = [repmat('<',N,1); repmat('>',N,1)];

for i = 1 : N
    if tight
        ub = tiger.ub(vars(i));
        lb = tiger.lb(vars(i));
    else
        lb = default_lb;
        ub = default_ub;
    end
    A(  i,[vars(i) inds(i)]) = [1 -ub];
    A(i+N,[vars(i) inds(i)]) = [1 -lb];
    rownames{i} = sprintf('BIND%i',i);
    rownames{i+N} = rownames{i};
end

tiger.A = [tiger.A; A];
tiger.b = [tiger.b; b];
tiger.rownames = [tiger.rownames; rownames];
tiger.ctypes = [tiger.ctypes; ctypes];

