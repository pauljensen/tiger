function [grRatio,grRateKO,grRateWT] = single_gene_ko(tiger,genes,varargin)
% SINGLE_GENE_KO  Perform single gene knockout simulations
%
%   [grRatio,grRateKO,grRateWT] = SINGLE_GENE_KO(TIGER,GENES)
%
%   Performs knockouts of each gene in the cell GENES.  If a GENES is not
%   given, uses all genes in the cell TIGER.genes.
%
%   Parameters
%   'status'  If true (default), display a status bar.
%
%   Outputs
%   grRatio   Ratio of knockout and wild-type growth rates.
%   grRateKO  Growth rate for each knockout.
%   grRateWT  Wild-type growth rate.

if nargin < 2
    genes = tiger.genes;
end

genes = assert_cell(genes);

p = inputParser;
p.addParamValue('status',true);
p.parse(varargin{:});

idxs = convert_ids(tiger.varnames,genes,'index');

N = length(genes);
statbar = statusbar(N,p.Results.status);

grRateKO = zeros(N,1);

sol = fba(tiger);
grRateWT = sol.val;

statbar.start('Single Gene Deletion status');
m = cmpi.prepare_mip(tiger);
for i = 1 : N
    prev_ub = m.ub(idxs(i));
    m.ub(idxs(i)) = 0;
    sol = fba(m);
    if isempty(sol.val)
        % infeasible; assume lethal
        sol.val = 0;
    end
    grRateKO(i) = sol.val;
    m.ub(idxs(i)) = prev_ub;
    statbar.update(i);
end

grRatio = grRateKO / grRateWT;
