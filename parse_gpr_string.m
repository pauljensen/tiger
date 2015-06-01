function expr = parse_gpr_string(gpr)
% PARSE_GPR_STRING  Parse GPR string into SIMPL expression.
%
%   GPR strings may contain only the following:
%       - Logical operators & and |
%       - Parentheses ( and )
%       - Gene identfiers -- unquoted strings that cannot contain whitespace or
%         the characters &, |, (, and ).

genes = cellfilter(@isempty, splitstr(gpr, '[&\|\(\)\s]+'), true);
genes = fliplr(sort(unique(genes)));

if isempty(genes)
    expr = simpl.Empty();
    return
elseif length(genes) == 1
    expr = simpl.Variable(genes{1});
    return
end

rulestr = gpr;
for i = 1 : length(genes)
    rulestr = regexprep(rulestr,genes{i},['x(' int2str(i) ')']);
end

x = simpl.Variable(genes);
expr = eval(rulestr);
