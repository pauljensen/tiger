function [expr] = group_ops(expr,force)

if nargin < 2
    force = false;
end

if ~is_op(expr)
    return
end

if ~isempty(expr.exprs)
    expr.exprs = map(@(x) group_ops(x,force),expr.exprs);
    return
end

expr.lexpr = group_ops(expr.lexpr,force);
expr.rexpr = group_ops(expr.rexpr,force);

join_left = ~isempty(expr.lexpr) && strcmp(expr.lexpr.op,expr.op);
join_right = ~isempty(expr.rexpr) && strcmp(expr.rexpr.op,expr.op);

if ~(join_left || join_right)
    if force
        expr.exprs = {expr.lexpr, expr.rexpr};
        expr.lexpr = [];
        expr.rexpr = [];
    end
    return;
end

if ~is_op(expr.lexpr) || ~join_left
    left = {expr.lexpr};
elseif ~isempty(expr.lexpr.exprs)
    left = expr.lexpr.exprs;
else
    left = {expr.lexpr.lexpr, expr.lexpr.rexpr};
end
if ~is_op(expr.rexpr) || ~join_right
    right = {expr.rexpr};
elseif ~isempty(expr.rexpr.exprs)
    right = expr.rexpr.exprs;
else
    right = {expr.rexpr.lexpr, expr.rexpr.rexpr};
end

expr.lexpr = [];
expr.rexpr = [];
expr.exprs = [left right];
