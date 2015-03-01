function tiger = add_inequalities(tiger,ineqs)

ineq_vars = [ineqs.vars];
Nineq = length(ineqs);
tiger = add_column(tiger,setdiff(ineq_vars,tiger.varnames),'b');

A = spalloc(Nineq,size(tiger.A,2),length(ineq_vars));
ctype = repmat(' ',Nineq,1);
b = zeros(Nineq,1);
for i = 1 : Nineq
    [~,loc] = ismember(ineqs(i).vars,tiger.varnames);
    A(i,loc) = ineqs(i).coeffs;
    ctype(i) = ineqs(i).op;
    b(i) = ineqs(i).rhs;
end

tiger = add_row(tiger,A,ctype,b);
