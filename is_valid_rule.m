function [tf] = is_valid_rule(rule)
% IS_VALID_RULE  Check that an EXPR object is a valid rule

if isa(rule,'cell')
    tf = cellfun(@is_valid_rule,rule);
else
    tf =    (rule.is_rule) ...
         && is_valid_expr(rule.lexpr) ...
         && is_valid_expr(rule.rexpr) ...
         && ~rule.negated;
end

