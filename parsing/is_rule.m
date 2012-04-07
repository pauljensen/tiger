function [tf] = is_rule(expr)
% IS_RULE  Returns true if EXPR is a rule (IF or IFF)

tf = expr.IFF || expr.IF;
