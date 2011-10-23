function [opts] = set_gurobi_opts(options)
% SET_GUROBI_OPTS  Convert a CMPI options structure into GUROBI opts

if isfield(options,'MaxTime')
    opts.TimeLimit = options.MaxTime;
end
if isfield(options,'MaxIter')
    opts.IterationLimit = options.MaxIter;
end
if isfield(options,'MaxNodes')
    opts.NodeLimit = options.MaxNodes;
end
if isfield(options,'FeasTol')
    opts.FeasibilityTol = options.FeasTol;
end
if isfield(options,'IntFeasTol')
    % respect the Gurobi minimim
    opts.IntFeasTol = max([options.IntFeasTol,1e-09]);
end
if isfield(options,'OptTol')
    opts.OptimalityTol = options.OptTol;
end
if isfield(options,'AbsOptTol')
    opts.MIPGapAbs = options.AbsOptTol;
end

if isfield(options,'Display') && strcmpi(options.Display,'on')
    opts.DisplayInterval = 5;
    opts.OutputFlag = 1;
    opts.Display = 2;
else
    opts.DisplayInterval = 0;
    opts.OutputFlag = 0;
    opts.Display = 0;
end
