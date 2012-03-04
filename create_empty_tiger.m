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

tiger.ind = [];
tiger.indtypes = '';

tiger.param.ind = 0;
tiger.param.fixedvar = [];
tiger.param.rules = {};
tiger.param.rule_id = [];

tiger.bounds.var = [];
tiger.bounds.ind = [];
tiger.bounds.type = '';
