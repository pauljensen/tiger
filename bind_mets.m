function [tiger] = bind_mets(tiger)
% BIND_METS  Bind metabolites to exchange reactions.
%
%   [TIGER] = BIND_METS(TIGER)
%
%   Searches for variable names that match metabolite names.  If found,
%   adds constraints to the exchange reactions for the metabolite such 
%   that if the metabolite is taken up, the variable must be 'on', and
%   if no metabolite is taken up, the variable must be 'off'.

m = size(tiger.S,1);
to_bind = ismember(tiger.rownames(1:m),tiger.varnames);
met_idxs = find(to_bind);
met_inds = tiger.rownames(met_idxs);

% find the excange reaction
ex_idxs = zeros(size(met_idxs));
colsums = sum(tiger.S ~= 0,1);
for i = 1 : length(met_idxs)
    ex_idxs(i) = find(tiger.S(met_idxs(i),:) ~= 0 & colsums == 1);
end

tiger = bind_var(tiger,ex_idxs,met_inds,'iff',true);

