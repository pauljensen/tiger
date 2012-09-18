function [sets,cor,fluxes] = mc_coupling(model,varargin)

p = inputParser;
p.addParamValue('vars',model.genes);
p.addParamValue('open_bounds',true);
p.addParamValue('display',false);
p.addParamValue('no_minflux',true);
p.addParamValue('sampling_max_time',100);
p.addParamValue('samples',100);
p.addParamValue('corr_thresh',0.99);
p.addParamValue('logfile',[]);
p.addParamValue('return_all_vars',false);
p.parse(varargin{:});

set_solver_option('MaxTime',p.Results.sampling_max_time);

open_bounds = p.Results.open_bounds;

if p.Results.no_minflux
    model.lb(model.lb > 0) = 0;
end

max_bound = max_abs(model.lb,model.ub);
if open_bounds
    model.lb = -max_bound .* (model.lb < 0);
    model.ub =  max_bound .* (model.ub > 0);
end

n_samples = p.Results.samples;
fluxes = sample_vars(model,p.Results.vars,'samples',n_samples, ...
                     'return_all_vars',p.Results.return_all_vars);

if p.Results.return_all_vars
    vars = convert_ids(model.varnames,p.Results.vars,'index');
    samples = fluxes(:,vars);
else
    samples = fluxes;
end

cor = correlation(samples);

linked = cor > p.Results.corr_thresh;
sets = find_sets(linked);

