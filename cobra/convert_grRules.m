function [rules] = convert_grRules(cobra)
% CONVERT_GRRULES  Parse grRules into rules for the COBRA toolbox
%
%   [RULES] = CONVERT_GRRULES(COBRA)
%
%   Parses grRules (human-readable) into the COBRA rules format
%   (i.e., x(1) | x(4)).  Returns a cell array of the rule strings.

rules = map(@convert_aux,cobra.grRules);

function [rule] = convert_aux(str)
    e = parse_string(str);
    e = expr_mapif(e,@(x) is_atom(x),@(x) switch_atom(x));
    rule = expr_to_string(e);
end

function [e] = switch_atom(e)
    [~,loc] = ismember(e.id,cobra.genes);
    e.id = sprintf('x(%i)',loc);
end

end