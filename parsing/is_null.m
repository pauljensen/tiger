function [tf] = is_null(expr)

tf = isempty(expr) || expr.NULL || ...
        ~(isempty(expr.op) && isempty(expr.id));
