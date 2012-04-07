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
%
%   If 'as_expr' is true (default), an EXPR object is returned.  If false,
%   the expression structure is returned.
%
%   If 'matlab_levels' is true (default), the 'and' operator is given 
%   higher precedence than 'or', consisting with Matlab's parsing rules 
%   (and the GPRs of some Cobra models).

p = inputParser;
p.addParamValue('numeric',true);
p.addParamValue('status',false);
p.addParamValue('as_expr',false);
p.addParamValue('matlab_levels',true);
p.parse(varargin{:});

numeric = p.Results.numeric;
status = p.Results.status;

if p.Results.matlab_levels
    levels = { {'not'}, ...
           {'>=','>','=','<','<=','~='}, ...
           {'and'}, ...
           {'or'}, ...
           {'iff','if'} };
else
    levels = { {'not'}, ...
               {'>=','>','=','<','<=','~='}, ...
               {'and','or'}, ...
               {'iff','if'} };
end

unary = {'not'};

op_subs = { 'and', {'and','AND','&&','&'}, ...
            'or' , {'or','OR','||','|'}, ...
            'iff', {'iff','Iff','IFF','<=>','<==>','<->','<-->'}, ...
            'if' , {'if','If','IF','=>','==>','->','-->'}, ...
            '>=' , {'>='}, ...
            '>'  , {'>'}, ...
            '='  , {'=','=='}, ...
            '<'  , {'<'}, ...
            '<=' , {'<='}, ...
            '~=' , {'~=','!=','<>'}, ...
            'not', {'not','NOT','Not','~','!'} };

strs = assert_cell(str);

N = length(strs);
statbar = statusbar(N,status);
statbar.start('Parsing strings');
exp = cell(1,N);
for i = 1 : N
    exp{i} = parse_single(strs{i});
    
    if p.Results.as_expr
        exp{i} = struct_to_expr(exp{i});
    end
    
    statbar.update(i);
end

if ~isa(str,'cell') && ~isempty(exp)
    exp = exp{1};
end

function [e] = parse_single(s)
    if isa(s,'expr')
        e = s.copy();
    elseif isa(s,'struct')
        e = s;
    elseif isempty(s)
        e = create_empty_expr_struct();
        e.NULL = true;
    else
        assert(isa(s,'char'),'Objects of class %s cannot be parsed.', ...
                             class(s));
        e = parse(s,levels,unary,op_subs,'numeric',numeric);
    end
end

end
