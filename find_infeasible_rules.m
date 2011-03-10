function [infeasible] = find_infeasible_rules(tiger,rules)

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

state = logical(round(sol.x(loc)));
infeasible = s_rules(state);

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
