function [opts,cplex] = set_cplex_opts(options,cplex)
% SET_CPLEX_OPTS  Convert a CMPI options structure into CPLEX opts

if nargin > 1
    opts = [];
    
    if isfield(options,'MaxTime')
        cplex.Param.timelimit = options.MaxTime;
    end
    if isfield(options,'MaxIter')
        cplex.mip.limits.solutions = options.MaxIter;
    end
    if isfield(options,'MaxNodes')
        cplex.Param.mip.limits.nodes = options.MaxNodes;
    end
    if isfield(options,'FeasTol')
        cplex.Param.simplex.tolerances.feasibility = options.FeasTol;
    end
    if isfield(options,'IntFeasTol')
        cplex.Param.mip.tolerances.integrality = options.IntFeasTol;
    end
    if isfield(options,'OptTol')
        cplex.Param.mip.tolerances.mipgap = options.OptTol;
    end
else
    cplex = [];
    
    opts = cplexoptimset;
    setifdef('MaxTime','MaxTime');
    setifdef('MaxIter','MaxIter');
    setifdef('MaxNodes','MaxNodes');
    setifdef('FeasTol','EpRHS');
    setifdef('IntFeasTol','TolXInteger');
    setifdef('OptTol','TolFun');
    setifdef('Display','Diagnostics');
    if isfield(options,'Display') && strcmpi(options.Display,'on')
        opts.Display = 'iter';
    end
end
    
function setifdef(cmpifield,cplexfield)
    if isfield(options,cmpifield)
        opts.(cplexfield) = options.(cmpifield);
    end
end

end