function [coupling] = enzyme_coupling(elf,varargin)

max_bound = max_abs(elf.lb,elf.ub);

p = inputParser;
p.addParamValue('vars',elf.genes);
p.addParamValue('open_bounds',true);
p.addParamValue('delta',0.1);
p.addParamValue('display',true);
p.addParamValue('no_minflux',true);
p.parse(varargin{:});

open_bounds = p.Results.open_bounds;
delta = p.Results.delta;

if p.Results.no_minflux
    elf.lb(elf.lb > 0) = 0;
end

vars = convert_ids(elf.varnames,p.Results.vars,'index');
Nvars = length(vars);

if open_bounds
    elf.lb = -max_bound .* (elf.lb < 0);
    elf.ub =  max_bound .* (elf.ub > 0);
end

[minact,maxact] = fast_fva(elf,'vars',vars,'frac',0);
minacts = zeros(Nvars);
maxacts = zeros(Nvars);

statbar = statusbar(Nvars,p.Results.display);
statbar.start('Finding coupled enzymes');
for i = 1 : Nvars
    fixed = set_var(elf,vars(i),minact(i)+delta*(maxact(i)-minact(i)));
    [minacts(i,:),maxacts(i,:)] = fast_fva(fixed,'vars',vars, ...
                                                 'frac',0, ...
                                                 'status',false);
    statbar.update(i);
end

coupling.minact = minact;
coupling.maxact = maxact;
coupling.minacts = minacts;
coupling.maxacts = maxacts;
