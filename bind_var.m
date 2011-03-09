function [tiger] = bind_var(tiger,vars,inds)

[~,vars,~] = convert_ids(tiger.varnames,vars);
[~,inds,~] = convert_ids(tiger.varnames,inds);

N = length(vars);

n = size(tiger.A,2);
A = sparse([],[],[],2*N,n,2*n);
rownames = cell(2*N,1);
d = zeros(2*N,1);
ctypes = [repmat('<',N,1); repmat('>',N,1)];

for i = 1 : N
    A(  i,[vars(i) inds(i)]) = [1 -tiger.ub(vars(i))];
    A(i+N,[vars(i) inds(i)]) = [1 -tiger.lb(vars(i))];
    rownames{i} = sprintf('BIND%i',i);
    rownames{i+N} = rownames{i};
end

tiger.A = [tiger.A; A];
tiger.d = [tiger.d; d];
tiger.rownames = [tiger.rownames; rownames];
tiger.ctypes = [tiger.ctypes; ctypes];

