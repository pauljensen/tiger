function [rules] = convert_grRules(cobra)

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