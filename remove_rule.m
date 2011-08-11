function [tiger] = remove_rule(tiger,rule)

if isa(rule,'double')
    % indices given
    exprs = tiger.param.rules(rule);
else
    exprs = assert_cell(parse_string(rule));
end

null_expr = expr();
null_expr.NULL = true;

N = length(exprs);
rule_strs = map(@(x) x.to_string,tiger.param.rules);
for i = 1 : N
    % find matching rules
    matched = find(map(@(x) strcmp(x,exprs{i}.to_string),rule_strs));
    % find corresponding rows
    to_zero = ismember(tiger.param.rule_id,matched);
    % zero the rows
    tiger.A(to_zero,:) = 0;
    % replace the removed rule with the null expression
    for j = 1 : length(matched)
        tiger.param.rules{matched(j)} = null_expr.copy;
    end
end

