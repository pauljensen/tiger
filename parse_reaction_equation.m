function parts = parse_reaction_equation(equation)

parts.reversible = ~isempty(strfind(equation, '<=>'));
backwards = strfind(equation, '<=');

if parts.reversible
    sides = strsplit(equation, '<=>');
elseif backwards
    sides = fliplr(strsplit(equation, '<='));
else
    sides = strsplit(equation, '=>');
end

parts.reactants = build_side(sides{1});
parts.products = build_side(sides{2});

end


function reactables = build_side(side)

pattern = '\((?<coef>\d*\.?\d+)\)\s+(?<met>\w+)\[(?<comp>\w+)\]';
matches = regexp(side, pattern, 'names');
if isempty(matches)
    reactables = Reactable.empty(0);
else
    reactables(length(matches)) = Reactable;
end
for i = 1 : length(matches)
    reactables(i) = Reactable(str2double(matches(i).coef), ...
                              matches(i).met, ...
                              matches(i).comp);
end

end
