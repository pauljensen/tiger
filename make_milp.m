function [milp] = make_milp(tiger)
% MAKE_MILP  Convert a TIGER structure to a CMPI MILP.

milp.c = tiger.obj;
milp.A = tiger.A;
milp.b = tiger.d;

milp.lb = tiger.lb;
milp.ub = tiger.ub;

milp.ctypes = tiger.ctypes';
milp.vartypes = upper(tiger.vartypes');

milp.sense = 1;

milp.colnames = tiger.varnames;
milp.rownames = tiger.rownames;

