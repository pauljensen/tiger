
init_test

mip.obj = [-2 -6]';
mip.A = sparse([1 1; -1 2; 2 1]);
mip.b = [2;2;3];
mip.lb = [0 0]';
mip.ub = [100 100]';

mip.ctypes = '<<<';
mip.vartypes = 'cc';

mip.Q = [0.5 0; 0 1];

sol = cmpi.solve_mip(mip);
assert(near(sol.val,-8.333333),'MIQP Q obj val');

t = create_empty_tiger();
t = add_column(t,3,'c');
t = add_row(t,[1 1 1],'=',1);

t.Qc.w = [1 1 1];
t.Qc.c = [0.3 0.2 0.1];

sol = cmpi.solve_mip(t);
show_sol(t,sol);