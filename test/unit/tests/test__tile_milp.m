
cobra_model;
tiger = cobra_to_tiger(cobra);

t1 = tiger;
t1 = set_var(t1,'r1',-0.3);
sol1 = fba(t1);

t2 = tiger;
t2 = set_var(t2,'r1',-0.2);
sol2 = fba(t2);

t3 = tiger;
t3 = set_var(t3,'r1',-0.4);
t3.obj = -1*t3.obj;
sol3 = fba(t3);

n = size(tiger.A,2);

milp = cmpi.tile_milp(t1,t2,t3);
sol = cmpi.solve_mip(milp);
val1 = t1.obj'*sol.x(1:n);
val2 = t2.obj'*sol.x(n+1:2*n);
val3 = t3.obj'*sol.x(2*n+1:3*n);

assert(near(sol1.val,val1),'model 1');
assert(near(sol2.val,val2),'model 2');
assert(near(sol3.val,val3),'model 3');

