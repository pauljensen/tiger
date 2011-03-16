function [tiger] = set_var(tiger,id,lb,ub)
% SET_VAR  Set bounds on a variable
%
%   [TIGER] = SET_VAR(TIGER,ID,VAL)
%   [TIGER] = SET_VAR(TIGER,ID,LB,UB)
%
%   Sets the bounds on variables in a TIGER model, returning the modified
%   model structure.  ID can be any ids accepted by CONVERT_IDS.  The
%   following calling formats are allowed:
%
%       SET_VAR(TIGER,ID,VAL)
%           Sets upper and lower bounds to VAL.
%       SET_VAR(TIGER,ID,LB,UB)
%           Sets lower bound to LB, upper bound to UB.
%       SET_VAR(TIGER,ID,[],UB)
%           Sets upper bound to UB; lower bound is unchanged.
%       SET_VAR(TIGER,ID,LB,[])
%           Sets lower bound to LB; upper bound is unchanged.
%
%   If multiple IDS are given but only a single value is specified for LB
%   or UB, this value is repeated.

assert(nargin > 2, 'At least three arguments required.');

if nargin == 3
    ub = lb;
end

if ~isempty(lb)
    tiger = set_fieldval(tiger,'lb',id,lb);
end
if ~isempty(ub)
    tiger = set_fieldval(tiger,'ub',id,ub);
end
