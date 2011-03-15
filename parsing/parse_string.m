function [exp] = parse_string(str,numeric)
% PARSE_STRING  Parse a rule string into an EXPR object
%
%   [EXP] = PARSE_STRING(STR)
%   [EXP] = PARSE_STRING(STR,NUMERIC)
%
%   Parse a string and return the corresponding EXPR object.  If STR is a
%   cell array of strings, EXP will be a cell array of EXPR objects.
%
%   The NUMERIC option determines if conditional statements can contain
%   numeric constants.  If true (the default), atoms in conditionals are
%   parsed as constants.  If false, they are treated as variable names.

if nargin < 2
    numeric = true;
end

% default regular expression for numeric values
NUMERIC_REGEXP = '^[+-]?\d+\.?\d*([eE]+[+-]?\d+)?$';

levels = { {'not'}, ...
           {'>=','>','=','<','<=','~='}, ...
           {'and','or'}, ...
           {'iff','if'} };

unary = {'not'};

strs = assert_cell(str);
exp = map(@parse_aux,strs);
if numeric
    cellfun(@(x) x.iterif(@(e) e.is_cond,@parse_numerics),exp);
end

if ~isa(str,'cell')
    exp = exp{1};
end

function [e] = parse_aux(s)
    if isempty(s)
        e = expr();
        e.NULL = true;
    else
        e = parse(lex(s),levels,unary);
    end
end

function parse_numerics(cond)
    parse_aux(cond.lexpr);
    parse_aux(cond.rexpr);

    function parse_aux(e)
        if ~e.was_quoted
            m = regexp(e.id,NUMERIC_REGEXP,'once');
            if ~isempty(m)
                e.is_numeric = true;
            end
        end
    end
end

end
