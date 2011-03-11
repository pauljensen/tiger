function [tf] = is_valid_expr(e)
% IS_VALID_EXPR  Check that an EXPR object is semantically valid

if isa(e,'cell')
    tf = cellfun(@is_valid_expr,e);
else
    tf =    e.is_atom ...
         || e.is_cond && (e.lexpr.is_atom && e.rexpr.is_atom) ...
         || e.is_junc && (is_valid_expr(e.lexpr) ...
                            && is_valid_expr(e.rexpr));
end