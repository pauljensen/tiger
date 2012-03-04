function [mip] = convert_var_bindings(mip)

var = mip.bounds.var;
ind = mip.bounds.ind;
type = mip.bounds.type;

constraints = ones(size(type));
constraints(type == 'b') = 2;
n_constraints = sum(constraints);

row = size(mip.A,1);
mip = add_row(mip,n_constraints);

for i = 1 : length(var)
    if type(i) == 'u' || type(i) == 'b'
        row = row + 1;
        mip.A(row,[var(i) ind(i)]) = [1 -mip.ub(var(i))];
        mip.ctypes(row) = '<';
    end
    if type(i) == 'l' || type(i) == 'b'
        row = row + 1;
        mip.A(row,[var(i) ind(i)]) = [1 -mip.lb(var(i))];
        mip.ctypes(row) = '>';
    end
end
