function [tiger] = update_rule(tiger,old_rules,new_rules,varargin)
% UPDATE_RULE  Re-compile rule(s) previously added to a TIGER model
%
%   [TIGER] = UPDATE_RULE(TIGER,OLD_RULES,NEW_RULES,...params...)
%
%   UPDATE_RULE takes a list of rules (OLD_RULES) and replaces them with
%   NEW_RULES.  The modified model structure is returned.
%
%   If any entry in NEW_RULES is empty, or if only two arguments are 
%   given, then the rules in OLD_RULES are recompiled.
%
%   If OLD_RULES is empty (or not given), then all rules are re-compiled.
%
%   Parameters given to the function are passed to REMOVE_RULE.

if nargin < 2 || isempty(old_rules)
    old_rules = tiger.param.rules;
end

if nargin < 3 || isempty(new_rules)
    new_rules = old_rules;
end

N = length(old_rules);
for i = 1 : N
    tiger = remove_rule(tiger,old_rules{i},varargin{:});
    if isempty(new_rules{i})
        new_rules{i} = old_rules{i}.copy;
    end
end

tiger = add_rule(tiger,new_rules);
