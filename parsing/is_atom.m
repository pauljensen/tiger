function [tf] = is_atom(expr)
% IS_ATOM  Returns true if EXPR is an atom (not an operator junction)

tf = ~isempty(expr) && ~isempty(expr.id);
