function [fluxes] = dare(elf,fold_change,gene_names,alpha,obj_frac,bounds)

if nargin < 6 || isempty(bounds)
    bounds = [];
end

[ngenes,ntrans] = size(fold_change);
assert(ngenes == length(gene_names), ...
       'FOLD_CHANGE and GENE_NAMES must have the same # of rows');

d = ones(ngenes,ntrans);
d(fold_change < 1) = -1;

[tf,gene_locs] = ismember(gene_names,elf.varnames);
genes = gene_names(tf);
gene_locs = gene_locs(tf);
fold_change = fold_change(tf,:);

ngenes = length(genes);

mip = mea(elf,[],true,obj_frac);
mip.Q = (1-alpha) .* mip.Q;
weights = alpha*(fold_change - 1);

[~,sol] = diffadj(mip,genes,d,-weights,[],bounds,[],0);

if ~isempty(sol.x)
    fluxes = cell(1,ntrans+1);
    n = size(elf.A,2);
    for i = 1 : ntrans + 1
        fluxes{i} = sol.x((i-1)*n+(1:n));
    end
else
    fluxes = [];
end
