function [tf] = is_simple(expr)
% IS_SIMPLE  Returns true if EXPR is a simple expression

tf =    is_atom(expr) ... 
     || (is_cond(expr) && ~expr.negated) ...
     || (is_junc(expr) && is_atom(expr.lexpr) && is_atom(expr.rexpr));
 