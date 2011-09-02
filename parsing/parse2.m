function [tree] = parse2(str,levels,unary,op_subs,varargin)

tokenstack = lex(str,op_subs);

check_parentheses();

Nlevels = length(levels);
is_token = @(x) isa(x,'token');

error_index = 0;

try
    collapse_to_right();
    tree = parse_aux(tokenstack);
catch ME
    if strcmpi(ME.identifier,'TIGER:stack:empty')
        show_parse_error(length(str)+1, ... 
                         'expression is incomplete or incorrect');
    elseif strcmpi(ME.identifier,'TIGER:parse:syntax')
        show_parse_error(error_index,ME.message);
    else
        rethrow(ME);
    end
end

tree.str = str;

function collapse_to_right()
    newstack = stack();
    while tokenstack.is_another
        next = tokenstack.pop();
        if is_token(next)
            if next.is_rparen
                break
            end
            if next.is_lparen
                collapse_to_right();
                next = tokenstack.pop();
            end
            newstack.push(next);
        end
    end
    
    if ~newstack.is_empty
        newstack.reverse();
        tokenstack.push(parse_aux(newstack));
    end
end

function [tree] = parse_aux(tokens)
    is_unary = @(x) is_token(x) && x.is_op && ismember(x.value,unary);
    
    reduce_stack(Nlevels+1);
    tree = make_optree(tokens.pop());

    function reduce_stack(level)
        prev_length = tokens.length;

        if tokens.length <= 1
            return
        end
        next = tokens.pop();

        if is_unary(next)
            % unary operators bind tightest
            reduce_stack(0);
            if tokens.is_empty
                error_index = next.index;
                error('TIGER:parse:syntax', ...
                      'incomplete expression after unary operator');
            end
            next = make_optree(tokens.pop(),next);
        end

        if tokens.is_another
            op = tokens.peek();
            if ~is_token(op)
                error_index = 0;
                error('TIGER:parse:syntax','operator expected');
            elseif ~op.is_op
                error_index = op.index;
                error('TIGER:parse:syntax','operator expected');
            end

            if get_level(op.value) > level
                tokens.push(next);
                return
            end

            tokens.pop();  % remove the op
            reduce_stack(get_level(op.value));
            if ~tokens.is_another
                error_index = op.index;
                error('TIGER:parse:syntax', ...
                      'incomplete expression after binary operator');
            end
            tokens.push(make_optree(next,op,tokens.pop()));
        else
            tokens.push(next);
        end

        if tokens.length < prev_length
            reduce_stack(level);
        end
    end     


    function [level] = get_level(op)
        found = cellfun(@(x) ismember(op,x),levels);
        level = find(found);
    end

    function [t] = make_optree(t1,op,t2)
        if nargin == 1
            if isa(t1,'optree')
                t = t1;
            else
                t = optree();
                t.id = t1.value;
                t.was_quoted = t1.quoted;
                t.index = t1.index;
            end
        elseif nargin == 2
            % unary operator
            t = optree();
            t.ltree = make_optree(t1);
            t.op = op.value;
            t.index = op.index;
        else
            % binary operator
            t = optree();
            t.ltree = make_optree(t1);
            t.rtree = make_optree(t2);
            t.op = op.value;
            t.index = op.index;
        end
    end
end

function show_parse_error(index,msg)
    pointer = [repmat(' ',1,index-1+3) '|'];
    error('\nTIGER parsing error:  %s\n   %s\n%s\n', ...
          msg,str,pointer);
end

function check_parentheses()
    tokens = tokenstack.copy;
    open_index = stack();
    n_open = 0;
    
    while tokens.is_another
        t = tokens.pop();
        if t.is_lparen
            n_open = n_open + 1;
            open_index.push(t.index);
        elseif t.is_rparen
            if n_open < 1
                show_parse_error(t.index,'unexpected )');
            else
                n_open = n_open - 1;
                open_index.pop();
            end
        end
    end
    
    if n_open > 0
        show_parse_error(open_index.pop(),'unmatched (');
    end
end

end
