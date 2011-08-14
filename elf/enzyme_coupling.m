function [sets] = enzyme_coupling(elf,varargin)

max_bound = max_abs(elf.lb,elf.ub);

p = inputParser;
p.addParamValue('vars',elf.genes);
p.addParamValue('open_bounds',true);
p.addParamValue('delta',0.01*max_bound);
p.parse(varargin{:});

open_bounds = p.Results.open_bounds;
delta = p.Results.delta;

vars = convert_ids(elf.varnames,p.Results.vars,'index');
N = length(vars);

if open_bounds
    elf.lb(:) = max_bound;
    elf.ub(:) = max_bound;
    
