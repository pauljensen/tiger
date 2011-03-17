function [sol] = solve_mip(mip)

solver = cmpi.get_solver();

if ~issparse(milp.A)
    mip.A = sparse(milp.A);
end

if ~isfield(milp,'options')
    mip.options = cmpi.get_options();
end

% preserve size before conversion
N = size(mip.A,2);

mip = cmpi.convert_indicators(mip);

quad =    isfield(mip,'Q')  && ~isempty(mip.Q)  ...
       || isfield(mip,'Qd') && ~isempty(mip.Qd) ...
       || isfield(mip,'Qc') && ~isempty(mip.Qc);
   
if quad
    mip = cmpi.convert_miqp(mip);
end

switch solver
    case 'gurobi'
        opts = mip.options;
        if quad
            [opts.QP.qrow,opts.QP.qcol,opts.QP.qval] = find(mip.Q);
        end
        [sol.x,sol.val,sol.flag,sol.output] = ...
            gurobi_mex(mip.obj, ...
                       mip.sense, ...
                       mip.A, ...
                       mip.b, ...
                       mip.ctypes, ...
                       mip.lb, ...
                       mip.ub, ...
                       mip.vartypes, ...
                       opts);
    otherwise
        error('Unrecognized solver: %s',solver);
end

% remove added variables
sol.x = sol.x(1:N);