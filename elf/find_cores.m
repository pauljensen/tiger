function [cores] = find_cores(elf,varargin)

FLUX_EPS = 1e-5;
GROUP_SOLVE_MAXTIME = 1;
SINGLE_SOLVE_MAXTIME = 1e5;

solver_calls = 0;

max_bound = max_abs(elf.lb,elf.ub);

p = inputParser;
p.addParamValue('vars',elf.genes);
p.addParamValue('open_bounds',true);
p.addParamValue('delta',0.01*max_bound);
p.addParamValue('display',false);
p.parse(varargin{:});

open_bounds = p.Results.open_bounds;
delta = p.Results.delta;

vars = convert_ids(elf.varnames,p.Results.vars,'index');
Nvars = length(vars);

in_cores = false(1,Nvars);
cores = [];

if open_bounds
    elf.lb = -max_bound .* (elf.lb < 0);
    elf.ub =  max_bound .* (elf.ub > 0);
end

statbar = statusbar(Nvars,p.Results.display);
statbar.start('Finding coupled enzymes');
for curr_var = 1 : Nvars
    next_row = find_corr_row(elf,get_cands(vars));
    update_cores(next_row);
    statbar.update(curr_var);
end

if p.Results.display
    fprintf('\n\nMIP Solver calls:  %i\n\n',solver_calls);
end

function [row] = find_corr_row(mip,cands)
    cmpi.set_option('MaxTime',GROUP_SOLVE_MAXTIME);
    row = zeros(1,Nvars);
    new_cands = cands;
    while 1
        old_cands = new_cands;
        up_cands = sim_aux(old_cands,-1);
        dn_cands = sim_aux(new_cands, 1);
        new_cands = unique([up_cands; dn_cands]);
        if all(ismember(old_cands,new_cands))
            break;
        end
    end
    
    cmpi.set_option('MaxTime',SINGLE_SOLVE_MAXTIME);
    for j = 1 : length(new_cands)
        if j == curr_var
            continue;
        end
        [~,loc] = ismember(new_cands(j),vars);
        row(loc) =     ~isempty(sim_aux(new_cands,-1))  ...
                    || ~isempty(sim_aux(new_cands, 1));
    end
    row(curr_var) = 1;
    
    function [remain] = sim_aux(idxs,sgn)
        if sgn == -1
            mip.ub(vars(curr_var)) = 0;
        else
            mip.lb(vars(curr_var)) = delta;
        end
        
        mip.obj(:) = 0;
        mip.obj(idxs) = sgn;
        sol = cmpi.solve_mip(mip);
        solver_calls = solver_calls + 1;
        
        remain = [];
        if sgn == -1 && ~isempty(sol.x)
            remain = idxs(abs(sol.x(idxs)) < FLUX_EPS);
        elseif ~isempty(sol.x)
            remain = idxs(abs(sol.x(idxs)) > FLUX_EPS);
        end
        
        if sgn == -1
            mip.ub(vars(curr_var)) = elf.ub(vars(curr_var));
        else
            mip.lb(vars(curr_var)) = 0;
        end
    end
end

function [curr] = get_cands(cands)
    remove = false(1,Nvars);
    remove(in_cores) = true;
    for i = 1 : size(cores,1)
        remove = remove | cores(i,:);
        remove(find(cores(i,:),1)) = false;
    end
    curr = cands(~remove);
end

function update_cores(row)
    if isempty(cores)
        cores = row;
        in_cores = row > 0;
        return;
    end
    
    Ncores = size(cores,1);
    in_cores = sum(cores,1) > 0;

    if all((row & ~in_cores) == row)
        cores(end+1,:) = row;
        in_cores = in_cores | row;
        return;
    end

    for i = 1 : Ncores
        if any(cores(i,:) & row)
            cores(i,:) = cores(i,:) | row;
        end
    end

    while 1
        colsums = sum(cores,1);
        col = find(colsums > 1,1);
        if isempty(col)
            break;
        end

        rows = find(cores(:,col));
        for i = 2 : length(rows)
            cores(rows(1),:) = cores(rows(1),:) | cores(rows(i),:);
            cores(rows(i),:) = 0;
        end
    end

    cores = cores(sum(cores,2) > 0,:);
    in_cores = sum(cores,1) > 0;
end

end