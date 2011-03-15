function [tiger] = add_rule(tiger,rule,varargin)
% ADD_RULE  Add rules to a TIGER model
%
%   [TIGER] = ADD_RULE(TIGER,RULE,...params...)
%
%   Convert rules to a MILP format and add them to a TIGER model.
%
%   Inputs
%   TIGER   TIGER model structure.  If empty, a new TIGER structure will
%           be created.
%   RULE    Rule or cell array of rules to be added.  Rules can be either
%           a text string or an EXPR object (text strings will be parsed
%           into EXPR objects).  If multiple rules are to be added to a 
%           model, it is more efficient to call ADD_RULE once with a cell
%           array of rules, rather than makeing repeated calls to ADD_RULE
%           with single rules.
%
%   Outputs
%   TIGER   TIGER model structure with rules added.
%
%   Parameters
%   'default_lb'  Default lower bound for new variables found in the 
%                 rules.  Default is 0.
%   'default_ub'  Default upper bound for new variables found in the 
%                 rules.  Default is 1.
%   'bounds'      Cell specifing upper and lower bounds for new variables.
%                 The first entry is a cell of variable names.  The second
%                 and third entries are vectors containing the lower and
%                 upper bounds for each variable name.  If a atom name is
%                 found in the rules that is not listed, the default 
%                 bounds are used.
%   'not_type'    Type of NOT indicator to use for multilevel variables.
%                 Options are
%                     'inverted'  NOT x =  x_max - x  (default)
%                     'binary'    NOT x =  1  if x > 0
%                                          0  otherwise
%   'ind_prefix'  String denoting the prefix used when creating indicator
%                 variable names.  Default is 'I'.
%   'ind_width'   Integer denoting the number of digits used to create
%                 indicator variable names.  Extra places will be zero-
%                 padded.  Default is 4.
%   'not_prefix'  String denoting the prefix used when creating negated
%                 variable names.  Default is 'NOT__'.

assert(nargin >= 2, 'ADD_RULE requires at least two inputs.');

% if there is no starting model, start with a blank model
if isempty(tiger)
    tiger = create_empty_tiger();
end

% check that a TIGER model was given (and convert if COBRA)
tiger = assert_tiger_model(tiger);

% begin parameter checking
p = inputParser;

p.addParamValue('ind_prefix','I',@ischar);
ind_width_val = @(x) validateattributes(x,{'numeric'}, ...
                                        {'scalar','integer','<=',1});
p.addParamValue('ind_width',4,ind_width_val);
p.addParamValue('not_prefix','NOT__',@ischar);

bound_val = @(x) validateattributes(x,{'numeric'},{'scalar','real'});
p.addParamValue('default_lb',0,bound_val);
p.addParamValue('default_ub',1,bound_val);

p.addParamValue('bounds',[]);

valid_not_type = @(x) ismember(x,{'pseudo-binary','inverted'});
p.addParamValue('not_type','inverted',valid_not_type);

p.parse(varargin{:});

IND_PRE = p.Results.ind_prefix;
IND_WIDTH = p.Results.ind_width;  % number of digits for indicator names
ind_counter = tiger.param.ind;

NOT_PRE = p.Results.not_prefix;
not_type = p.Results.not_type;

default_lb = p.Results.default_lb;
default_ub = p.Results.default_ub;

user_bounds = p.Results.bounds;  % TODO: add support for user bounds

% rule parsing
rules = assert_cell(rule);
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
add_var(atoms);

% measure the size of the original model
[orig_m,orig_n] = size(tiger.A);

% move nots down to the atoms
cellfun(@(x) x.demorgan,rules);

% TODO: pre-allocate A better
A = tiger.A;
b = tiger.b;
ctypes = tiger.ctypes;
ind = tiger.ind;
indtypes = tiger.indtypes;
roff = size(A,1);  % row offset for adding constraints

% simplify the rules and convert to inequalities
cellfun(@simplify_rule,rules);

% add new entries to the TIGER model
Nvars_added = size(A,2) - orig_n;
tiger.A = A;
tiger.b = b;
tiger.ctypes = ctypes;
rownames = array2names('ROW',orig_m+1:size(A,1));
tiger.rownames = [tiger.rownames; rownames'];
tiger.obj = [tiger.obj; zeros(Nvars_added,1)];

tiger.param.ind = ind_counter;

function switch_nots(e)
    % Create negated variables to remove negated atoms. 
    e.iterif(@(x) x.is_atom && x.negated,@switch_aux);
    
    function switch_aux(e)
        not_name = [NOT_PRE e.id];
        add_not_con(e.id,not_name);
        e.id = not_name;
        e.negated = false;
    end
end

function add_not_con(not_var,not_ind)
    if strcmpi(not_type,'binary')
        pseudo_rule = sprintf('%s > 0 <=> %s',not_var,not_ind);
        simplify_rule(parse_string(pseudo_rule));
    else
        [~,var_idx] = ismember(not_var,tiger.varnames);
        tf = ismember(not_ind,tiger.varnames);
        if ~tf
            add_var(not_ind,tiger.lb(var_idx),tiger.ub(var_idx));
            ind_idx = length(tiger.varnames);
            roff = roff + 1;
            A(roff,[var_idx,ind_idx]) = [1 1];
            b(roff) = tiger.ub(var_idx);
            ctypes(roff) = '=';
        end
    end
end

function simplify_rule(r)
    % Simplify a rule.  The resulting
    % rules are of the form:
    %                atom -> atom
    %                cond -> atom
    %       atom AND atom -> atom
    %       atom OR  atom -> atom
    % The simple rules are converted to inequalities.
    switch_nots(r);
    
    if ~r.rexpr.is_atom
        r.rexpr = make_substitution(r.rexpr);
    end
    if ~r.lexpr.is_simple
        simplify_expr(r.lexpr);
    end
    % convert to ineqs
    simple_rule_to_ineqs(r);
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

function [ind_expr] = make_substitution(e)
    % Returns an indicator to replace the expression 'e'.
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
    add_var(ind_name,ind_lb,ind_ub);
    
    simplify_rule(ind_rule);
end

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

function add_var(name,lb,ub)
    % Add a variable to VARNAMES and place correct bounds and vartype.
    % If LB and UB are not given, default bounds or user-specified bounds
    % are used.
    names = assert_cell(name);
    Nnames = length(names);
    if nargin < 2 || isempty(lb)
        lbs = repmat(default_lb,1,Nnames);
    else
        if length(lb) == 1
            lbs = repmat(lb,1,Nnames);
        else
            lbs = lb;
        end
    end
    if nargin < 3 || isempty(ub)
        ubs = repmat(default_ub,1,Nnames);
    else
        if length(ub) == 1
            ubs = repmat(ub,1,Nnames);
        else
            ubs = ub;
        end
    end
        
    % if user specified bounds, change from default
    if ~isempty(user_bounds)
        [tf,loc] = ismember(user_bounds.names,names);
        if any(tf)
            lbs(loc(tf)) = user_bounds.lb(tf);
            ubs(loc(tf)) = user_bounds.ub(tf);
        end
    end
    
    tiger.varnames(end+1:end+Nnames) = names;
    tiger.lb(end+1:end+Nnames) = lbs;
    tiger.ub(end+1:end+Nnames) = ubs;
    
    vartypes = repmat('b',Nnames,1);
    vartypes(ubs > 1) = 'i';
    tiger.vartypes(end+1:end+Nnames) = vartypes;
end

function simple_rule_to_ineqs(r)
    e = r.lexpr;
    I = r.rexpr.id;
    [~,Iloc] = ismember(I,tiger.varnames);
    
    if e.is_atom
        [~,loc] = ismember(e.id,tiger.varnames);
        if r.IFF
            % x <=> I ~> x = I
            addrow([1 -1],'=',0,[loc Iloc]);
        else
            % x => I ~> I >= x
            addrow([1 -1],'<',0,[loc Iloc]);
        end
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
        % multilevel expressions
        if e.AND
            Iaux = get_next_ind_name();
            simplify_rule(sprintf('%s > %s <=> %s',x,y,Iaux));
            [~,Iaux_loc] = ismember(Iaux,tiger.varnames);
            addrow([1 -xmax -1],'<',0,[xloc Iaux_loc Iloc]);
            addrow([1 -ymax -1],'<',ymax,[yloc Iaux_loc Iloc]);
            if r.IFF
                addrow([1 -1],'<',0,[Iloc xloc]);
                addrow([1 -1],'<',0,[Iloc yloc]);
            end
        elseif e.OR
            addrow([1 -1],'>',0,[Iloc xloc]);
            addrow([1 -1],'>',0,[Iloc yloc]);
            if r.IFF
                Iaux = get_next_ind_name();
                simplify_rule(sprintf('%s > %s <=> %s',x,y,Iaux));
                [~,Iaux_loc] = ismember(Iaux,tiger.varnames);
                addrow([1 -xmax -1],'>',-xmax,[xloc Iaux_loc Iloc]);
                addrow([1 -ymax -1],'>',0,[yloc Iaux_loc Iloc]);
            end
        end
    elseif e.is_cond
        assert(ismember(e.cond_op,{'<=','=','>='}), ...
               'Operator %s should have been removed.',e.cond_op);
        l = e.lexpr.id;
        [~,lloc] = ismember(l,tiger.varnames);
        r = e.rexpr.id;
        [~,rloc] = ismember(r,tiger.varnames);
        op = e.cond_op;
        if e.rexpr.is_numeric
            addrow(1,op(1),r,lloc);
        else
            addrow([1 -1],op(1),0,[lloc rloc]);
        end
        ind(roff) = Iloc;
        if r.IFF
            indtype(roff) = 'b';
        else
            indtype(roff) = 'p';
        end
    end
    
    function addrow(coefs,ctype,rhs,loc)
        if nargin < 4
            loc = locs;
        end
        roff = roff + 1;
        A(roff,loc) = coefs;
        b(roff) = rhs;
        ctypes(roff) = ctype;
        ind(roff) = 0;
        indtype(roff) = ' ';
    end   
end

function [tf] = is_multilevel(e)
    [~,ub] = get_expr_bounds(e);
    tf = ub > 1;
end

end % add_rule

