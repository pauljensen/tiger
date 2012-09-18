function [cores] = cores(cobra)

cobra.lb(cobra.lb < 0) = -1000;
cobra.ub(cobra.ub > 0) =  1000;
cobra.lb(cobra.lb > 0) = 0;

elf = make_elf(cobra);

[cores] = var_coupling(elf,elf.genes);
