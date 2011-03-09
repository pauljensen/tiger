function [tiger] = bind_var(tiger,vars,inds,varargin)

p = inputParser;
p.addParamValue('tight',false);
p.addParamValue('lb',[]);
p.addParamValue('ub',[]);
p.parse(varargin{:});

tight = p.Results.tight;
default_lb = p.Results.lb;
default_ub = p.Results.ub;
if isempty(default_lb)
    default_lb = min(tiger.lb);
end
if isempty(default_ub)
    default_ub = max(tiger.ub);
end

[~,vars,~] = convert_ids(tiger.varnames,vars);
[~,inds,~] = convert_ids(tiger.varnames,inds);

N = length(vars);

n = size(tiger.A,2);
A = sparse([],[],[],2*N,n,2*n);
rownames = cell(2*N,1);
d = zeros(2*N,1);
ctypes = [repmat('<',N,1); repmat('>',N,1)];

for i = 1 : N
    if tight
        ub = tiger.ub(vars(i));
        lb = tiger.lb(vars(i));
    else
        lb = default_lb;
        ub = default_ub;
    end
    A(  i,[vars(i) inds(i)]) = [1 -ub];
    A(i+N,[vars(i) inds(i)]) = [1 -lb];
    rownames{i} = sprintf('BIND%i',i);
    rownames{i+N} = rownames{i};
end

tiger.A = [tiger.A; A];
tiger.d = [tiger.d; d];
tiger.rownames = [tiger.rownames; rownames];
tiger.ctypes = [tiger.ctypes; ctypes];

