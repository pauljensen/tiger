function [param] = set_gurobi_param(options)
% SET_GUROBI_PARAM  Convert a CMPI options structure into Gurobi params

if isempty(options)
    param = struct;
    return
else
    param = options;
end

if isfield(options,'MaxTime')
    param.timelimit = options.MaxTime;
end
if isfield(options,'MaxIter')
    param.iterationlimit = options.MaxIter;
end
if isfield(options,'MaxNodes')
    param.nodelimit = options.MaxNodes;
end
if isfield(options,'FeasTol')
    param.feasibilitytol = options.FeasTol;
end
if isfield(options,'IntFeasTol')
    param.intfeastol = trim_param(options.IntFeasTol,1e-9);
end
if isfield(options,'OptTol')
    param.mipgap = options.OptTol;
end
if isfield(options,'AbsOptTol')
    param.mipgapabs = options.AbsOptTol;
end
if isfield(options,'Display')
    if strcmp(options.Display,'off')
        param.outputflag = 0;
    else
        param.outputflag = 1;
    end
end

function [trimmed] = trim_param(val,floor)
    if val < floor
        trimmed = floor;
    else
        trimmed = val;
    end
end

end

