function [grRatio,grRateKO,grRateWT] = single_gene_ko(tiger,genes)

if nargin < 2
    genes = tiger.genes;
end

N = length(genes);

grRateKO = zeros(N,1);

sol = fba(tiger);
grRateWT = sol.val;

[~,loc] = ismember(genes,tiger.varnames);
for i = 1 : N
    m = tiger;
    m.ub(loc(i)) = 0;
    sol = fba(m);
    grRateKO(i) = sol.val;
end

grRatio = grRateKO / grRateWT;
