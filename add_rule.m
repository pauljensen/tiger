function [tiger] = add_rule(tiger,rule)

tiger.varnames = {};
tiger.lb = [];
tiger.ub = [];

simple_rules = {};

IND_PRE = 'I';
IND_WIDTH = 4;  % number of digists for indicator names
ind_counter = 0;

NOT_PRE = 'NOT__';
not_vars = {};
not_inds = {};

default_lb = 0;
default_ub = 1;

user_bounds = [];

if ~isa(rule,'cell')
    rules = {rule};
else
    rules = rule;
end

N = length(rules);
% parse all strings if necessary
for i = 1 : N
    if ~isa(rules{i},'expr')
        if isa(rules{i},'char')
            rules{i} = parse_string(rules{i});
        else
            error('Objects of class %s cannot be parsed.', ...
                  class(rules{i}));
        end
    else
        % be sure to not overwrite parent object
        rules{i} = rules{i}.copy;
    end
end

% get all atoms in the expression list
atoms = cellfun(@(x) x.atoms,rules,'Uniform',false);
atoms = setdiff(unique([atoms{:}]),tiger.varnames);


Natoms = length(atoms);
tiger.varnames(end+1:end+Natoms) = atoms;
tiger.lb(end+1:end+Natoms) = default_lb;
tiger.ub(end+1:end+Natoms) = default_ub;

if ~isempty(user_bounds);
    [tf,loc] = ismember(user_bounds.names,tiger.varnames);
    tiger.lb(loc(tf)) = user_bounds.lb(tf);
    tiger.ub(loc(tf)) = user_bounds.ub(tf);
end

cellfun(@(x) x.demorgan,rules);
cellfun(@simplify_rule,rules);
cellfun(@switch_nots,simple_rules);
simple_rules{:}

1;

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
end

function [ind_name] = get_next_ind_name()
    ind_counter = ind_counter + 1;
    ind_name = sprintf([IND_PRE '%0*i'], IND_WIDTH, ind_counter);
end
    
function [ind_expr] = make_substitution(e)
    ind_name = get_next_ind_name();
    ind_expr = expr();
    ind_expr.id = ind_name;

    ind_rule = expr();
    ind_rule.IFF = true;
    ind_rule.lexpr = e.copy;
    ind_rule.rexpr = ind_expr.copy;
    
    [ind_lb,ind_ub] = get_expr_bounds(e);
    tiger.varnames{end+1} = ind_name;
    tiger.lb(end+1) = ind_lb;
    tiger.ub(end+1) = ind_ub;
    
    simplify_rule(ind_rule);
end
    
function [e] = simplify_expr(e)
    if ~e.lexpr.is_atom
        e.lexpr = make_substitution(e.lexpr);
    end
    if ~e.rexpr.is_atom
        e.rexpr = make_substitution(e.rexpr);
    end
end
    
function simplify_rule(r)
    if ~r.rexpr.is_atom
        r.rexpr = make_substitution(r.rexpr);
    end
    if ~r.lexpr.is_simple
        r.lexpr = simplify_expr(r.lexpr);
    end
    simple_rules{end+1} = r;
end

function switch_nots(e)
    if e.is_atom && e.negated
        not_name = [NOT_PRE e.id];
        [tf,loc] = ismember(not_name,tiger.varnames);
        if ~tf
            not_vars{end+1} = e.id;
            not_inds{end+1} = not_name;
        end
        e.id = not_name;
        e.negated = false;
    end
    
    if ~isempty(e.lexpr)
        switch_nots(e.lexpr);
    end
    if ~isempty(e.rexpr)
        switch_nots(e.rexpr);
    end
end


end % function

        
