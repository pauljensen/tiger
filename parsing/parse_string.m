function [exp] = parse_string(str,varargin)
% PARSE_STRING  Parse a rule string into an EXPR object
%
%   [EXP] = PARSE_STRING(STR,...params...)
%
%   Parse a string and return the corresponding EXPR object.  If STR is a
%   cell array of strings, EXP will be a cell array of EXPR objects.
%
%   If any element of STR is already an EXPR object, a copy of the object 
%   is returned.
%
%   The 'numeric' parameter determines if conditional statements can 
%   contain numeric constants.  If true (the default), atoms in 
%   conditionals are parsed as constants.  If false, they are treated as 
%   variable names.
%
%   If 'status' is true (default = false), a progress indicator is
%   displayed.

p = inputParser;
p.addParamValue('numeric',true);
p.addParamValue('status',false);
p.parse(varargin{:});

numeric = p.Results.numeric;
status = p.Results.status;

% default regular expression for numeric values
NUMERIC_REGEXP = '^[+-]?\d+\.?\d*([eE]+[+-]?\d+)?$';

levels = { {'not'}, ...
           {'>=','>','=','<','<=','~='}, ...
           {'and','or'}, ...
           {'iff','if'} };

unary = {'not'};

strs = assert_cell(str);

N = length(strs);
statbar = statusbar(N,status);
statbar.start('Parsing strings');
exp = cell(1,N);
for i = 1 : N
    exp{i} = parse_single(strs{i});
    statbar.update(i);
end

if numeric
    cellfun(@(x) x.iterif(@(e) e.is_cond,@parse_numerics),exp);
end

if ~isa(str,'cell') && ~isempty(exp)
    exp = exp{1};
end

function [e] = parse_single(s)
    if isa(s,'expr')
        e = s.copy();
    elseif isempty(s)
        e = expr();
        e.NULL = true;
    else
        assert(isa(s,'char'),'Objects of class %s cannot be parsed.', ...
                             class(s));
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
