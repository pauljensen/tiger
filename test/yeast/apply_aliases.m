function apply_aliases(ex,aliases)
% APPLY_ALIASES  Change atom aliases to the same name
%
%   [EX] = APPLY_ALIASES(EX,ALIASES)
%
%   ALIASES is a N x 2 cell of aliases, where the first column is the
%   alias, and the second column is the name that should be substituted
%   for the alias.

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
    