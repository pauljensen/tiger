function [mip] = convert_miqp(mip)
% CONVERT_MIQP  Prepare a MIQP for solution
%
%   [MIP] = CONVERT_MIQP(MIP)
%
%   Converts a general MIQP problem to standard form:
%       min sense*( x'*Q*x + obj*x )
%       subject to
%           A*x (<=/=/>=) b
%           lb <= x <= ub
%
%   General MIQP problems are defined by three fields:
%       Q     Matrix with standard quadratic weights for x'*Q*x.
%
%       Qd    If Qd(i,j) = k, then the objective entry is 
%             k*(x(i) - x(j))^2.  A difference variable d is added such
%             that d = (x(i) - x(j)), and the entry Q(d,d) = k.
%
%       Qc.w  If Qc.w(i) and Qc.c(i) are nonzero (Qc.w and Qc.c are 
%       Qc.c  vectors the same size as x), then the objective entry is
%             Qc.w(i)*(x(i) - Qc.c(i))^2, i.e., the weighted least-square
%             distance between x(i) and a constant c(i).

[m,n] = size(mip.A);

mip.Q = cmpi.check_field('Q',mip);
mip.Q = expand_to(mip.Q,[n n]);

Qd = cmpi.check_field('Qd',mip);
Qd = expand_to(Qd,[n n]);

Qc = cmpi.check_field('Qc',mip);
Qc.w = cmpi.check_field('w',Qc);
Qc.c = cmpi.check_field('c',Qc);
Qc.w = expand_to(Qc.w,n);
Qc.c = expand_to(Qc.c,n);

% move all nonzero elements in Q and Qd to the lower half
mip.Q  = tril(mip.Q) + triu(mip.Q)'.*double(tril(mip.Q) == 0);
Qd = tril(Qd) + triu(Qd)'.*double(tril(Qd) == 0);

[I,J,w] = find(Qd);
Nadd = length(w);
if Nadd > 0
    mip = add_column(mip,Nadd);
    mip = add_row(mip,Nadd);
    mip.Q = expand_to(mip.Q,n+Nadd);
    for i = 1 : Nadd
        mip.A(m+i,[I(i) J(i) n+i]) = [1 -1 1];
        mip.Q(n+i,n+i) = w(i);
    end
end

[m,n] = size(mip.A);
idxs = find(Qc.w);
Nadd = length(idxs);
if Nadd > 0
    mip = add_column(mip,Nadd);
    mip = add_row(mip,Nadd);
    mip.Q = expand_to(mip.Q,n+Nadd);
    for i = 1 : Nadd
        mip.A(m+i,[idxs(i) n+i]) = [1 -1];
        mip.b(m+i) = Qc.c(idxs(i));
        mip.Q(n+i,n+i) = Qc.w(idxs(i));
    end
end

% make Q symmetric
mip.Q = tril(mip.Q) + tril(mip.Q,-1)';

    