function [sol] = run_solver(mip)

solver = cmpi.get_solver();
if isempty(solver)
    error('No solver selected.  Use set_solver() to choose a solver');
end

% support remote solver calls
if any(solver == '@')
    parts = splitstr(solver,'@');
    cmds = sprintf(['addpath(genpath(''/usr/local/tiger''));', ...
                    'start_tiger(''%s'');', ...
                    'sol=cmpi.solve_mip(mip);'], ...
                   parts{1});
    job_id = run_remote(cmds, ...
                        'server',parts{2}, ...
                        'send_workspace',true', ...
                        'background',false, ...
                        'send_files',false, ...
                        'load_return',true);
    sol = job_id.vars.sol;
    return;
end

switch solver
    case 'gurobi_mex'
        % Gurobi Mex interface; this is deprecated, use the native
        % Gurobi Matlab interface instead (Gurobi v. 5 or greater).
        
        % Gurobi does not like problems without constraints;
        % add a dummy constraint: x(1) <= ub(x(1))
        if nnz(mip.A) == 0
            mip = add_row(mip,[],'<',mip.ub(1));
            mip.A(end,1) = 1;
        end
        
        opts = cmpi.set_gurobi_opts(mip.options);
        if mip.param.qp
            [opts.QP.qrow,opts.QP.qcol,opts.QP.qval] = find(mip.Q);
            opts.QP.qrow = int32(opts.QP.qrow(:)' - 1);
            opts.QP.qcol = int32(opts.QP.qcol(:)' - 1);
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
                       upper(mip.vartypes), ...
                       opts);
    
    case 'gurobi'
        % Gurobi version 5 or later with native Matlab interface
        param = cmpi.set_gurobi_param(mip.options);
        
        % logging can be turned on for debugging by uncommenting the
        % following line
        %param.resultfile = 'gurobi.lp';
        
        mip.vtype = upper(mip.vartypes);
        mip.rhs = mip.b;
        if mip.sense == 1
            mip.modelsense = 'min';
        else
            mip.modelsense = 'max';
        end
        mip.sense = mip.ctypes;
        
        gsol = gurobi(mip,param);
        
        sol.val = get_default(gsol,'objval');
        sol.x = get_default(gsol,'x');
        sol.output = gsol.status;
        
        gurobi_status = {'LOADED','OPTIMAL','INFEASIBLE','INF_OR_UNBD', ...
                         'UNBOUNDED','CUTOFF','ITERATION_LIMIT', ...
                         'NODE_LIMIT','TIME_LIMIT','SOLUTION_LIMIT', ...
                         'INTERRUPTED','NUMERIC','SUBOPTIMAL'};
        [~,sol.flag] = ismember(gsol.status,gurobi_status);
                   
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
        if mip.param.qp
            [sol.x,sol.val,~,sol.output] = ...
                cplexmiqp(mip.sense.*(2*mip.Q), ...
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
        if mip.param.qp
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
if ~isempty(sol.x) && isfield(mip.param,'pre_mip_N')
    sol.x = sol.x(1:mip.param.pre_mip_N);
end
