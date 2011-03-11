function [grRatio,grRateKO,grRateWT] = single_gene_ko(tiger,genes)
% SINGLE_GENE_KO  Perform single gene knockout simulations
%
%   [grRatio,grRateKO,grRateWT] = SINGLE_GENE_KO(TIGER,GENES)
%
%   Performs knockouts of each gene in the cell GENES.  If a GENES is not
%   given, uses all genes in the cell TIGER.genes.
%
%   Outputs
%   grRatio   Ratio of knockout and wild-type growth rates.
%   grRateKO  Growth rate for each knockout.
%   grRateWT  Wild-type growth rate.

if nargin < 2
    genes = tiger.genes;
end

[genes,~,~] = convert_ids(genes);

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
