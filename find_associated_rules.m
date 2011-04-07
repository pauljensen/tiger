function [assoc] = find_associated_rules(exprs,start)

%rules = parse_string(rules);
rules = exprs;
atoms = map(@(x) x.atoms,rules);

assoc = false(size(rules));

prev_count = -1;
current_imp = assert_cell(start);

while prev_count < count(assoc)
    prev_count = count(assoc);
    f = @(x) any(ismember(current_imp,x));
    to_add = cellfun(f,atoms);
    assoc = assoc | to_add;
    new_atoms = atoms(to_add);
    current_imp = [current_imp{:},new_atoms{:}];
end
