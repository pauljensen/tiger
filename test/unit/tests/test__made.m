
cobra_model

gene_names = {'g7a','g7b','g4','g8c'};

fc =    [   2   2;  % g7a
            1 0.9;  % g7b
            2   2;  % g4
            2   2]; % g8
            
pvals = [ 0.1 0.1;  % g7a
          0.1 0.1;  % g7b
          0.1 0.1;  % g4
          0.1 0.1]; % g8

tiger = cobra_to_tiger(cobra);
[gene_states,genes,sol] = made(tiger,fc,pvals, ...
                               'weighting','linear', ...
                               'gene_names',gene_names, ...
                               'verbose',false);