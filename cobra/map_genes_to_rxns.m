function [rxn_vals,model] = map_genes_to_rxns(model,gene_vals)
% MAP_GENES_TO_RXNS  Map measurements from gene to reactions
%
%   [RXN_VALS,MODEL] = MAP_GENES_TO_RXNS(MODEL,GENE_VALS)
%
%   Maps GENE_VALS to RXN_VALS (genes to reactions) using weighting from
%   the GPR in MODEL.  The weighting is calculated using the C matrix,
%   which is added to the MODEL if it does not already exist.

if ~isfield(model,'C')
    model.C = make_c_matrix(model);
end

rxn_vals = model.C * gene_vals;
