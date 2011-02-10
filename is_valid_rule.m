function [tf] = is_valid_rule(rule)

if isa(rule,'cell')
    tf = cellfun(@is_valid_rule,rule);
else
    tf =    (rule.is_rule) ...
         && is_valid_expr(rule.lexpr) ...
         && is_valid_expr(rule.rexpr) ...
         && ~rule.negated;
end

