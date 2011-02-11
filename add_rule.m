function [tiger] = add_rule(tiger,rule)

if isempty(tiger)
    tiger = create_empty_tiger();
end

not_types = 'inverted';

tiger.varnames = {};
tiger.lb = [];
tiger.ub = [];

simple_rules = {};

IND_PRE = 'I';
IND_WIDTH = 4;  % number of digits for indicator names
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

% map the nots and add bounds
Nnots = length(not_inds);
tiger.varnames(end+1:end+Nnots) = not_inds;
tiger.lb(end+1:end+Nnots) = 0;
if strcmpi(not_types,'binary')
    tiger.ub(end+1:end+Nnots) = 1;
else
    % inverted
    [~,loc] = ismember(not_vars,tiger.varnames);
    tiger.ub(end+1:end+Nnots) = tiger.ub(loc);
end

n_cons_added = sum(cellfun(@number_of_cons,simple_rules)) ...
                  + length(not_vars);
n_vars_added = sum(cellfun(@number_of_vars,simple_rules));
nnZ_added = 3*n_cons_added;  % upper bound

A = spalloc(n_cons_added,length(tiger.varnames)+n_vars_added,nnZ_added);
ctypes = repmat(' ',n_cons_added,1);
d = zeros(n_cons_added,1);
roff = 0;
voff = length(tiger.varnames);

cellfun(@simple_rule_to_ineq,simple_rules);
% constrain the nots
% TODO -- allow other forms of NOT for multilevel variables
for i = 1 : length(not_vars)
    [~,loc] = ismember({not_vars{i},not_inds{i}},tiger.varnames);
    roff = roff + 1;
    A(roff,loc) = [1 1];
    ctypes(roff) = '=';
    d(roff) = tiger.ub(loc(1));
end

% add new entries to TIGER model
m = size(tiger.A,1);
rownames = array2names('ROW',m+1:m+size(A,1));
tiger.A = [tiger.A; A];
tiger.d = [tiger.d; d];
tiger.ctypes = [tiger.ctypes; ctypes];
tiger.rownames = [tiger.rownames rownames];

% TODO  Update vartypes and obj
% TODO  support for all conditionals


function [lb,ub] = get_expr_bounds(e)
    % Get upper and lower bounds on an expression
    % TODO  tighten bounds on AND and OR
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
    % Get the next indicator name
    ind_counter = ind_counter + 1;
    ind_name = sprintf([IND_PRE '%0*i'], IND_WIDTH, ind_counter);
end
    
function [ind_expr] = make_substitution(e)
    % Returns an indicator to replace the expression 'e'
    % 'e' is formed into a rule with the indicator.  This rule
    % is passed to 'simplify_rule' to be added to the list of
    % simple rules.  The indicator is added to the list of
    % variable names in the TIGER structure.
    %
    % The indicator expression returned is not linked to the
    % new rule (a copy is made in this function).  The expression
    % passed in is copied as well, so the expression in the parent
    % rule can be modified in place.
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
    % Simplifies an expression.  If the left or right subexpressions
    % are not atoms, they are replaced with an indicator variable.
    % This function modifies the expression in place.
    if ~e.lexpr.is_atom
        e.lexpr = make_substitution(e.lexpr);
    end
    if ~e.rexpr.is_atom
        e.rexpr = make_substitution(e.rexpr);
    end
end
    
function simplify_rule(r)
    % Simplify a rule.  The resulting
    % rules are of the form:
    %                atom -> atom
    %                cond -> atom
    %       atom AND atom -> atom
    %       atom OR  atom -> atom
    % The simple rules are appended to the cell 'simple_rules'.
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

function [tf] = is_multilevel(e)
    [~,ub] = get_expr_bounds(e);
    tf = ub > 1;
end

function [num] = number_of_cons(r)
    e = r.lexpr;
    multilevel = is_multilevel(e);
    if e.is_atom
        num = 1;
    elseif e.is_cond
        num = 2;
    elseif  multilevel && e.is_junc && r.IFF
        num = 6;
    elseif  multilevel && e.is_junc && r.IF
        if e.AND
            num = 4;
        else
            num = 2;
        end
    elseif ~multilevel && e.is_junc && r.IFF
        num = 2;
    elseif ~multilevel && e.is_junc && r.IF
        num = 1;
    end
end

function [num] = number_of_vars(r)
    e = r.lexpr;
    if is_multilevel(e) && ((r.IFF && e.junc) || (r.IF && e.AND))
        num = 2;
    else
        num = 0;
    end
end

function simple_rule_to_ineq(r)
    e = r.lexpr;
    I = r.rexpr.id;
    [~,Iloc] = ismember(I,tiger.varnames);
    
    if e.is_atom
        [~,loc] = ismember(e.id,tiger.varnames);
        addrow([1 1],'=',1,[loc Iloc]);
        return;
    end
    
    x = r.lexpr.lexpr.id;
    y = r.lexpr.rexpr.id;
    [~,xloc] = ismember(x,tiger.varnames);
    [~,yloc] = ismember(y,tiger.varnames);
    locs = [xloc yloc Iloc];
    
    multilevel = is_multilevel(r.lexpr);
    
    xmax = tiger.ub(xloc);
    ymax = tiger.ub(yloc);
    
    if ~multilevel && e.AND
        addrow([2 2 -4],'<',3);
        if r.IFF
            addrow([2 2 -4],'>',-1);
        end
    elseif ~multilevel && e.OR
        addrow([-1 -1 3],'>',0);
        if r.IFF
            addrow([-1 -1 3],'<',2);
        end
    elseif e.is_junc
        if ~r.IFF
            % add x > y <=> I_aux
            Iaux = [I '__aux'];
            Iaux_not = [NOT_PRE Iaux];
            Iauxloc = voff + 1;
            Iaux_notloc = voff + 2;
            voff = voff + 2;
            tiger.varnames([Iauxloc,Iaux_notloc]) = {Iaux,Iaux_not};
            tiger.lb([Iauxloc,Iaux_notloc]) = [0 0];
            tiger.ub([Iauxloc,Iaux_notloc]) = [1 1];
            
            aux_rule = parse_string(sprintf('%s > %s <=> %s',x,y,Iaux));
            
            simple_rule_to_ineq(aux_rule);
        end
        if e.AND
            addrow([1 -xbar -1],'<',0,[xloc Iauxloc Iloc]);
            addrow([1 -ybar -1],'<',0,[yloc Iaux_notloc Iloc]);
            if r.IFF
                addrow([-1  0 1],'<',0);
                addrow([ 0 -1 1],'<',0);
            end
        elseif e.OR
            addrow([-1  0 1],'>',0);
            addrow([ 0 -1 0],'>',0);
            if r.IFF
                addrow([1 xbar -1],'>',0,[xloc Iaux_notloc Iloc]);
                addrow([1 ybar -1],'>',0,[yloc Iauxloc Iloc]);
            end
        end
    elseif e.is_cond
        switch e.cond_op
            case '>='
                addrow([ 1 -1 -(xmax+1)],'<',-1);
                addrow([-1  1  (ymax+1)],'<',ymax+1);
            case '>'
                addrow([ 1 -1 -(xmax+1)],'<',0);
                addrow([-1  1  (ymax+2)],'<',ymax);
            case '<='
                addrow([-1  1 -(1-xmax)],'<',-1);
                addrow([ 1 -1  (1-ymax)],'<',1-ymax);
            case '<'
                addrow([-1  1 -(1-xmax)],'<',0);
                addrow([ 1 -1  (2-ymax)],'<',-ymax);
            otherwise
                error('Operator %s not implemented.',e.cond_op);
        end
    end
    
    function addrow(coefs,ctype,rhs,loc)
        if nargin < 4
            loc = locs;
        end
        roff = roff + 1;
        A(roff,loc) = coefs;
        d(roff) = rhs;
        ctypes(roff) = ctype;
    end   
end
    

end % function

        
