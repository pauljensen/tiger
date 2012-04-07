function [tf] = is_or(expr)
% IS_OR  Returns true if EXPR is an OR expression

tf = strcmp(expr.op,'or');
