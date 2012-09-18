function [sets,Rmin,Rmax] = flux_coupling_finder(model,vars)

MIN_FLUX_TOL = 1e-5;
VERBOSE = true;

vars = convert_ids(model.varnames,vars,'index');
nvars = length(vars);

Rmin = -ones(nvars);
Rmax = -ones(nvars);

max_bound = max(model.ub(vars));

sets = zeros(nvars);
coupled = false(1,nvars);

statbar = statusbar(nvars,VERBOSE);
statbar.start('Flux Coupling status');
for i = 1 : nvars-1
    if coupled(i)
        continue
    end
    model.obj(:) = 0;
    model.obj(vars(i)) = 1;
    for j = i+1 : nvars
        model.ub(vars(j)) = 1;
        
        sol = solve_tiger(model,'min');
        if ~isempty(sol.x)
            Rmin(i,j) = sol.val;
        end
        
        sol = solve_tiger(model,'max');
        if ~isempty(sol.x)
            Rmax(i,j) = sol.val;
        end
        
        model.ub(vars(j)) = max_bound;
        
        if Rmin(i,j) > MIN_FLUX_TOL && Rmax(i,j) > MIN_FLUX_TOL
            sets(i,i) = 1;
            sets(i,j) = 1;
            coupled(j) = true;
        end
    end
    statbar.update(i);
end
statbar.update(nvars);

sets = sets(sum(sets,2) > 0,:);
