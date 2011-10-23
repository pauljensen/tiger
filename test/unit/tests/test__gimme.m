
cobra_model

express    = [   10   10     1     2    3];
gene_names = {'g5a','g4','g5b','g5c','g6'};

tiger = cobra_to_tiger(cobra);
[states,genes,sol,t] = gimme(tiger,express,5,'gene_names',gene_names);

assert(near(states,[1 1 0 1 0]),'states incorrect');
assert(cmpi.is_acceptable_exit(fba(t)),'nonfunctional');

clear cobra express gene_names genes m n sol states t tiger
