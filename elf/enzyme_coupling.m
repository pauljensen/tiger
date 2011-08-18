function [sets_dn,sets_up] = enzyme_coupling(elf,varargin)

FLUX_EPS = 1e-5;

PRE_PROCESS_VARS = true;

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
N = length(vars);

if open_bounds
    elf.lb = -max_bound .* (elf.lb < 0);
    elf.ub =  max_bound .* (elf.ub > 0);
end

model_dn = elf;
model_up = elf;
model_dn.lb(vars) = 0;
model_up.lb(vars) = 0;

data_dn = zeros(N);
data_up = zeros(N);

statbar = statusbar(N,p.Results.display);
statbar.start('Finding coupled enzymes');
for i = 1 : N
    model_dn.ub(vars(i)) = 0;
    model_up.lb(vars(i)) = delta;
    
    data_dn(i,:) = run_sim(model_dn,-1);
    data_up(i,:) = run_sim(model_up, 1);
    
    % reset bounds
    model_dn.ub(vars(i)) = elf.ub(vars(i));
    model_up.lb(vars(i)) = 0;
    
    statbar.update(i);
end

sets_dn = data_dn | eye(N);
sets_up = data_up | eye(N);

if nargout == 1;
    sets_dn = sets_dn | sets_up;
end


function [corr_row] = run_sim(mip,sgn)
    corr_row = zeros(size(vars));
    
    old_cands = [];
    new_cands = vars;
    if PRE_PROCESS_VARS
        new_cands = pre_process(vars);
    end
    while 1
        old_cands = new_cands;
        new_cands = sim_aux(old_cands);
        if all(ismember(old_cands,new_cands))
            break;
        end
    end
    
    for j = 1 : length(new_cands)
        [~,idx] = ismember(new_cands(j),vars);
        corr_row(idx) = ~isempty(sim_aux(new_cands(j)));
    end

    function [remain] = sim_aux(cands)
        mip.obj(:) = 0;
        mip.obj(cands) = sgn;
        sol = cmpi.solve_mip(mip);
        solver_calls = solver_calls + 1;
        if isempty(sol.x)
            remain = [];
            return;
        end
        if sgn == -1
            remain = cands(abs(sol.x(cands)) < FLUX_EPS);
        else
            remain = cands(abs(sol.x(cands)) > FLUX_EPS);
        end
    end
end

function [nocorr] = pre_process(cands)
    cands = cands(cands > i);
    prev_sets = data_dn(1:i,:) | data_up(1:i,:);
    include = true(size(cands));
    for j = 1 : length(cands)
        [~,jloc] = ismember(cands(j),vars);
        include(j) = ~any(prev_sets(:,i) & prev_sets(:,jloc));
    end
    nocorr = cands(include);
end

end

