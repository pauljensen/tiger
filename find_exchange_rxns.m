function [ex_locs] = find_exchange_rxns(model)
% FIND_EXCHANGE_RXNS  Find locations of exchange reactions
%
%   Returns the indices of the reactions in an S matrix that only have one
%   nonzero entry.

S = model.S;

S(S ~= 0) = 1;
ex_locs = find(sum(S,1) == 1)';
