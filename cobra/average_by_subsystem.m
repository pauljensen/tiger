function [vals,subsystems] = average_by_subsystem(model,data)

assert(isfield(model,'subSystems'), ...
       'model does not contain a "subSystems" field');

if length(data) == length(model.genes)
    data = map_genes_to_rxns(model,data);
end


