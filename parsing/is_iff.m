function [tf] = is_iff(expr)

tf = strcmp(expr.op,'iff');
