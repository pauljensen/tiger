function [vals,subsystems] = average_by_subsystem(model,data)
% AVERAGE_BY_SUBSYSTEM  Average gene or flux data by subsystem
%
%   [VALS,SUBSYSTEMS] = AVERAGE_BY_SUBSYSTEMS(MODEL,DATA)
%
%   Average gene or flux data by grouping values by subsystem.  SUBSYSTEMS
%   is a unique cell of subsystems corresponding to the average values in
%   VALS.  The format of each entry in SUBSYSTEMS is "s [i,j]", where s is
%   the name of the subsystem, and i and j are the number of reactions and
%   genes mapped to that subsystem.
%
%   MODEL must contain a "subSystems" field of subsystems for each 
%   reaction.  If LENGTH(DATA) == LENGTH(MODEL.GENES), the values in DATA
%   are mapped to reaction susing MAP_GENES_TO_RXNS.

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

