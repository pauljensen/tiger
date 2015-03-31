function [tiger,rxn_names] = create_exchange_reactions(tiger,mets,lb,ub)

if nargin < 3
    lb = min(tiger.lb);
end
if nargin < 4
    ub = max(tiger.ub);
end

[~,met_idxs] = convert_ids(tiger.rownames,mets);
ex_rxn_names = map(@(x) ['EX_' x], mets);
[tiger,rxn_names] = add_column(tiger,ex_rxn_names,'c',lb,ub);
[~,rxn_idxs] = convert_ids(tiger.varnames,rxn_names);
for i = 1 : length(rxn_idxs)
    tiger.A(met_idxs(i),rxn_idxs(i)) = -1;
end
