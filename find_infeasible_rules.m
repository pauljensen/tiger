function [infeasible,side] = find_infeasible_rules(tiger,rules)
% FIND_INFEASIBLE_RULES  Determine which rules make a model infeasible.
%
%   [INFEASIBLE,SIDE] = FIND_INFEASIBLE_RULES(TIGER,RULES,...params...)
%
%   Find a minimal set of rules which cannot be satisfied when finding a
%   feasible solution.  Reports which rules are not feasible and which 
%   side of the rule is not satisfiable.
%
%   Inputs
%   TIGER   TIGER model structure
%   RULES   Cell of strings or EXPR objects containing rules to test.
%           These rules should not have been previously added to the TIGER
%           model.
%
%           If RULES is empty or the functions is called with only one
%           argument, all previously added rules are removed from the 
%           model and used in the infeasibility calculation.  The indices
%           returned in INFEASIBLE reference the cell TIGER.param.rules.
%
%   Outputs
%   INFEASIBLE  Array of indices corresponding to rules in RULES that are
%               not satisfiable in any feasible solution.
%   SIDE        Character array describing the side of the rule that was
%               infeasible.  'l' corresponds to the left side, 'r' is the
%               right side.
%
%   Parameters
%   'display'   If true (default), display the infeasible rules.

if nargin < 3 || isempty(indicators)
    indicators = false;
end

N = length(rules);
exprs = cell(1,N);
for i = 1 : N
    if isa(rules{i},'char')
        exprs{i} = parse_string(rules{i});
    else
        exprs{i} = rules{i}.copy;
    end
end

s_names = {};
s_rules = [];

for i = 1 : N
    if exprs{i}.IFF
        exprs{i}.lexpr = append_s(exprs{i}.lexpr,'l');
    end
    exprs{i}.rexpr = append_s(exprs{i}.rexpr,'r');
end

model = add_rule(tiger,exprs);

% indicators
if indicators
    ind_rows = find(model.ind);
    ind_inds = model.ind(ind_rows);
    and_vars = array2names('inf_ind_AND[%i]',ind_inds);
    or_vars  = array2names('inf_ind_OR[%i]',ind_inds);
    sub_vars = arary2names('inf_ind_SUB[%i]',ind_inds);
end 

[~,loc] = ismember(s_names,model.varnames);
model.obj(:) = 0;
model.obj(loc) = 1;

sol = cmpi.solve_mip(make_milp(model));
if isempty(sol.x)
    warning('Model cannot be made feasible.');
    infeasible = [];
    side = '';
    return;
end

state = logical(round(sol.x(loc)));
infeasible = s_rules(state);
side = map(@(x) x(end),s_names(state));

function [new] = append_s(e,side)
    s_name = sprintf('_s%i%s',i,side);
    s_names{end+1} = s_name;
    s_rules(end+1) = i;
    new = expr();
    new.OR = true;
    new.lexpr = expr();
    new.lexpr.id = s_name;
    new.rexpr = e;
end

end
