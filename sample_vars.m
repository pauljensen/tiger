function [vars,xs,samples] = sample_vars(model,vars,varargin)

p = inputParser;
p.addParamValue('samples',100);
p.addParamValue('seed',1985);
p.addParamValue('status',true);
p.addParamValue('use_fva_scaling',true);
p.addParamValue('return_all_vars',false);
p.parse(varargin{:});

n_samples = p.Results.samples;
seed = p.Results.seed;
return_all = p.Results.return_all_vars;

if ~isempty(seed)
    % save the random number stream for later restoration
    saved_stream = RandStream.getDefaultStream;
    RandStream.setDefaultStream(RandStream('mt19937ar','seed',seed));
end

vars = convert_ids(model.varnames,vars,'index');

n_vars = length(vars);

xs = zeros(n_samples,size(model.A,2));

samples = rand(n_samples,n_vars);
% scale the sample in the bounds
if p.Results.use_fva_scaling
    [lb,ub] = fva(model,'vars',vars,'frac',0);
else
    lb = model.lb(vars);
    ub = model.ub(vars);
end
lb = lb(:)';
ub = ub(:)';
samples = samples .* repmat(ub - lb,n_samples,1) + repmat(lb,n_samples,1);
        
model.obj(:) = 0;
model.sense = 1;
model.Qc.w = zeros(size(model.lb));
model.Qc.w(vars) = 1;
model.Qc.c = zeros(size(model.lb));

statbar = statusbar(n_samples,p.Results.status);
statbar.start('Sampling');
error_samples = [];
errors = {};
for i = 1 : n_samples
    model.Qc.c(vars) = samples(i,:);
    try
        sol = cmpi.solve_mip(model);
    catch ME
        error_samples(end+1) = i;
        errors{end+1} = ME;
    end
    if ~isempty(sol.x)
        xs(i,:) = sol.x;
    end
    statbar.update(i);
end

if return_all
    vars = xs;
else
    vars = xs(:,vars);
end

if ~isempty(seed)
    % restore the random number stream
    RandStream.setDefaultStream(saved_stream);
end

