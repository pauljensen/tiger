function [tiger] = bind_var(tiger,vars,inds,varargin)
% BIND_VAR  Bind variables to a indicator variable
%
%   [TIGER] = BIND_VAR(TIGER,VARS,INDS,...params...)
%
%   For each variable v in VARS and corresponding indicator I in INDS,
%   adds constraints such that v=0 if I=0.
%
%   If parameter 'iff' is true, the binding is such that v=0 if and only
%   if I=0.  ('iff' is false by default.)
%
%   The bounds used when adding these rules are determined by the
%   parameters:
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
p.addParamValue('iff',false);
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

assert(length(vars) == length(inds), ...
       'VARS and INDS must have the same length.');

% make sure we have names
[vars,var_idxs] = convert_ids(tiger.varnames,vars);
[inds,ind_idxs] = convert_ids(tiger.varnames,inds);

if p.Results.iff
    rules = cellzip(@(x,y) sprintf('"%s" ~= 0 <=> "%s"',x,y),vars,inds);

    if ~tight
        prev_lb = tiger.lb;
        prev_ub = tiger.ub;
        tiger.lb(var_idxs) = default_lb;
        tiger.ub(var_idxs) = default_ub;

        tiger = add_rule(tiger,rules);

        tiger.lb(1:length(prev_lb)) = prev_lb;
        tiger.ub(1:length(prev_ub)) = prev_ub;
    else
        tiger = add_rule(tiger,rules);
    end
else
    N = length(var_idxs);
    A = zeros(2*N,size(tiger.A,2));
    ctypes = repmat(' ',2*N,1);
    for i = 1 : N
        if tight
            A(  i,[var_idxs(i) ind_idxs(i)]) = [1 -tiger.ub(var_idxs(i))];
            A(i+N,[var_idxs(i) ind_idxs(i)]) = [1 -tiger.lb(var_idxs(i))];
        else
            A(  i,[var_idxs(i) ind_idxs(i)]) = [1 -default_ub];
            A(i+N,[var_idxs(i) ind_idxs(i)]) = [1 -default_lb];
        end
        ctypes(  i) = '<';
        ctypes(i+N) = '>';
    end
    
    tiger = add_row(tiger,A,ctypes);
end
