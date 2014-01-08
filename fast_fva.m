function [minflux,maxflux] = fast_fva(tiger,varargin)

p = inputParser;
p.addParamValue('vars',1:size(tiger.S,2));
p.addParamValue('frac',1.0);
p.addParamValue('status',true);
p.addParamValue('group_solve_maxtime',1);
p.addParamValue('single_solve_maxtime',1e5);
p.parse(varargin{:});

vars = convert_ids(tiger.varnames,p.Results.vars,'index');
frac = p.Results.frac;
status = p.Results.status;

global group_solve_maxtime single_solve_maxtime

group_solve_maxtime = p.Results.group_solve_maxtime;
single_solve_maxtime = p.Results.single_solve_maxtime;

nvars = length(vars);

if frac > 0
    tiger = add_growth_constraint(tiger,frac);
end

statbar = statusbar(2*nvars,status);
statbar.start('Flux Variability status');

tiger.sense = -1;
maxflux = fva_aux(tiger,vars,tiger.ub,statbar);
tiger.sense =  1;
minflux = fva_aux(tiger,vars,tiger.lb,statbar);

function [range] = fva_aux(model,vars,bounds,statbar)
    global group_solve_maxtime single_solve_maxtime
    TOL = 1e-5;
    range = bounds(vars);

    fixed = false(size(vars));
    set_solver_option('MaxTime',group_solve_maxtime);
    while (1)
        idxs = vars(~fixed);
        model.obj(:) = 0;
        model.obj(idxs) = 1;
        
        sol = solve_tiger(model);
        
        new_fixed = fixed;
        new_fixed(~fixed) = abs(sol.x(idxs) - bounds(idxs)) <= TOL;
        
        statbar.increment(count(new_fixed) - count(fixed));
        no_change = all(new_fixed == fixed);
        fixed = new_fixed;
        if no_change
            break
        end
    end
    
    set_solver_option('MaxTime',single_solve_maxtime);
    for i = 1 : length(vars)
        if fixed(i)
            continue
        end
        model.obj(:) = 0;
        model.obj(vars(i)) = 1;
        sol = solve_tiger(model);
        range(i) = sol.x(vars(i));
        statbar.increment(1);
    end
    