
base_mets = add_rule(base,met_rules);
%base_mets = base;

base_mets.lb(1:1266) = cobra.lb;
base_mets.ub(1:1266) = cobra.ub;

wg = add_growth_constraint(base_mets,0.3);
%wg = set_var(wg,'glc[e]',1);



[infeas,side] = find_infeasible_rules(wg,exprs)

