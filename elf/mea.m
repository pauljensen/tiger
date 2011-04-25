function [sol] = mea(elf,actnorm)

if nargin < 2
    actnorm = 'euclid';
end

elf = add_growth_constraint(elf,0.99);
elf.obj(:) = 0;
nA = size(elf.A,2);
idxs = convert_ids(elf.varnames,elf.genes,'index');

no_gpr_rxns = find(cellfun(@isempty,elf.grRules));

idxs = [idxs; no_gpr_rxns];

switch actnorm
    case {'euclid','quad','two'}
        elf.Q = spalloc(nA,nA,length(idxs));
        for i = 1 : length(idxs)
            elf.Q(idxs(i),idxs(i)) = 1;
        end
    case {'one','taxi','manhattan'}
        elf.obj(idxs) = 1;
end

sol = cmpi.solve_mip(elf);
