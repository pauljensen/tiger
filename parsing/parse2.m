function [tree] = parse2(tokens,levels,unary,varargin)

is_token = @(x) isa(x,'token');
is_unary = @(x) x.is_op && ismember(x.value,unary);

Nlevels = length(levels);

reduce_stack(Nlevels+1);
while tokens.length > 1
    reduce_stack(Nlevels+1);
end

tree = tokens.pop();


function reduce_stack(level)
    next = tokens.pop();
    
    if next.is_rparen
        return
    end
    
    if is_token(next)
        if is_unary(next)
            % unary operators bind tightest
            reduce_stack(Nlevels+1);
            t = optree();
            t.op = next.value;
            t.lexpr = tokens.pop();
            tokens.push(t);
            reduce_stack(level);
        end

        next = make_optree(next);
    end

    if tokens.length == 0
        tokens.push(next);
        return
    elseif tokens.length == 1
        % error -- unclaimed token
    end
    
    % next is an optree object
    % there are at least two tokens on the stack
    op = tokens.peek();
    if get_level(op.value) >= level
        tokens.push(next);
    else
        tokens.pop();  % clear the operator
        reduce_stack(get_level(op.value));
        tokens.push(make_optree(next,op,tokens.pop()));
    end      
end


function [level] = get_level(op)
    found = cellfun(@(x) ismember(op,x),levels);
    level = find(found);
end

function [t] = make_optree(t1,op,t2)
    if nargin == 1
        t = optree();
        t.id = t1.value;
        t.was_quoted = t1.quoted;
    else
        t = optree();
        t.lexpr = make_optree(t1);
        t.rexpr = make_optree(t2);
        t.op = op.value;
    end
end

end