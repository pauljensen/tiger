function [tf] = is_if(expr)
% IS_IF  Returns true if EXPR is an IF expression

tf = strcmp(expr.op,'if');
