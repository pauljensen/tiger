function [tiger] = create_empty_tiger()
% CREATE_EMPTY_TIGER  Create an empty TIGER model structure.

tiger.A = [];
tiger.b = [];
tiger.lb = [];
tiger.ub = [];
tiger.obj = [];

tiger.varnames = {};
tiger.rownames = {};

tiger.ctypes = '';
tiger.vartypes = '';

tiger.param.ind = 0;
