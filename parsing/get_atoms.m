function [atoms] = get_atoms(e)

if isempty(e) || e.NULL
    atoms = {};
    return;
end

if ~isempty(e.lexpr) || ~isempty(e.rexpr) || ~isempty(e.exprs)
    latoms = get_atoms(e.lexpr);
    ratoms = get_atoms(e.rexpr);
    eatoms = unique(flatten(map(@get_atoms,e.exprs)));
    atoms = unique([latoms ratoms eatoms]);
else
    if e.is_numeric || isempty(e.id)
        atoms = {};
    else
        atoms = {e.id};
    end
end
