function apply_aliases(ex,aliases)

tf = ismember(aliases(:,1),ex.atoms);
aliases = aliases(tf,:);

atom_test = @(e) e.is_atom;
for i = 1 : size(aliases,1)
    ex.iterif(atom_test,@(x) swapif(x,aliases{i,1},aliases{i,2}));
end
    
function swapif(e,name,alias)
    if strcmp(e.id,name)
        e.id = alias;
    end
    