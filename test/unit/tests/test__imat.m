
init_test
cobra_model

levels     = [    2    1     0     0];
gene_names = {'g7a','g7b','g6','g5a'};
weights    = [    4    1     3     1];

tiger = cobra_to_tiger(cobra);
[levels,genes,sol,t] = imat(tiger,levels,'gene_names',gene_names, ...
                                         'flux_eps',0.3, ...
                                         'weights',weights);

assert(near(levels,[2 2 0 1]),'levels incorrect');
