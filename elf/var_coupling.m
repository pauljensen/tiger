function [sets] = var_coupling(model,vars)

MIN_VAR_TOL = 1e-5;
DELTA = 1;
VERBOSE = true;
LOGGING = true;
VERIFY = true;

vars = convert_ids(model.varnames,vars,'index');
nvars = length(vars);

sets = zeros(nvars);
coupled = false(1,nvars);

statbar = statusbar(nvars,VERBOSE);
statbar.start('Variable Coupling status');

for i = 1 : nvars
    if coupled(i)
        continue
    end
    
    model.obj(:) = 0;
    model.obj(vars(~coupled)) = 1;
    
    prev_lb = model.lb(vars(i));
    model.lb(vars(i)) = DELTA;
    sol = solve_tiger(model,'min');
    if ~isempty(sol.x)
        x = sol.x(vars);
        if count(x > MIN_VAR_TOL) > 1
            sets(i,:) = x' > MIN_VAR_TOL;
            if VERIFY
                for j = 1 : nvars
                    if x(j) <= MIN_VAR_TOL
                        continue
                    end
                    model.obj(:) = 0;
                    model.obj(vars(j)) = 1;
                    sol = solve_tiger(model,'min');
                    if ~isempty(sol.x) && sol.x(vars(j)) < MIN_VAR_TOL
                        sets(i,j) = 0;
                    end
                end
            end
        end
    end
    
    model.lb(vars(i)) = prev_lb;
    statbar.update(i);
end

sets = unique(sets(sum(sets,2) > 1,:),'rows');
