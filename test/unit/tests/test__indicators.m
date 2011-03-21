
init_test

cobra_model

tiger = cobra_to_tiger(cobra);
fba(tiger)

t = add_rule(tiger,'r1 < -0.5 => not g5a');
sol = fba(t)