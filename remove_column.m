function [tiger] = remove_column(tiger,col_ids)
% REMOVE_COLUMN  Remove column(s) from a TIGER model
%
%   [TIGER] = REMOVE_COLUMN(TIGER,COL_IDS)
%
%   Remove columns COL_IDS from a TIGER model and return the modified
%   structure.  COL_IDS are any valid IDs (see CONVERT_IDS).

ids = ~convert_ids(tiger.varnames,col_ids,'logical');

tiger.A = tiger.A(:,ids);
tiger.lb = tiger.lb(ids);
tiger.ub = tiger.ub(ids);

tiger.obj = tiger.obj(ids);

tiger.varnames = tiger.varnames(ids);
tiger.vartypes = tiger.vartypes(ids);

tiger.param.fixedvar = tiger.param.fixedvar(ids);

% update TIGER.ind
removed = find(~ids);
ind = tiger.ind;
for i = 1 : length(removed)
    ind(ind > removed(i)) = ind(ind > removed(i)) - 1;
end
tiger.ind = ind;
