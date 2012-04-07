function [tf] = is_iff(expr)
% IS_IFF  Returns true if EXPR is an IFF operator

tf = strcmp(expr.op,'iff');
