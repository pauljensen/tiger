function [tiger] = create_empty_tiger()

tiger.A = [];
tiger.d = [];
tiger.lb = [];
tiger.ub = [];
tiger.obj = [];

tiger.varnames = {};
tiger.rownames = {};

tiger.ctypes = '';
tiger.vartypes = '';

tiger.param.ind = 0;
