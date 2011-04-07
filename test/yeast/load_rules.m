
load ind750

fid = fopen('aliases.csv');
aliases = textscan(fid,'%q%q','Delimiter',',','CollectOutput',true);
aliases = aliases{1};
fclose(fid);

fid = fopen('rules.csv');
raw = textscan(fid,'%q%q','Delimiter',',','CollectOutput',true);
raw = raw{1};
fclose(fid);

Nrules = size(raw,1);
rules = cell(Nrules,1);
for i = 1 : Nrules
    rules{i} = [raw{i,2}(4:end) ' <=> ' raw{i,1}];
end

% remove infeasible
infeas = [79 104 130 300 428];
for i = 1 : length(infeas)
    rules{infeas(i)} = 'a => b';
end
    
exprs = parse_string(rules);
celliter(@(x) apply_aliases(x,aliases),exprs);

all_atoms = map(@(x) x.atoms,exprs);
all_atoms = unique([all_atoms{:}])';

unbound = setdiff(find_like('^[^Y]',all_atoms), ...
                  find_like('\[e\]$',cobra.mets));

tic; tiger_base = cobra_to_tiger(cobra); toc
mets = find_like('\[e\]$',all_atoms);              
tiger_base = add_column(tiger_base,mets);
%tiger_base = bind_mets(tiger_base);
%tiger_base = bind_var(tiger_base,{'EX_glc(e)'},{'glc[e]'},'iff',true);

tinf = add_growth_constraint(tiger_base,0.01,'valtype','abs');
[infeas,side] = find_infeasible_rules(tinf,exprs);


tic; trn  = add_rule(tiger_base,exprs);  toc

%trn = bind_mets(trn);              
%trn = bind_var(trn,{'EX_glc(e)'},{'glc[e]'},'iff',true);

save yeast_trn_iff.mat trn