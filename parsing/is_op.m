function [tf] = is_op(expr)

tf = ~isempty(expr.op);
