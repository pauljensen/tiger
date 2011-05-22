function [ex_locs] = find_exchange_rxns(model)

S = model.S;

S(S ~= 0) = 1;
ex_locs = find(sum(S,1) == 1)';
