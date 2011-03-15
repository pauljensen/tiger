function [ex] = make_expr(e1,op,e2)

if nargin == 1
    if isa(e1,'token')
        ex = expr();
        ex.id = e1.value;
        ex.was_quoted = e1.quoted;
    elseif isa(e1,'expr')
        ex = e1;
    else
        error('Expr cannot be formed from class ''%s''',class(e1));
    end
else
    % make operator cons
    ex = expr();
    ex.lexpr = make_expr(e1);
    ex.rexpr = make_expr(e2);
    switch op
        case 'and'
            ex.AND = true;
        case 'or'
            ex.OR = true;
        case 'iff'
            ex.IFF = true;
        case 'if'
            ex.IF = true;
        otherwise
            ex.cond_op = op;
    end
end
