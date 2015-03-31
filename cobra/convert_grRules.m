function [rules,cobra] = convert_grRules(cobra)
% CONVERT_GRRULES  Parse grRules into rules for the COBRA toolbox
%
%   [RULES] = CONVERT_GRRULES(COBRA)
%
%   Parses grRules (human-readable) into the COBRA rules format
%   (i.e., x(1) | x(4)).  Returns a cell array of the rule strings and
%   the modified COBRA model.

% check if genes are defined
if ~isfield(cobra,'genes')
    exprs = map(@parse_string,cobra.grRules);
    cobra.genes = unique(flatten(map(@get_atoms,exprs)));
end

rules = map(@convert_aux,cobra.grRules);
cobra.rules = rules;

function [rule] = convert_aux(str)
    e = parse_string(str);
    e = expr_mapif(e,@(x) is_atom(x),@(x) switch_atom(x));
    rule = regexprep(expr_to_string(e), {' or ',' and '}, {' | ',' & '});
end

function [e] = switch_atom(e)
    [~,loc] = ismember(e.id,cobra.genes);
    e.id = sprintf('x(%i)',loc);
end

end