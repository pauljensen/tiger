function [milp] = make_milp(tiger)

milp.c = tiger.obj;
milp.A = tiger.A;
milp.b = tiger.d;

milp.lb = tiger.lb;
milp.ub = tiger.ub;

milp.ctypes = tiger.ctypes;
milp.vartypes = tiger.vartypes;

milp.sense = 1;

milp.colnames = tiger.varnames;
milp.rownames = tiger.rownames;
