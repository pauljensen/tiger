function [expr] = group_ops(expr,force)

if nargin < 2
    force = false;
end

if ~is_op(expr)
    return
end

expr.lexpr = group_ops(expr.lexpr,force);
expr.rexpr = group_ops(expr.rexpr,force);

join_left = strcmp(expr.lexpr.op,expr.op);
join_right = strcmp(expr.rexpr.op,expr.op);

if ~(join_left || join_right)
    if force
        expr.exprs = {expr.lexpr, expr.rexpr};
        expr.lexpr = [];
        expr.rexpr = [];
    end
    return;
end

if ~is_op(expr.lexpr)
    left = {expr.lexpr};
elseif ~isempty(expr.lexpr.exprs)
    left = expr.lexpr.exprs;
else
    left = {expr.lexpr.lexpr, expr.lexpr.rexpr};
end
if ~is_op(expr.rexpr)
    right = {expr.rexpr};
elseif ~isempty(expr.rexpr.exprs)
    right = expr.rexpr.exprs;
else
    right = {expr.rexpr.lexpr, expr.rexpr.rexpr};
end

expr.lexpr = [];
expr.rexpr = [];
expr.exprs = [left right];
