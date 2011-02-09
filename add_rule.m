function [tiger] = add_rule(tiger,rule)

IND_STR = 'I';
IND_WIDTH = 4;  % number of digists for indicator names
ind_counter = 0;

default_lb = 0;
default_ub = 1;

user_bounds = [];

if ~isa(rule,'cell')
    exprs = {rule};
else
    exprs = rule;
end

N = length(exprs);
% parse all strings if necessary
for i = 1 : N
    if ~isa(exprs{i},'expr')
        if isa(exprs{i},'char')
            exprs{i} = parse_string(exprs{i});
        else
            error('Objects of class %s cannot be parsed.', ...
                  class(exprs{i}));
        end
    end
end

% get all atoms in the expression list
atoms = cellfun(@(x) x.atoms,exprs,'Uniform',false);
atoms = setdiff(unique([atoms{:}]),tiger.varnames);


Natoms = length(atoms);
tiger.varnames{end+1:end+Natoms} = atoms;
tiger.lb(end+1:end+Natoms) = default_lb;
tiger.ub(end+1:end+Natoms) = default_ub;

if ~isempty(user_bounds);
    [tf,loc] = ismember(user_bounds.names,tiger.varnames);
    tiger.lb(loc(tf)) = user_bounds.lb(tf);
    tiger.ub(loc(tf)) = user_bounds.ub(tf);
end

function [lb,ub] = get_expr_bounds(e)
    if e.is_atom
        [~,loc] = ismember(e.id,tiger.varnames);
        lb = tiger.lb(loc);
        ub = tiger.ub(loc);
    else
        [llb,lub] = get_expr_bounds(e.lexpr);
        [rlb,rub] = get_expr_bounds(e.rexpr);
        lb = min([llb rlb]);
        ub = max([lub rub]);
    end

function [ind_name] = get_next_ind_name()
    ind_counter = ind_counter + 1;
    ind_name = sprintf([IND_STR '%0*i'], IND_WIDTH, ind_counter);
    

function [ind_expr] = make_substitution(e)
    ind_name = get_next_ind_name();

    ind_rule = expr();
    ind_rule.IFF = true;
    ind_rule.lexpr = e.copy;
    ind_rule.
