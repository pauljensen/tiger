function [tree] = parse2(tokenstack,levels,unary,varargin)

Nlevels = length(levels);
is_token = @(x) isa(x,'token');

collapse_to_right();

tree = parse_aux(tokenstack);

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
            next = make_optree(tokens.pop(),next);
        end

        if tokens.is_another
            op = tokens.peek();

            if get_level(op.value) > level
                tokens.push(next);
                return
            end

            tokens.pop();  % remove the op
            reduce_stack(get_level(op.value));
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
            end
        elseif nargin == 2
            % unary operator
            t = optree();
            t.lexpr = make_optree(t1);
            t.op = op.value;
        else
            % binary operator
            t = optree();
            t.lexpr = make_optree(t1);
            t.rexpr = make_optree(t2);
            t.op = op.value;
        end
    end
end

end
