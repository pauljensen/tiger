function [expression] = parse(tokens,levels,unary)

expression = parse_aux();

function [ex] = parse_aux()
    ex = get_expr(0);
    while tokens.is_another
        next = tokens.pop();
        if next.is_rparen
            return
        end
        op = next.value;
        assert(next.is_op,'Operator expected instead of ''%s''',op);
        ex = make_expr(ex,op,get_expr(get_level(op)));
    end
    if isa(ex,'token')
        ex = make_expr(ex);
    end
end

function [level] = get_level(op)
    found = cellfun(@(x) ismember(op,x),levels);
    level = find(found);
end

function [e] = get_expr(level)
    t = tokens.pop();
    if t.is_lparen
        e = parse_aux();
    elseif t.is_op
        op = t.value;
        assert(ismember(op,unary),'Unexpected operator ''%s''',op);
        e = make_expr(get_expr(get_level(op)));
        e.negated = true;
    else
        e = t;
    end
    if tokens.is_another
        next = tokens.peek();
        if next.is_op && get_level(next.value) < level
            tokens.pop();
            e = make_expr(e,next.value,get_expr(get_level(next.value)));
        end
    end
end

end % function
