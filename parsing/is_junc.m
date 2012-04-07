function [tf] = is_junc(expr)
% IS_JUNC  Returns true if EXPR is a junction

tf = strcmp(expr.op,'and') || strcmp(expr.op,'or');
