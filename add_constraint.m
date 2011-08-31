function [tiger] = add_constraint(tiger,constraint,varargin)

assert(nargin >= 2, 'ADD_CONSTRAINT requires at least two inputs.');

% if there is no starting model, start with a blank model
if isempty(tiger)
    tiger = create_empty_tiger();
end

% check that a TIGER model was given (and convert if COBRA)
tiger = assert_tiger(tiger);

levels = { {'*'}, ...
           {'+','-'}, ...
           {'>=','>','=','<','<='} };

op_subs = { '+'  , {'+'}, ...
            '-'  , {'-'}, ...
            '*'  , {'*'}, ...
            '>=' , {'>='}, ...
            '>'  , {'>'}, ...
            '='  , {'=','=='}, ...
            '<'  , {'<'}, ...
            '<=' , {'<='} };

cons = assert_cell(constraint);

N = length(cons);

bs = zeros(1,N);
coefs = cell(1,N);
names = cell(1,N);

strip1 = @(x) cellfun(@(y) y{1},x);
strip2 = @(x) map(@(y) y{2},x);

for i = 1 : N
    e = parse_single(cons{i});
    e.iterif(@(x) x.cond_op == '-',@fold_negative);
    [lvars,lconst] = parse_side(e.lexpr);
    [rvars,rconst] = parse_side(e.rexpr);
    coefs{i} = [strip1(lvars), -strip1(rvars)];
    names{i} = [strip2(lvars), strip2(rvars)];
    bs(i) = rconst - lconst;
end

1;


function [e] = parse_single(c)
    if isa(c,'expr')
        e = c.copy();
    elseif isempty(c)
        e = expr();
        e.NULL = true;
    else
        assert(isa(c,'char'),'Objects of class %s cannot be parsed.', ...
                             class(c));
        e = parse(lex(c,op_subs),levels,{});
    end
end

function [vars,const] = parse_side(e)
    terms = collect_terms(e);
    vars = {};
    const = 0;
    for j = 1 : length(terms)
        term = terms{j};
        if term.is_numeric
            const = const + str2double(term.id);
            continue
        end
        
        if term.is_atom
            newvar = {1,term.id};
        else
            newvar = {str2double(term.lexpr.id),term.rexpr.id};
        end
        
        vars{end+1} = newvar;
    end
end

function [terms] = collect_terms(e)
    if e.cond_op == '+'
        terms = flatten({e.lexpr, collect_terms(e.rexpr)});
    else
        terms = {e};
    end
end

function fold_negative(e)
    e.cond_op = '+';
    if e.rexpr.is_atom
        c = expr();
        c.id = '-1';
        c.is_numeric = true;
        a = e.rexpr;
        e.rexpr = expr();
        e.rexpr.cond_op = '*';
        e.rexpr.lexpr = c;
        e.rexpr.rexpr = a;
    else
        e.rexpr.lexpr.id = num2str(str2double(e.rexpr.lexpr.id) * -1);
    end
end

end 
