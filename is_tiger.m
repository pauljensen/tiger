function [tf] = is_tiger(model)
% IS_TIGER  Returns true if a structure is a TIGER model.

fields = {'A','b','vartypes','ctypes','rownames','varnames','obj'};
tf = isstruct(model) && all(isfield(model,fields));
