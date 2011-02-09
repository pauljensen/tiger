function [tokens] = lex(str)
% TODO add support for quoted strings

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

alphas = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
all_ops = [op_subs{2:2:end}];
opstart = setdiff(cellfun(@(x) {x(1)},all_ops), ...
                  arrayfun(@(x) {x}, alphas));
op_keys = op_subs(1:2:end);
op_vals = op_subs(2:2:end);    

whitespace = {' ','\t'};

chars = stack(fliplr(str));
tokens = stack();


buf = strbuffer();
while chars.is_another
    ch = chars.pop();
    switch ch
        case {'(',')'}
            if ~isempty(buf)
                tokens.push(make_token());
                buf.clear;
            end
            tokens.push(make_token(ch));
        case whitespace
            if ~isempty(buf)
                tokens.push(make_token());
                buf.clear;
            end
        case opstart
            punc = strbuffer(ch);
            while chars.is_another && is_sub_op([punc.val chars.peek()])
                punc.append(chars.pop());
            end
            % punc may contains a complete operator
            if is_op(punc.val)
                if ~isempty(buf)
                    tokens.push(make_token());
                    buf.clear;
                end
                tokens.push(make_token(punc.val));
            else
                % this was not a complete operator
                buf.append(punc.val);
            end
        otherwise
            buf.append(ch);
    end
end

if ~isempty(buf)
    tokens.push(make_token());
end

tokens.reverse();

function [tf] = is_sub_op(str)
    like = @(x,s) length(x) >= length(s) && strcmp(x(1:length(s)),s);
    tf = any(cellfun(@(x) like(x,str),all_ops));
end

function [tok] = make_token(str)
    if nargin == 0
        str = buf.val;
    end
    
    if is_op(str)
        str = op_keys{cellfun(@(x) ismember(str,x),op_vals)};
        tok = token(str,true);
    elseif str == '('
        tok = token(str,false,true);
    elseif str == ')'
        tok = token(str,false,false,true);
    else
        if str(1) == '''' || str(1) == '"'
            % strip the quotes
            str = str(2:end-1);
        end
        tok = token(str);
    end
end

function [tf] = is_op(str)
    if nargin == 0
        str = buf.val;
    end
    tf = ismember(str,all_ops);
end

end % function
