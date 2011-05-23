function [rxn_vals] = map_genes_to_rxns(model,gene_vals)

if ~isfield(model,'C')
    model.C = make_c_matrix(model);
end

rxn_vals = model.C * gene_vals;
