function [new] = expr_mapif(e,test,f)

if test(e)
    new = f(e);
else
    new = e;
end

if ~isempty(new.lexpr)
    new.lexpr = expr_mapif(new.lexpr,test,f);
end
if ~isempty(new.rexpr)
    new.rexpr = expr_mapif(new.rexpr,test,f);
end

if ~isempty(new.exprs)
    new.exprs = map(@(x) expr_mapif(x,test,f),new.exprs);
end
