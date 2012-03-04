function [str] = expr_to_string(expr)

if is_null(expr)
    str = '';
    return
end

if is_atom(expr)
    str = expr.id;
elseif is_op(expr)
    str = sprintf('(%s %s %s)',expr_to_string(expr.lexpr), ...
                               expr.op, ...
                               expr_to_string(expr.rexpr));
end

if expr.negated
    str = ['~' str];
end
