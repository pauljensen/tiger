function [e] = demorgan_expr(e)

if e.negated && is_junc(e)
    orig_op = e.op;
    if strcmp(orig_op,'or'), e.op = 'and'; end
    if strcmp(orig_op,'and'), e.op = 'or'; end
    e.negated = false;
    
    e.lexpr.negated = ~e.lexpr.negated;
    e.rexpr.negated = ~e.rexpr.negated;
    for i = 1 : length(e.exprs)
        e.exprs{i}.negated = ~e.exprs{i}.negated;
    end
elseif e.negated && is_cond(e)
    e.negated = false;
    switch e.op
        case '='
            e.op = '~=';
        case '~='
            e.op = '=';
        case '>='
            e.op = '<';
        case '<'
            e.op = '>=';
        case '<='
            e.op = '>';
        case '>'
            e.op = '<=';
    end
end

if is_junc(e.lexpr) || is_cond(e.lexpr)
    e.lexpr = demorgan_expr(e.lexpr);
end
if is_junc(e.rexpr) || is_cond(e.rexpr)
    e.rexpr = demorgan_expr(e.rexpr);
end

for i = 1 : length(e.exprs)
    if is_junc(e.exprs{i}) || is_cond(e.exprs{i})
        e.exprs{i} = demorgan_expr(e.exprs{i});
    end
end
