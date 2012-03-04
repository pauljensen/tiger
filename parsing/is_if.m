function [tf] = is_if(expr)

tf = strcmp(expr.op,'if');
