function [tf] = is_cond(expr)
% IS_COND  Returns true if EXPR is a conditional expression

tf = ismember(expr.op,{'=','<','>','<=','>=','~='});
