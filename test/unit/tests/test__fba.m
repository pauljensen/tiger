
cobra_model
cmpi.init();
cmpi.set_solver('gurobi');

tiger = cobra_to_tiger(cobra);

wtsol = fba(tiger);
assert(near(wtsol.val,1),'original fba');

sol = fba(set_var(tiger,'g5a',0));
assert(near(sol.val),'g5a ko');

sol = fba(set_var(tiger,'g7a',0));
assert(near(sol.val,wtsol.val),'g7a ko');

sol = fba(set_var(tiger,{'g7a','g6'},0));
assert(near(sol.val),'g7a + g6 ko');
