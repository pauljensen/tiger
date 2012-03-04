function [tiger] = add_binding(tiger,var,ind,type)

if nargin < 4
    type = 'b';
end

var = convert_ids(tiger.varnames,var,'index');
ind = convert_ids(tiger.varnames,ind,'index');

tiger.bounds.var = [tiger.bounds.var; var(:)];
tiger.bounds.ind = [tiger.bounds.ind; ind(:)];
tiger.bounds.type = [tiger.bounds.type; type(:)];
