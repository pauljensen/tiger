function [infeasible,side] = find_infeasible_rules(tiger,rules)
% FIND_INFEASIBLE_RULES  Determine which rules make a model infeasible.
%
%   [INFEASIBLE,SIDE] = FIND_INFEASIBLE_RULES(TIGER,RULES)
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
%   Outputs
%   INFEASIBLE  Array of indices corresponding to rules in RULES that are
%               not satisfiable in any feasible solution.
%   SIDE        Character array describing the side of the rule that was
%               infeasible.  'l' corresponds to the left side, 'r' is the
%               right side.

N = length(rules);
exprs = cell(1,N);
for i = 1 : N
    if isa(rules{i},'char')
        exprs{i} = parse_string(rules{i});
    else
        exprs{i} = rules{i};
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
[~,loc] = ismember(s_names,model.varnames);
model.obj(:) = 0;
model.obj(loc) = 1;

sol = cmpi.solve_milp(make_milp(model));
if isempty(sol.x)
    error('Model cannot be made feasible.');
    infeasible = [];
    side = '';
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
