function [new] = expr_map(e,f)

new = expr_mapif(e,@(x) true,f);
