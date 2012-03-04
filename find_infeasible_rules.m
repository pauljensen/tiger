function [infeasible,side] = find_infeasible_rules(tiger,rules,varargin)
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
%   'display'   If true, display the infeasible rules.  (default = false)
%   'obj_frac'  Define a fraction of the objective value that must be
%               obtained when the rules are added for the model to be
%               declared feasible.  Default is 0.0.  It is also possible
%               add the objective constraint to TIGER before calling this
%               function (see ADD_GROWTH_CONSTRAINT).

p = inputParser;
p.addParamValue('display',false);
p.addParamValue('obj_frac',0);
p.parse(varargin{:});
show_rules = p.Results.display;
obj_frac = p.Results.obj_frac;

if nargin < 2 || isempty(rules)
    % use all previously added rules
    rules = tiger.param.rules;
    tiger = remove_rule(tiger,rules);
end

if obj_frac ~= 0
    tiger = add_growth_constraint(tiger,obj_frac);
end

N = length(rules);
exprs = parse_string(rules);

s_names = {};
s_rules = [];

for i = 1 : N
    if is_iff(exprs{i})
        exprs{i}.lexpr = append_s(exprs{i}.lexpr,'l');
    end
    exprs{i}.rexpr = append_s(exprs{i}.rexpr,'r');
end

model = add_rule(tiger,exprs);

loc = convert_ids(model.varnames,s_names,'index');
model.obj(:) = 0;
model.obj(loc) = 1;

sol = cmpi.solve_mip(model);
if isempty(sol.x)
    warning('Model cannot be made feasible.');
    infeasible = [];
    side = '';
    return;
elseif near(sol.val,0)
    showif(show_rules,'\n\nModel is feasible.\n\n');
    infeasible = [];
    side = '';
    return;
end 

state = logical(round(sol.x(loc)));
infeasible = s_rules(state);
side = cellfun(@(x) x(end),s_names(state));

if show_rules
    fprintf('\n\nInfeasible rules (#[side] rule):\n');
    for i = 1 : length(infeasible)
        idx = infeasible(i);
        if isa(rules{idx},'char')
            string = rules{idx};
        else
            string = expr_to_string(rules{idx});
        end
        fprintf('%5i[%s]  %s\n',idx,side(i),string);
    end
    fprintf('\n');
end

function [new] = append_s(e,side)
    s_name = sprintf('_s%i%s',i,side);
    s_names{end+1} = s_name;
    s_rules(end+1) = i;
    new = create_empty_expr_struct();
    new.op = 'or';
    new.lexpr = create_empty_expr_struct();
    new.lexpr.id = s_name;
    new.rexpr = e;
end

end
