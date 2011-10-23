
cobra_model_extended;

elf = cobra_to_elf(cobra);

%[sets_dn,sets_up] = enzyme_coupling(elf);

clear cobra elf m n
