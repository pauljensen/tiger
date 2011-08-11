function [tiger] = remove_null_rules(tiger,varargin)
% REMOVE_NULL_RULES  Remove NULL rules from a TIGER model
%
%   [TIGER] = REMOVE_NULL_RULES(TIGER,...params...)
%
%   Removes any null rules that have been added to a TIGER model,
%   including nulls left behind by REMOVE_RULE.
%
%   If the parameter 'remove_rows' is true (default = false), rows in A
%   that were created for the null rules are removed.

p = inputParser;
p.addParamValue('remove_rows',false);
p.parse(varargin{:});

remove_rows = p.Results.remove_rows;

is_null = cellfun(@(x) x.NULL,tiger.param.rules);
nulls = find(is_null);

to_remove = false(size(tiger.A,1),1);
rule_id = tiger.param.rule_id;
for i = 1 : length(nulls)
    idx = nulls(i);
    if remove_rows
        to_remove = to_remove | rule_id == idx;
    else
        rule_id(rule_id == idx) = 0;
    end
    rule_id(rule_id > idx) = rule_id(rule_id > idx) - 1;
    nulls(i+1:end) = nulls(i+1:end) - 1;
end

tiger.param.rule_id = rule_id;
tiger.param.rules = tiger.param.rules(~is_null);

if remove_rows
    tiger = remove_row(tiger,to_remove);
end
