function [str] = make_gpr_string(expression)

AND = 1;
OR = 2;

str = make_aux(expression,0);

function [s] = make_aux(e,op)
    if ~is_junc(e)
        s = e.id;
        return;
    end

    if e.AND
        sep = ' & ';
        down_op = AND;
    elseif e.OR
        sep = ' | ';
        down_op = OR;
    end
    
    s = [make_aux(e.lexpr,down_op) sep make_aux(e.rexpr,down_op)];

    if (e.AND && op == OR) || (e.OR && op == AND)
        s = ['(' s ')'];
    end
end

end
