function [tf] = is_and(expr)
% IS_AND  Returns true if EXPR is an AND

tf = strcmp(expr.op,'and');
