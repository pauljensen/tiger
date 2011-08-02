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
    e.iterif(@(x) x.is_atom,@(x) switch_atom(x));
    rule = e.to_string();
end

function switch_atom(e)
    [~,loc] = ismember(e.id,cobra.genes);
    e.id = sprintf('x(%i)',loc);
end

end