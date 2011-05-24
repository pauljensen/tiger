function [vals,subsystems] = average_by_subsystem(model,data)

data(~isfinite(data)) = 0;

if ~isfield(model,'rxnGeneMat')
    model.rxnGeneMat = make_rxnGeneMat(model);
end

assert(isfield(model,'subSystems'), ...
       'model does not contain a "subSystems" field');

if length(data) == length(model.genes)
    data = map_genes_to_rxns(model,data);
end

subsystems = unique(model.subSystems);
[~,subids] = ismember(model.subSystems,subsystems);

vals = zeros(length(subsystems),1);
for i = 1 : length(subsystems)
    insub = ismember(subids,i);
    nrxns = count(insub > 0);
    ngenes = count( sum(model.rxnGeneMat(insub,:),1) > 0 );
    
    vals(i) = mean(data(insub));
    subsystems{i} = sprintf('%s [%i,%i]',subsystems{i},nrxns,ngenes);
end

