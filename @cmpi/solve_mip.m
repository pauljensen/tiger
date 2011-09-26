function [sol] = solve_mip(mip)
% SOLVE_MIP  Solve a Mixed Integer Programming problem
%
%   [SOL] = SOLVE_MIP(MIP,SOLVER)
%
%   Solves the Mixed Integer Linear Programming problem
%       min sense*obj*x
%       subject to
%           A*x (<=/=/>=) b
%           lb <= x <= ub
%
%   or the Mixed Integer Quadratic Programming problem
%       min sense*(x'*Q*x + obj*x)
%       subject to
%           A*x (<=/=/>=) b
%           lb <= x <= ub
%
%   Inputs
%   MIP     Problem structure.  Fields include:
%               obj       Objective coefficients
%               sense     Direction of optimization:
%                              1    Minimization
%                             -1    Maximization
%               A         Coefficient matrix for constraints.
%               b         Right-hand side of constraints.
%               ctypes    Char array denoting the type of each constraint:
%                             '<'   a*x <= b
%                             '='   a*x == b
%                             '>'   a*x >= b
%               lb        Lower bound for each variable.
%               ub        Upper bound for each variable.
%               vartypes  Char array denoting the type of each variable:
%                             'C'   Continuous
%                             'B'   Binary
%                             'I'   Integer
%               options   Solver options (see below).  If not given, the
%                         options in the global variable CMPI_OPTIONS are
%                         used (if defined).
%                             MaxTime     Maximum solution time (seconds)
%                             MaxIter     Maximum simplex iterations
%                             MaxNodes    Maximum number of nodes
%                             Display     Turn reporting to the screen
%                                         'on' or 'off' (default)
%                             FeasTol     Feasibility tolerance
%                             IntFeasTol  Integer feasibility tolerance
%                             OptTol      Optimality tolerance
%                             AbsOptTol   Absolute optimality tolerance
%               Q         Quadratic objective matrix.  If given, the
%                         problem is solved as a MIQP.  See CONVERT_MIQP
%                         for details on Q and related fields.
%
%   Outputs
%   SOL     Solution structure with fields:
%               x       Optimal vector
%               val     Objective values (sense*c*x)
%               flag    Exit flag.  Possible values are:
%                           1   Not started
%                           2   Optimal
%                           3   Infeasible
%                           4   Infeasible or unbounded
%                           5   Unbounded
%                           6   Objective worse than user cutoff
%                           7   Iteration limit reached
%                           8   Node limit reached
%                           9   Time limit reached
%                           10  Solution limit reached
%                           11  User interruption
%                           12  Numerical difficulties
%                           13  Suboptimal solution
%               output  Other solver-specific output

solver = cmpi.get_solver();

if ~issparse(mip.A)
    mip.A = sparse(mip.A);
end

if ~isfield(mip,'sense') || isempty(mip.sense)
    mip.sense = 1;
end

if ~isfield(mip,'options') || isempty(mip.options)
    mip.options = cmpi.get_options();
end

% preserve size before conversion
N = size(mip.A,2);

mip = cmpi.convert_indicators(mip);

qp = ~isempty(cmpi.miqp_type(mip));

if qp
    mip = cmpi.convert_miqp(mip);
end

switch solver
    case 'gurobi'
        opts = cmpi.set_gurobi_opts(mip.options);
        if qp
            [opts.QP.qrow,opts.QP.qcol,opts.QP.qval] = find(mip.Q);
            opts.QP.qrow = int32(opts.QP.qrow(:)');
            opts.QP.qcol = int32(opts.QP.qcol(:)');
            opts.QP.qval = opts.QP.qval(:)';
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
                   
    case 'cplex'        
        opts = cmpi.set_cplex_opts(mip.options);
        
        mip.b = mip.b(:);
        mip.vartypes = upper(mip.vartypes);

        Aineq = [ mip.A(mip.ctypes == '<',:); 
                 -mip.A(mip.ctypes == '>',:)];
        bineq = [ mip.b(mip.ctypes == '<');
                 -mip.b(mip.ctypes == '>')];
             
        Aeq = mip.A(mip.ctypes == '=',:);
        beq = mip.b(mip.ctypes == '=');
        if qp
            [sol.x,sol.val,~,sol.output] = ...
                cplexmiqp(mip.sense.*mip.Q, ...
                          mip.sense.*mip.obj(:), ...
                          Aineq, bineq, ...
                          Aeq, beq, ...
                          [], [], [], ...
                          mip.lb(:), mip.ub(:), ...
                          mip.vartypes(:)', ...
                          [], ...
                          opts);
        else
            [sol.x,sol.val,~,sol.output] = ...
                cplexmilp(mip.sense*mip.obj(:), ...
                          Aineq, bineq, ...
                          Aeq, beq, ...
                          [], [], [], ...
                          mip.lb(:), mip.ub(:), ...
                          mip.vartypes(:)', ...
                          [], ...
                          opts);
        end

        sol.val = mip.sense*sol.val;
                   
        sol.flag = cmpi.get_cplex_flag(sol.output.cplexstatus);
        
    case 'glpk'
        % move equality bounds to A (problem with GLPK?)
        mip = cmpi.bounds_to_constraints(mip,'bounds','equal');
        
        opts = cmpi.set_glpk_opts(mip.options);
        
        mip.b = mip.b(:);
        if qp
            error('GLPK does not support MIQP problems.');
        end
        
        ctypes = mip.ctypes;
        ctypes(ctypes == '<') = 'U';
        ctypes(ctypes == '=') = 'S';
        ctypes(ctypes == '>') = 'L';
        
        if ~isempty(opts)
            [sol.x,sol.val,glpk_flag,sol.output] = ...
                glpk(mip.obj(:),mip.A,mip.b(:),mip.lb(:),mip.ub(:), ...
                     ctypes,upper(mip.vartypes),mip.sense,opts);
        else
            [sol.x,sol.val,glpk_flag,sol.output] = ...
                glpk(mip.obj(:),mip.A,mip.b(:),mip.lb(:),mip.ub(:), ...
                     ctypes,upper(mip.vartypes),mip.sense);
        end
         
        sol.flag = cmpi.get_glpk_flag(glpk_flag);
        
    otherwise
        error('Unrecognized solver: %s',solver);
end

% remove added variables
if ~isempty(sol.x)
    sol.x = sol.x(1:N);
end
    