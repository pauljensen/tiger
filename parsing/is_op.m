function [tf] = is_op(expr)
% IS_OP  Returns true if EXPR is an operator junction

tf = ~isempty(expr) && ~isempty(expr.op);
