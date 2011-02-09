function [exp] = parse_string(str)

levels = { {'not'}, ...
           {'>=','>','=','<','<=','~='}, ...
           {'and','or'}, ...
           {'iff','if'} };

unary = {'not'};

if isempty(str)
    exp = expr();
    exp.NULL = true;
else
    exp = parse(lex(str),levels,unary);
end
