
cobra_model

tiger = cobra_to_tiger(cobra);
sol1 = fba(tiger);

t = add_rule(tiger,'r1 < -0.5 <=> not g5a');
sol2 = fba(t);

assert(near(sol2.val,0.5),'indicator did not work');

clear cobra m n sol1 sol2 t tiger
