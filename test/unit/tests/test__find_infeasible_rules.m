
cobra_model;
t = cobra_to_tiger(cobra);

rules = {'a <=> ~b','a <=> b'};

t2 = add_rule(t,rules);

[infeas,side] = find_infeasible_rules(t,rules,'obj_frac',0.3);
[infeas2,side2] = find_infeasible_rules(t2,[],'obj_frac',0.3);

assert(length(infeas) == 1 && length(side) == 1, ...
       'rules added');
assert(length(infeas2) == 1 && length(side) == 1, ...
       'rules implied');

clear cobra infeas infeas2 m n rules side side2 t t2
 