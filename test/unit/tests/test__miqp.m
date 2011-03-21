
init_test

mip.obj = [-2 -6]';
mip.A = sparse([1 1; -1 2; 2 1]);
mip.b = [2;2;3];
mip.lb = [0 0]';
mip.ub = [100 100]';

mip.ctypes = '<<<';
mip.vartypes = 'cc';

mip.Q = [0.5 0; 0 1];

cmpi.solve_mip(mip);