
levels = { {'*'}, ...
           {'+','-'}, ...
           {'>=','>','=','<','<='} };

op_subs = { '+'  , {'+'}, ...
            '-'  , {'-'}, ...
            '*'  , {'*'}, ...
            '>=' , {'>='}, ...
            '>'  , {'>'}, ...
            '='  , {'=','=='}, ...
            '<'  , {'<'}, ...
            '<=' , {'<='} };

unary = {'-'};

str = 'a + b = c';

e = parse2(lex(str,op_subs),levels,unary);

%%

levels = { {'not'}, ...
           {'>=','>','=','<','<=','~='}, ...
           {'and','or'}, ...
           {'iff','if'} };

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

str = 'a > b < d | e => f < not g & h';

e2 = parse2(lex(str,op_subs),levels,unary)
