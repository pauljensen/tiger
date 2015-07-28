function cobra = compile_to_cobra(model,varargin)

args = inputParser;
args.addOptional('objectiveName','bio1');
args.parse(varargin{:});

rxns = values(model.reactions);
nrxns = length(rxns);
metidx = create_index_map(uniqueflatmap('localizedCompounds', ...
                                        values(model.reactions)));
Snnz = sum(cellfun(@(x) length(x.localizedCompounds), rxns));
cobra.S = spalloc(length(metidx), nrxns, Snnz);
cobra.lb = zeros(nrxns,1);
cobra.ub = zeros(nrxns,1);
for j = 1 : nrxns
    for r = rxns{j}.reactants
        cobra.S(metidx(r.localizedCompound),j) = -1 * r.coefficient;
    end
    for p = rxns{j}.products
        cobra.S(metidx(p.localizedCompound),j) = p.coefficient;
    end
    
    cobra.lb(j) = rxns{j}.lb;
    cobra.ub(j) = rxns{j}.ub;                           
end

cobra.mets = keys(metidx);
cobra.rxns = map(@(x) x.id, rxns);
cobra.rxnNames = map(@(x) x.name, rxns);

cobra.c = zeros(nrxns,1);
if ~isempty(args.Results.objectiveName)
    cobra.c(ismember(cobra.rxns,args.Results.objectiveName)) = 1;
end

cobra.genes = sort(uniqueflatmap('genes',rxns));
cobra.grRules = map(@(x) toString(x.gpr), rxns);

end


function idxmap = create_index_map(keySet)

idxmap = containers.Map(keySet,1:length(keySet),'UniformValues',true);

end