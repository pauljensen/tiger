function [tf] = is_null(expr)
% IS_NULL  Returns true if EXPR is a null (empty) expression

tf = isempty(expr) || expr.NULL || ...
        ~(isempty(expr.op) && isempty(expr.id));
