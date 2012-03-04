function [expr] = fold_nots(expr)

expr = expr_map(expr,@collapse);

function [e] = collapse(e)
    if strcmp(e.op,'not')
        e.lexpr.negated = ~e.lexpr.negated;
        e = e.lexpr;
    end
